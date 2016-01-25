<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:zenta="http://magwas.rulez.org/zenta"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:function name="zenta:getNeighbourDefs">
		<xsl:param name="elemId"/>
		<xsl:param name="doc"/>
	</xsl:function>
	
	<xsl:template match="/">
	  <xsl:message>Begin</xsl:message>
	  <xsl:copy>
	    <xsl:apply-templates select="*|text()|processing-instruction()|comment()" mode="changetype"/>
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
	
	<xsl:template match="element[@xsi:type='zenta:BasicObject']" mode="enrich">
		<xsl:variable name="ancestor" select="//element[@id=current()/@ancestor]/@id"/>
		<xsl:copy>
		    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
			<value>
				<xsl:attribute name="referenced" select="//element[@target=$ancestor]/@source"/>
				<xsl:attribute name="name" select="//element[@id=//element[@target=$ancestor]/@source]/@name"/>
			</value>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()" mode="#all">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	  </xsl:copy>
	</xsl:template>


</xsl:stylesheet>

