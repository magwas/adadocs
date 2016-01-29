<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:zenta="http://magwas.rulez.org/zenta"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:function name="zenta:log">
		<xsl:param name="input"/>
		<xsl:param name="msg"/>
		<xsl:message>
		LOG <xsl:value-of select="$msg"/>:|<xsl:copy-of select="$input"/>|
		</xsl:message>
		<xsl:copy-of select="$input"/>
	</xsl:function>
	
	<xsl:function name="zenta:compileTarget">
		<xsl:param name="target"/>
		<xsl:param name="via"/>
		<xsl:param name="direction"/>
		<target>
			<xsl:attribute name="targetId" select="$target/@id" />
			<xsl:attribute name="targetName" select="concat('Ada:',$target/@name)" />
			<xsl:attribute name="relationId" select="$via/@id" />
			<xsl:attribute name="relationName" select="concat('Ada:',$via/@name)" />
			<xsl:attribute name="minOccurs" select="tokenize($via/property[@key='minOccurs']/@value,'/')[$direction]"/>
			<xsl:attribute name="direction" select="$direction" />
		</target>
	</xsl:function>

	<xsl:function name="zenta:getNeighbourDefs">
		<xsl:param name="elemId"/>
		<xsl:param name="doc"/>
		<xsl:variable name="backVias" select="$doc//element[@target=$elemId]"/>
		<xsl:variable name="fwdVias" select="$doc//element[@source=$elemId]"/>
		<targetlist>
			<xsl:for-each select="$fwdVias">
				<xsl:copy-of select="zenta:compileTarget(
					$doc//element[@id=current()/@target],
					.,
					1
				)"/>
			</xsl:for-each>
			<xsl:for-each select="$backVias">
				<xsl:copy-of select="zenta:compileTarget(
					$doc//element[@id=current()/@source],
					.,
					2
				)"/>
			</xsl:for-each>
		</targetlist>
	</xsl:function>
	
	<xsl:template match="zenta:model" mode="enrich">
		<xsl:variable name="changetypeResult">
			<xsl:apply-templates select="." mode="meta"/>
		</xsl:variable>
		<xsl:apply-templates select="$changetypeResult" mode="enrich_run"/>
	</xsl:template>

	<xsl:function name="zenta:buildConnection">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
			<xsl:variable name="mO" select="$element/property[@key='minOccurs']/@value"/>
			<connection>
				<xsl:choose>
					<xsl:when test="$direction=1">
						<xsl:attribute name="sourceClass" select="$element/@source"/>
						<xsl:attribute name="targetClass" select="$element/@target"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="sourceClass" select="$element/@target"/>
						<xsl:attribute name="targetClass" select="$element/@source"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="direction" select="$direction"/>
				<xsl:copy-of select="$element/@ancestor|$element/@id"/>
				<xsl:attribute name="minOccurs" select="zenta:occursNumber(tokenize($mO,'/')[$direction])"/>
			</connection>
	</xsl:function>
	
	<xsl:template match="zenta:model" mode="meta">
		<xsl:variable name="changetypeResult">
			<xsl:apply-templates select="*" mode="changetype"/>
		</xsl:variable>
		<xsl:copy>
			<metamodel>
				<xsl:for-each select="//element[@source]">
					<xsl:copy-of select="zenta:buildConnection(.,1)"/>
					<xsl:copy-of select="zenta:buildConnection(.,2)"/>
				</xsl:for-each>
			</metamodel>
			<xsl:copy-of select="$changetypeResult"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="zenta:model" mode="changetype">
		<zenta:enriched>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="changetype"/>
		</zenta:enriched>
	</xsl:template>

	<xsl:template match="@xsi:type" mode="changetype">
		<xsl:attribute name="xsi:type" select="
			if(current()/../@ancestor)
			then
				concat('Ada:',//element[@id=current()/../@ancestor]/@name)
			else
				'zenta:BasicObject'"/>
	</xsl:template>
	
	<xsl:function name="zenta:getTargetThroughRelation">
		<xsl:param name="doc"/>
		<xsl:param name="relation"/>
		<xsl:param name="direction"/>
		<xsl:variable name="targetId" select="
			if($direction=1)
			then
				$relation/@target
			else
				$relation/@source
		"/>
		<xsl:copy-of select="$doc//element[@id=$targetId]"/>
	</xsl:function>

	<xsl:function name="zenta:occursNumber">
		<xsl:param name="theString"/>
		<xsl:choose>
			<xsl:when test="empty($theString)">0</xsl:when>
			<xsl:otherwise><xsl:value-of select="number($theString)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:checkRelationCount">
		<xsl:param name="element"/>
		<xsl:param name="relations"/>
		<xsl:param name="template"/>
		<xsl:if test="
			count($relations)
			&lt;
			zenta:occursNumber(string($template/@minOccurs))
		">
			<error type="less than minOccurs values" element="{$element/@id}">
				<xsl:copy-of select="$template/@relationId|$template/@relationName|$template/@minOccurs"/>
			</error>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getRelations">
		<xsl:param name="target"/>
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
			<xsl:copy-of select="$doc//
				element[@ancestor=$target/@relationId and
				( @source=$element/@id or @target = $element/@id )]"/>
	</xsl:function>

	<xsl:function name="zenta:getRelationsnew">
		<xsl:param name="element"/>
		<xsl:param name="docinput"/>
		<xsl:variable name="doc">
			<xsl:apply-templates select="$docinput" mode="meta"/>
		</xsl:variable>
		<xsl:for-each select="$doc/zenta:model/metamodel/connection[@sourceClass=$element/@id]">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="zenta:createValueFromRelation">
		<xsl:param name="relation"/>
		<xsl:param name="doc"/>
		<xsl:param name="direction"/>
		<value>
			<xsl:variable name="target" select="zenta:getTargetThroughRelation($doc,$relation,$direction)"/>
			<xsl:attribute name="target" select="$target/@id"/>
			<xsl:attribute name="name" select="$target/@name"/>
		</value>
	</xsl:function>

	<xsl:function name="zenta:createValuesForElement">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:variable name="neighbourhood" select="zenta:getNeighbourDefs($element/@ancestor,$doc)"/>
		<xsl:for-each select="$neighbourhood/target">
			<xsl:variable name="template" select="."/>
			<xsl:variable name="relations" select="zenta:getRelations(.,$element,$doc)"/>
			<xsl:copy-of select="zenta:checkRelationCount($element,$relations,$template)"/>
			<xsl:for-each select="$relations">
				<xsl:copy-of select="zenta:createValueFromRelation(.,$doc,$template/@direction)"/>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:function>

	<xsl:template match="element" mode="enrich_run">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	    <xsl:copy-of select="zenta:createValuesForElement(.,/)"/>
	  </xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()" mode="#all">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	  </xsl:copy>
	</xsl:template>

</xsl:stylesheet>

