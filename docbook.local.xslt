<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			version='2.0'
			xmlns="http://www.w3.org/TR/xhtml1/transitional"
			xmlns:fn="http://www.w3.org/2005/xpath-functions"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:zenta="http://magwas.rulez.org/zenta"
			exclude-result-prefixes="#default">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<!--xsl:template match="element[@xsi:type='Ada:varlistentry']" mode="elementTitle">
		<xsl:value-of select="@name"/>
	</xsl:template>

    <xsl:template match="element[@id='basicobject']|connection[@id='basicrelation']" mode="varlistentry">
    </xsl:template>

    <xsl:template match="folder[property[@key='display']/@value='hidden']" mode="varlist"/-->
    
    <xsl:function name="zenta:modelErrorTitle">
    	<xsl:param name="object"/>
    	<xsl:param name="doc"/>
    	<xsl:value-of select="if ($object/object/error/@type='less than minOccurs values')
        	then concat(
        		'extra relation for ',
	        	$doc//element[@id=$object/object/error/@element]/@name
	        	)
	        else if ($object/object/error/@type='more than maxOccurs values')
        	then concat(
        		'missing relation for ',
	        	$doc//element[@id=$object/object/error/@element]/@name
	        	)
			else concat('unknown error type ', $object/object/error/@type)
    	"/>
    </xsl:function>
    
    <xsl:function name="zenta:modelErrorDescription">
    	<xsl:param name="object"/>
    	<xsl:param name="doc"/>
    	<xsl:variable name="errobj" select="$object/object/error"/>
    	<xsl:variable name="relations" select="$doc//element[@id=$errobj/@element]/value[@ancestorName=$errobj/@name]/@name"/>
    	<xsl:value-of select="if ($errobj/@type='less than minOccurs values')
        	then concat(
	        	$doc//element[@id=$errobj/@element]/@name,
	        	' should have at least ',
	        	$errobj/@minOccurs, ' ',
	        	$errobj/@name,
	        	' relation, but have only ',
	        	count($relations),
	        	' to ',
	        	string-join($relations,' and ')
	        	)
	        else if ($errobj/@type='more than maxOccurs values')
        	then concat(
	        	$doc//element[@id=$object/object/error/@element]/@name,
	        	' should have at most ',
	        	$errobj/@maxOccurs, ' ',
	        	$errobj/@name,
	        	' relation, but already have ',
	        	count($relations),
	        	' to ',
	        	string-join($relations,' and ')
	        	)
			else concat('unknown error type ', $object/object/error/@type)
    	"/>
    </xsl:function>
</xsl:stylesheet>

