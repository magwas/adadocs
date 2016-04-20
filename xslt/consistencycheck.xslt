<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
    xmlns:zenta="http://magwas.rulez.org/zenta"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<xsl:include href="functions.xslt"/>

<xsl:function name="zenta:createElemList">
	<xsl:param name="file"/>
	<xsl:param name="namepath"/>
	<xsl:param name="basepath"/>
	<xsl:param name="valuepath"/>
	<xsl:variable name="model" select="document($file)"/>
	<xsl:for-each select="$model">
		<xsl:variable name="bases" select="saxon:evaluate($basepath)"/>
		<xsl:for-each select="$bases">
	 		<xsl:variable name="name" select="saxon:evaluate($namepath)"/>
	 		<xsl:for-each select="saxon:evaluate($valuepath)">
	 			<entry>
	 				<xsl:attribute name="name" select="$name"/>
	 				<xsl:attribute name="value" select="."/>
	 			</entry>
	 		</xsl:for-each>
		</xsl:for-each>
	</xsl:for-each>
</xsl:function>

  <xsl:template match="check">
  		<data>
  			<xsl:variable name="inmodel" select="zenta:createElemList(@modelfile,@modelnamepath,@modelbasepath,@modelvaluepath)"/>
  			<xsl:variable name="ininput" select="zenta:createElemList(@inputfile,@inputnamepath,@inputbasepath,@inputvaluepath)"/>
	  		<model>
	  			<xsl:copy-of select="$inmodel"/>
	  		</model>
	  		<input>
	  			<xsl:copy-of select="$ininput"/>
	  		</input>
	  		<check>
	  			<xsl:copy-of select="."/>
	  		</check>
	  		<onlymodel>
	  			<xsl:for-each select="$inmodel">
	  				<xsl:if test="count($ininput[@name=current()/@name and @value=current()/@value]) =0 ">
	  					<entry><xsl:copy-of select="@name|@value"/>
	  					</entry>
	  					<xsl:message>onlymodel:<xsl:value-of select="@name"/>/<xsl:value-of select="@value"/>.</xsl:message>
	  				</xsl:if>
	  			</xsl:for-each>
	  		</onlymodel>
	  		<onlyinput>
	  			<xsl:for-each select="$ininput">
	  				<xsl:if test="count($inmodel[@name=current()/@name and @value=current()/@value]) =0 ">
	  					<xsl:message>onlyinput:<xsl:value-of select="@name"/>/<xsl:value-of select="@value"/>.</xsl:message>
	  					<entry><xsl:copy-of select="@name|@value"/>
	  					</entry>
	  				</xsl:if>
	  			</xsl:for-each>
	  		</onlyinput>
  		</data>
  </xsl:template>

</xsl:stylesheet>

