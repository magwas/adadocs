<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:archimate="http://www.archimatetool.com/archimate"
   xmlns:zenta="http://magwas.rulez.org/zenta"
   xmlns:x="http://www.jenitennison.com/xslt/xspec"
   xmlns:saxon="http://saxon.sf.net/"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../functions.xslt"/>
	
	<xsl:param name="tests"/>
	<xsl:param name="terminate" select="'yes'"/>
	<xsl:param name="sources"/>
	
	<xsl:variable name="doc" select="/"/>

	<xsl:template match="/">
	<xsl:variable name="sources">
	<sources>
	 <xsl:for-each select="tokenize($sources,',')">
		 <document>
		 	<xsl:attribute name="name" select="."/>
		 	<xsl:copy-of select="document(.)"/>
		 </document>
	 </xsl:for-each>
	</sources>
	</xsl:variable>
	
		<xsl:for-each select="document($tests)//x:expect">
			<xsl:variable name="lineno" select="saxon:line-number(@test)"/>
			<xsl:variable name="label" select="@label"/>
			<xsl:variable name="test" select="@test"/>
			<xsl:for-each select="$doc">
				<xsl:message select="concat($lineno,':',$label,':')"/>
				<xsl:choose>
					<xsl:when test="saxon:evaluate($test,$sources)">
						<xsl:message select="'OK'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="{$terminate}" select="concat('FAIL. test=',$test)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>