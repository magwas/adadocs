<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:archimate="http://www.archimatetool.com/archimate"
   xmlns:zenta="http://magwas.rulez.org/zenta"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
	<objlist>
		<xsl:for-each select="//element[@template='true']">
			<objectClass>
				<xsl:copy-of select="@id|@name"/>
				<xsl:for-each select="//element[@ancestor=current()/@id]">
					<object>
						<xsl:copy-of select="@id|@name"/>
						<xsl:for-each select="value">
							<value>
								<xsl:copy-of select="@id|@direction"/>
								<xsl:attribute name="name" select="@ancestorName"/>
								<xsl:value-of select="@name"/>
							</value>
						</xsl:for-each>
					</object>
				</xsl:for-each>
			</objectClass>
<xsl:text>
</xsl:text>
		</xsl:for-each>
	</objlist>
</xsl:template>
</xsl:stylesheet>

