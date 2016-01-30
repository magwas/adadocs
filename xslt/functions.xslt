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

	<xsl:function name="zenta:buildConnection">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
			<xsl:variable name="mO" select="$element/property[@key='minOccurs']/@value"/>
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
				<xsl:copy-of select="$element/@ancestor|$element/@id|$element/@name"/>
				<xsl:attribute name="minOccurs" select="zenta:occursNumber(tokenize($mO,'/')[$direction])"/>
			</connection>
	</xsl:function>

</xsl:stylesheet>