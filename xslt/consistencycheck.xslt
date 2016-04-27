<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
    xmlns:zenta="http://magwas.rulez.org/zenta"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="debug" select="'false'"/>
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
	 		<xsl:variable name="object" select="."/>
	 		<xsl:for-each select="saxon:evaluate($valuepath)">
	 			<entry>
	 				<xsl:attribute name="name" select="$name"/>
	 				<xsl:attribute name="value" select="."/>
	 				<object>
	 					<xsl:copy-of select="$object"/>
	 				</object>
	 				<value>
		 				<xsl:copy-of select="."/>
	 				</value>
	 			</entry>
	 		</xsl:for-each>
		</xsl:for-each>
	</xsl:for-each>
</xsl:function>

	<xsl:template match="/">
		<consistencycheck>
			<xsl:apply-templates select="//check"/>
		</consistencycheck>
	</xsl:template>
  <xsl:template match="check">
  		<data>
  			<xsl:variable name="inmodel" select="zenta:createElemList(@modelfile,@modelnamepath,@modelbasepath,@modelvaluepath)"/>
  			<xsl:variable name="ininput" select="zenta:createElemList(@inputfile,@inputnamepath,@inputbasepath,@inputvaluepath)"/>
  			<xsl:variable name="inputerrorid" select="@inputerrorid"/>
  			<xsl:variable name="modelerrorid" select="@modelerrorid"/>
  			<xsl:variable name="errorURL" select="@errorURL"/>
  			<xsl:if test="$debug='true'">
		  		<model>
		  			<xsl:copy-of select="$inmodel"/>
		  		</model>
		  		<input>
		  			<xsl:copy-of select="$ininput"/>
		  		</input>
  			</xsl:if>
	  		<xsl:copy-of select="."/>
	  		<onlymodel>
	  			<xsl:for-each select="$inmodel">
	  				<xsl:if test="count($ininput[@name=current()/@name and @value=current()/@value]) =0 ">
	  					<entry>
	  						<xsl:copy-of select="@name|@value"/>
	  						<xsl:variable name="errorID" select="saxon:evaluate($modelerrorid,.)"/>
	  						<xsl:attribute name="errorID" select="$errorID"/>
	  						<xsl:attribute name="errorURL" select="saxon:evaluate($errorURL,$errorID)"/>
	  						<xsl:copy-of select="object|value"/>
	  					</entry>
	  					<xsl:message>onlymodel:<xsl:value-of select="@name"/>/<xsl:value-of select="@value"/>.</xsl:message>
	  				</xsl:if>
	  			</xsl:for-each>
	  		</onlymodel>
	  		<onlyinput>
	  			<xsl:for-each select="$ininput">
	  				<xsl:if test="count($inmodel[@name=current()/@name and @value=current()/@value]) =0 ">
	  					<entry>
	  						<xsl:copy-of select="@name|@value"/>
	  						<xsl:variable name="errorID" select="saxon:evaluate($inputerrorid,.)"/>
	  						<xsl:attribute name="errorID" select="$errorID"/>
	  						<xsl:attribute name="errorURL" select="saxon:evaluate($errorURL,$errorID)"/>
	  						<xsl:copy-of select="object|value"/>
	  					</entry>
	  				</xsl:if>
	  			</xsl:for-each>
	  		</onlyinput>
  		</data>
  </xsl:template>

</xsl:stylesheet>

