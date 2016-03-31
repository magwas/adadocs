<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:archimate="http://www.archimatetool.com/archimate"
   xmlns:zenta="http://magwas.rulez.org/zenta"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="functions.xslt"/>
	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:template match="zenta:enriched">
		<article version="5.0">
	    	<xsl:apply-templates select="*"/>
		</article>
	</xsl:template>

	<xsl:template match="folder">
		<section>
			<xsl:copy-of select="@id"/>
			<title>
				<xsl:value-of select="@name"/>
			</title>
			<para>
				<xsl:copy-of select="documentation/(*|text())"/>
			</para>
			<xsl:apply-templates select="folder"/>
			<table class="elementtable"><tgroup cols="2"><colspec colname="c1"/><colspec colname="c2"/>
			<tbody>
				<xsl:for-each select="element[@xsi:type='zenta:ZentaDiagramModel']">
				<row><entry namest="c1" nameend="c2"><para>
					<figure>
						<title><xsl:value-of select="@name"/></title>
						<remark><xsl:copy-of select="documentation/(*|text())"/></remark>
						<mediaobject><imageobject><imagedata fileref="pics/{@id}.png"/></imageobject></mediaobject>
					</figure>
				</para></entry></row>
				</xsl:for-each>
				<xsl:for-each select="element[@xsi:type!='zenta:ZentaDiagramModel']">
				<row>
					<entry class="starter">
						<anchor id="{@id}"/>
						<xsl:value-of select="@name"/> (<xsl:value-of select="@xsi:type"/>)
					</entry>
					<entry class="documentation"><xsl:copy-of select="documentation/(*|text())"/>
					</entry>
				</row>
				</xsl:for-each>
				<xsl:for-each select="connection[@name and @direction='1']">
				<row>
					<entry class="starter">
						<anchor id="{@id}"/>
						<xsl:value-of select="@name"/> (<xsl:value-of select="@ancestorName"/>)
					</entry>
					<entry class="documentation"><xsl:copy-of select="documentation/(*|text())"/>
					</entry>
				</row>
				</xsl:for-each>
			</tbody>
			</tgroup>
			</table>
		</section>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()" mode="#all">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	  </xsl:copy>
	</xsl:template>

</xsl:stylesheet>

