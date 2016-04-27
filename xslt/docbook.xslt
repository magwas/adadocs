<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:archimate="http://www.archimatetool.com/archimate"
   xmlns:zenta="http://magwas.rulez.org/zenta"
xmlns:saxon="http://saxon.sf.net/"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="functions.xslt"/>
	<xsl:include href="docbook.local.xslt"/>
	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:param name="inconsistencyfile"/>
	<xsl:variable name="inconsistencies" select="document($inconsistencyfile)"/>
	<xsl:template match="element[@xsi:type='zenta:ZentaDiagramModel']" mode="figure">
		<figure>
			<title><xsl:value-of select="@name"/></title>
			<remark><xsl:copy-of select="documentation/(*|text())"/></remark>
			<mediaobject><imageobject><imagedata fileref="pics/{@id}.png"/></imageobject></mediaobject>
		</figure>
	</xsl:template>
	
	<xsl:template match="element[@xsi:type!='zenta:ZentaDiagramModel']" mode="elementTitle">
		<anchor id="{@id}"/>
		<xsl:value-of select="@name"/>
	</xsl:template>

	<xsl:template match="connection[@name and @direction='1']" mode="elementTitle">
		<anchor id="{@id}"/>
		<xsl:value-of select="@name"/>
	</xsl:template>

	<xsl:function name="zenta:relationName">
		<xsl:param name="value"/>
		<xsl:variable name="given" select="if ($value/@relationName != '') then $value/@relationName else $value/@ancestorName"/>
		<xsl:copy-of select="
			if(contains($given,'/'))
			then
				tokenize(string($given),'/')[number($value/@direction)]
			else
				if($value/@direction='1')
				then
					$given
				else
					zenta:passive($given)
			"/>
	</xsl:function>

	<xsl:template match="element[@xsi:type!='zenta:ZentaDiagramModel']"
		mode="elementDetails">
		<para>
			<xsl:value-of select="concat(zenta:capitalize(zenta:articledName(.,'any')),' is ', zenta:articledName(//element[@id=current()/@ancestor],'no'),'.')"/>
		</para>
		<para>
			<xsl:copy-of select="documentation/(*|text())"/>
		</para>
		<para>
		<xsl:if test="value">
			connections:
			<itemizedlist>
				<xsl:for-each select="value">
					<listitem>
						<xsl:variable name="atleast">
							<xsl:if test="number(@minOccurs) > 0">
								<xsl:value-of select="if (number(@minOccurs) > 0) then concat('at least ',@minOccurs,' ') else ''"/>
							</xsl:if>
						</xsl:variable>
						<xsl:variable name="atmost">
								<xsl:value-of select="if (number(@maxOccurs) > 0) then concat('at most ',@maxOccurs,' ') else '' "/>
						</xsl:variable>
						<xsl:variable name="numbers" select="if ($atmost!='' and $atleast!='') then concat($atleast,'and ',$atmost) else concat($atleast,$atmost)"/>
						<xsl:value-of select="concat(
								../@name,' ',
								zenta:relationName(.),' ',
								if (@template='true') then $numbers else '',
								@name)"/>
					</listitem>
				</xsl:for-each>
			</itemizedlist>
		</xsl:if>
		</para>
	</xsl:template>

	<xsl:template match="connection[@name and @direction='1']"
		mode="elementDetails">
		<para>
			<xsl:value-of select="concat(zenta:capitalize(zenta:articledName(.,'any')),' is ', zenta:articledName(//connection[@id=current()/@ancestor and @direction='1'],'no'),'.')"/>
		</para>
		<para>
			<xsl:copy-of select="documentation/(*|text())"/>
		</para>
	</xsl:template>

	<xsl:template match="element[@xsi:type!='zenta:ZentaDiagramModel']|connection[@name and @direction='1']" mode="tablerow">
		<row>
			<entry class="starter">
				<xsl:apply-templates select="." mode="elementTitle"/>
			</entry>
			<entry class="documentation">
				<xsl:apply-templates select="." mode="elementDetails"/>
			</entry>
		</row>
	</xsl:template>

	<xsl:template match="element[@xsi:type!='zenta:ZentaDiagramModel']|connection[@name and @direction='1']" mode="varlistentry">
		<varlistentry>
			<term>
				<xsl:apply-templates select="." mode="elementTitle"/>
			</term>
			<listitem>
				<xsl:apply-templates select="." mode="elementDetails"/>
			</listitem>
		</varlistentry>
	</xsl:template>

	<xsl:template match="element[@xsi:type='zenta:ZentaDiagramModel']" mode="tablerow">
		<row><entry namest="c1" nameend="c2"><para>
			<xsl:apply-templates select="." mode="figure"/>
		</para></entry></row>
	</xsl:template>

	<xsl:template match="folder" mode="elementtable">
		<table class="elementtable">
			<tgroup cols="2"><colspec colname="c1"/><colspec colname="c2"/>
				<tbody>
					<xsl:apply-templates select="element[@xsi:type='zenta:ZentaDiagramModel']" mode="tablerow"/>
					<xsl:apply-templates select="element[@xsi:type!='zenta:ZentaDiagramModel']" mode="tablerow"/>
					<xsl:apply-templates select="connection[@name and @direction='1']" mode="tablerow"/>
				</tbody>
			</tgroup>
		</table>
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
			<xsl:apply-templates select="." mode="elementtable"/>
		</section>
	</xsl:template>

	<xsl:template match="folder" mode="varlistList">
		<para>
			<xsl:apply-templates select="element[@xsi:type='zenta:ZentaDiagramModel']" mode="figure"/>
			<xsl:if test="element[@xsi:type!='zenta:ZentaDiagramModel']|connection[@name and @direction='1']">
				<variablelist>
					<xsl:apply-templates select="element[@xsi:type!='zenta:ZentaDiagramModel']" mode="varlistentry"/>
					<xsl:apply-templates select="connection[@name and @direction='1']" mode="varlistentry"/>
				</variablelist>
			</xsl:if>
		</para>
	</xsl:template>

	<xsl:template match="folder" mode="varlist">
		<section>
			<xsl:copy-of select="@id"/>
			<title>
				<xsl:value-of select="@name"/>
			</title>
			<para>
				<xsl:copy-of select="documentation/(*|text())"/>
			</para>
			<xsl:apply-templates select="folder" mode="varlist"/>
			<xsl:apply-templates select="." mode="varlistList"/>
		</section>
	</xsl:template>

	<xsl:template match="error" mode="#all">
 		<varlistentry>
 			<term><xsl:value-of select="@type"/></term>
 			<listitem>
				<variablelist>
					<varlistentry>
						<term>
							<anchor id="{@errorID}">Offending element:</anchor>
						</term>
						<listitem>
							<xsl:variable name="eid" select="@element"/>
							<link linkend="{@element}"><xsl:value-of select="//element[@id=$eid]/@name"/></link>
						</listitem>
					</varlistentry>
					<varlistentry>
						<term>Relation:</term>
						<listitem>
							<link linkend="{@id}"><xsl:value-of select="@name"/></link>
						</listitem>
					</varlistentry>
				</variablelist>
			</listitem>
 		</varlistentry>
	</xsl:template>
	<xsl:template match="zenta:enriched" mode="#all">
		<xsl:variable name="doc" select="/"/>
		<article version="5.0">
	    	<xsl:apply-templates select="*" mode="#current"/>
	    	<section>
	    		<title>Deviations</title>
	    		<xsl:for-each select="$inconsistencies//data">
	    			<section>
	    				<title><xsl:value-of select="check/@title"/></title>
	    				<xsl:choose>
		    				<xsl:when test="onlyinput/entry|onlymodel/entry">
				    			<variablelist>
					    			<xsl:for-each select="onlyinput/entry|onlymodel/entry">
					    				<varlistentry>
					    					<term>
					    						<anchor><xsl:attribute name="id" select="@errorID"/></anchor>
		  											<xsl:value-of select="saxon:evaluate(
		  											../../check/@errortitlestring,
		  											.,
		  											$doc)"/>
					    					</term>
					    					<listitem>
					    						<para>
		  											<xsl:copy-of select="saxon:evaluate(
		  											../../check/@errordescription,
		  											.,
		  											$doc)"/>
					    						</para>
					    					</listitem>
					    				</varlistentry>
					    			</xsl:for-each>
				    			</variablelist>
				    		</xsl:when>
				    		<xsl:otherwise>
				    			<para>No deviations in this section.</para>
				    		</xsl:otherwise>
			    		</xsl:choose>
	    			</section>
	    		</xsl:for-each>
	    	</section>
		</article>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()" mode="#all">
	  <xsl:copy>
	    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="#current"/>
	  </xsl:copy>
	</xsl:template>

</xsl:stylesheet>

