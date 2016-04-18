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

	<xsl:function name="zenta:value-by-names">
		<xsl:param name="doc"/>
		<xsl:param name="source"/>
		<xsl:param name="target"/>
		<xsl:copy-of select="$doc//element[@name=$source]/value[@target=//element[@name=$target]/@id]"/>
	</xsl:function>

	<xsl:function name="zenta:connection-by-names">
		<xsl:param name="doc"/>
		<xsl:param name="source"/>
		<xsl:param name="target"/>
		<xsl:copy-of select="$doc//connection[@source=//element[$source]/@id and @target=//element[@name=$target]/@id]"/>
	</xsl:function>

	<xsl:function name="zenta:assertSequenceEquals">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:copy-of select="
		   	zenta:log(
      			zenta:toStringSequence($expected,',')
      		,'expected')
      		 = 
      		 zenta:log(
      		 	zenta:toStringSequence($result,',')
      		,'result')
		"/>
	</xsl:function>
	<xsl:function name="zenta:toStringSequence">
		<xsl:param name="input"/>
		<xsl:param name="delimiter"/>
		<xsl:variable name="sorted">
			<xsl:for-each select="$input">
				<xsl:sort select="."/>
				<a><xsl:copy-of select="string(.)"/></a>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="
				string-join($sorted//a,$delimiter)
		"/>
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
		<xsl:param name="template"/>
		<xsl:param name="relations"/>
		<xsl:if test="
			count($relations)
			&lt;
			zenta:occursNumber(string($template/@minOccurs))
		">
			<error type="less than minOccurs values" element="{$element/@id}">
				<xsl:copy-of select="$template/@id|$template/@name|$template/@minOccurs|$template/@source|$template/@target"/>
			</error>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getMinOccurs">
		<xsl:param name="doc"/>
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element/property[@key='minOccurs']">
				<xsl:copy-of select="$element/property[@key='minOccurs']/@value"/>
			</xsl:when>
			<xsl:when test="$doc//element[@id=$element/@ancestor]">
				<xsl:copy-of select="zenta:getMinOccurs($doc,$doc//element[@id=$element/@ancestor])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="'0'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:buildConnection">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
		<xsl:param name="doc"/>
			<xsl:variable name="mO" select="zenta:getMinOccurs($doc,$element)"/>
			<connection>
				<xsl:choose>
					<xsl:when test="$direction=1">
						<xsl:attribute name="source" select="$element/@source"/>
						<xsl:attribute name="target" select="$element/@target"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="source" select="$element/@target"/>
						<xsl:attribute name="target" select="$element/@source"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="direction" select="$direction"/>
				<xsl:attribute name="minOccurs" select="zenta:occursNumber(tokenize($mO,'/')[$direction])"/>
				<xsl:attribute name="ancestorName" select="$doc//element[@id=$element/@ancestor]/@name"/>
				<xsl:copy-of select="$element/@ancestor|$element/@id|$element/@name|$element/documentation"/>
			</connection>
	</xsl:function>

	<xsl:function name="zenta:getAncestry">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:if test="$element">
			<xsl:copy-of select="zenta:getAncestry($doc//element[@id=$element/@ancestor],$doc)"/>
			<xsl:copy-of select="$element"/>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getDefiningRelations">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:for-each select="zenta:getAncestry($element,$doc)">
			<xsl:copy-of select="$doc//connection[@source=current()/@ancestor]"/>
		</xsl:for-each>
	</xsl:function>

</xsl:stylesheet>