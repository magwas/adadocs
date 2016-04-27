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

	<xsl:function name="zenta:all-instances-of-type">
		<xsl:param name="p1"/>
		<xsl:param name="name"/>
		<xsl:copy-of select="$p1//document[@name='../../testmodel.rich']//element[
      				@ancestor=zenta:id-for-name($p1,$name)
      				]"/>
	</xsl:function>
	<xsl:function name="zenta:id-for-name">
		<xsl:param name="docs"/>
		<xsl:param name="name"/>
		<xsl:value-of select="$docs//document[@name='../../testmodel.rich']//element[@name=$name]/@id"/>
	</xsl:function>
	<xsl:function name="zenta:value-by-names">
		<xsl:param name="doc"/>
		<xsl:param name="source"/>
		<xsl:param name="target"/>
		<xsl:copy-of select="$doc//element[@name=$source]/value[@target=//element[@name=$target]/@id]"/>
	</xsl:function>

	<xsl:function name="zenta:connection-by-names">
		<xsl:param name="doc"/>
		<xsl:param name="source"/>
		<xsl:param name="target"/>
		<xsl:copy-of select="$doc//connection[@source=//element[$source]/@id and @target=//element[@name=$target]/@id]"/>
	</xsl:function>

	<xsl:function name="zenta:assertEquals">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:if test="not($result = $expected)">
			<xsl:message>expected:
			<xsl:copy-of select="$expected"/>
			</xsl:message>
			<xsl:message>result:
			<xsl:copy-of select="$result"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy-of select='$result = $expected'/>
	</xsl:function>

	<xsl:function name="zenta:doesContain">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:variable name="have">
			<xsl:for-each select="$result">
				<xsl:if test="contains(.,$expected)">
					<have got="true"/>
				</xsl:if>
					<have got="foo"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="$have//@got='true'"/>
	</xsl:function>

	<xsl:function name="zenta:assertContains">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:if test="not(zenta:doesContain($expected,$result))">
			<xsl:message>expected:
			<xsl:copy-of select="$expected"/>
			</xsl:message>
			<xsl:message>result:
			<xsl:copy-of select="$result"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy-of select="zenta:doesContain($expected,$result)"/>
	</xsl:function>

	<xsl:function name="zenta:assertNotContains">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:if test="zenta:doesContain($expected,$result)">
			<xsl:message>not expected:
			<xsl:copy-of select="$expected"/>
			</xsl:message>
			<xsl:message>result:
			<xsl:copy-of select="$result"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy-of select="not(zenta:doesContain($expected,$result))"/>
	</xsl:function>

	<xsl:function name="zenta:assertSequenceEquals">
		<xsl:param name="expected"/>
		<xsl:param name="result"/>
		<xsl:variable name="resultSequence" select="zenta:toStringSequence($result,',')"/>
		<xsl:variable name="expectedSequence" select="zenta:toStringSequence($expected,',')"/>
		<xsl:if test="not($resultSequence = $expectedSequence)">
			<xsl:message>
				expected:
				<xsl:value-of select="$expectedSequence"/>
				result:
				<xsl:value-of select="$resultSequence"/>
			</xsl:message>
		</xsl:if>
		<xsl:copy-of select="
      		 	$resultSequence
      		=
      			$expectedSequence
		"/>
	</xsl:function>

	<xsl:function name="zenta:toStringSequence">
		<xsl:param name="input"/>
		<xsl:param name="delimiter"/>
		<xsl:variable name="sorted">
			<xsl:for-each select="$input">
				<xsl:sort select="."/>
				<a><xsl:copy-of select="string(.)"/></a>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="
				string-join($sorted//a,$delimiter)
		"/>
	</xsl:function>

	<xsl:function name="zenta:occursNumber">
		<xsl:param name="theString"/>
		<xsl:choose>
			<xsl:when test="empty($theString)">0</xsl:when>
			<xsl:when test="$theString=''">0</xsl:when>
			<xsl:otherwise><xsl:value-of select="number($theString)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:descendantRelationsFor">
		<xsl:param name="relation"/>
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:variable name="descendants" select="$doc//connection[
			@ancestor=$relation/@id and
			@template='true' and
			@direction=$relation/@direction
			]"/>
		<xsl:copy-of select="$doc//connection[
			@ancestor=$relation/@id and
			@template='false' and
			@direction=$relation/@direction and
			@source=$element/@id
			]"/>
		<xsl:for-each select="$descendants">
			<xsl:copy-of select="zenta:descendantRelationsFor(.,$element,$doc)"/>
		</xsl:for-each>
	</xsl:function>
	

	<xsl:function name="zenta:checkRelationCount">
		<xsl:param name="element"/>
		<xsl:param name="template"/>
		<xsl:param name="doc"/>
		<xsl:variable name="descendants" select="zenta:descendantRelationsFor($template,$element,$doc)"/>
		<xsl:if test="
			count($descendants)
			&lt;
			zenta:occursNumber(string($template/@minOccurs))
		">
			<error type="less than minOccurs values" element="{$element/@id}">
				<xsl:copy-of select="$template/@id|$template/@name|$template/@minOccurs|$template/@source|$template/@target"/>
				<xsl:attribute name="errorID" select="concat('minOccurs_',$element/@id,'_',$template/@id)"/>
			</error>
		</xsl:if>
		<xsl:if test="
			(zenta:occursNumber(string($template/@maxOccurs)) !=0) and
				(count($descendants)
				&gt;
				zenta:occursNumber(string($template/@maxOccurs)))
		">
			<error type="more than maxOccurs values" element="{$element/@id}">
				<xsl:copy-of select="$template/@id|$template/@name|$template/@maxOccurs|$template/@source|$template/@target"/>
				<xsl:attribute name="errorID" select="concat('maxOccurs_',$element/@id,'_',$template/@id)"/>
			</error>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getMinOccurs">
		<xsl:param name="doc"/>
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element/property[@key='minOccurs']">
				<xsl:copy-of select="$element/property[@key='minOccurs']/@value"/>
			</xsl:when>
			<xsl:when test="$doc//element[@id=$element/@ancestor]">
				<xsl:copy-of select="zenta:getMinOccurs($doc,$doc//element[@id=$element/@ancestor])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="'0'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:getMaxOccurs">
		<xsl:param name="doc"/>
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element/property[@key='maxOccurs']">
				<xsl:copy-of select="$element/property[@key='maxOccurs']/@value"/>
			</xsl:when>
			<xsl:when test="$doc//element[@id=$element/@ancestor]">
				<xsl:copy-of select="zenta:getMaxOccurs($doc,$doc//element[@id=$element/@ancestor])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="'0'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="zenta:buildConnection">
		<xsl:param name="element"/>
		<xsl:param name="direction"/>
		<xsl:param name="doc"/>
			<xsl:variable name="mO" select="zenta:getMinOccurs($doc,$element)"/>
			<xsl:variable name="xO" select="zenta:getMaxOccurs($doc,$element)"/>
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
				<xsl:attribute name="minOccurs" select="zenta:occursNumber(tokenize($mO,'/')[$direction])"/>
				<xsl:attribute name="maxOccurs" select="zenta:occursNumber(tokenize($xO,'/')[$direction])"/>
				<xsl:attribute name="template" select="$doc//element[property/@key='Template']//sourceConnection/@relationship=$element/@id"/>
				<xsl:attribute name="relationName" select="$element/@name"/>
				<xsl:attribute name="ancestorName" select="$doc//element[@id=$element/@ancestor]/@name"/>
				<xsl:copy-of select="$element/@ancestor|$element/@id|$element/@name|$element/documentation"/>
			</connection>
	</xsl:function>

	<xsl:function name="zenta:getAncestry">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:if test="$element">
			<xsl:copy-of select="zenta:getAncestry($doc//element[@id=$element/@ancestor],$doc)"/>
			<xsl:copy-of select="$element"/>
		</xsl:if>
	</xsl:function>

	<xsl:function name="zenta:getDefiningRelations">
		<xsl:param name="element"/>
		<xsl:param name="doc"/>
		<xsl:for-each select="zenta:getAncestry($element,$doc)">
			<xsl:copy-of select="$doc//connection[@source=current()/@ancestor]"/>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="zenta:isVovel">
		<xsl:param name="str"/>
		<xsl:copy-of select="contains('aeouiAEOUI',$str)"/>
	</xsl:function>
	
	<xsl:function name="zenta:articledName">
		<xsl:param name="element"/>
		<xsl:param name="definite"/>
			<xsl:choose>
				<xsl:when test="$element/@template='true' or $definite='no'">
					<xsl:choose>
						<xsl:when test="zenta:isVovel(substring($element/@name,1,1))">
							<xsl:value-of select="concat('an ',$element/@name)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('a ',$element/@name)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$element/@name"/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:function>
	
	<xsl:function name="zenta:capitalize">
		<xsl:param name="str"/>
		<xsl:value-of select="concat(upper-case(substring($str,1,1)),substring($str, 2))"/>
	</xsl:function>
	
	<xsl:function name="zenta:passive">
		<xsl:param name="str"/>
		<xsl:value-of select="
			if (zenta:isVovel(substring($str,string-length($str)-1,1)))
			then
				concat('is ',substring($str,1,string-length($str)-1),'d by')
			else
				concat('is ',substring($str,1,string-length($str)-1),'ed by')
			"/>
	</xsl:function>
	
</xsl:stylesheet>