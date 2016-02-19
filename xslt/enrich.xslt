<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:zenta="http://magwas.rulez.org/zenta"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:include href="functions.xslt"/>
	
	<xsl:template match="zenta:model" mode="enrich">
		<xsl:variable name="changetypeResult">
			<xsl:apply-templates select="." mode="changetype"/>
		</xsl:variable>
		<xsl:variable name="enrich1Result">
		<xsl:apply-templates select="$changetypeResult" mode="enrich_run1"/>
		</xsl:variable>
		<xsl:apply-templates select="$enrich1Result" mode="enrich_run2"/>
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
				."/>
	</xsl:template>

	<xsl:template match="element" mode="changetype">
		<xsl:copy>
			<xsl:if test="//child[@zentaElement=current()/@id]/ancestor::*/property/@key='Template'">
				<xsl:attribute name="template" select="'yes'"/>
			</xsl:if>
		    <xsl:apply-templates select="@*|*|text()|processing-instruction()|comment()" mode="changetype"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="connection" mode="createValue">
		<value>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="name" select="//element[@id=current()/@target]/@name"/>
		</value>
	</xsl:template>

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

	<xsl:template match="element" mode="createValue">
		<xsl:variable name="element" select="."/>
		<xsl:variable name="doc" select="/"/>		
		<xsl:variable name="definingRelations" select="zenta:getDefiningRelations($element,/)"/>
		<xsl:for-each select="$definingRelations">
			<xsl:variable name="relations" select="$doc//connection[@source=$element/@id and @ancestor=current()/@id]"/>
			<xsl:if test="not($element/@template)">
				<xsl:copy-of select="zenta:checkRelationCount($element,.,$relations)"/>
			</xsl:if>
			<xsl:for-each select="$relations">
				<xsl:apply-templates select="." mode="createValue" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="element" mode="enrich_run2">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	    <xsl:apply-templates select="." mode="createValue"/>
	  </xsl:copy>
	</xsl:template>

	<xsl:template match="element[@source]" mode="enrich_run1">
		<xsl:copy-of select="zenta:buildConnection(.,1,/)"/>
		<xsl:copy-of select="zenta:buildConnection(.,2,/)"/>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()" mode="#all">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	  </xsl:copy>
	</xsl:template>

</xsl:stylesheet>

