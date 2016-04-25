<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
    xmlns:zenta="http://magwas.rulez.org/zenta"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:saxon="http://saxon.sf.net/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

    <xsl:param name="xpath"/>

<xsl:include href="functions.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="doc" select="/"/>
    <xsl:copy>
      <xsl:copy-of select="saxon:evaluate($xpath)"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

