<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bach="http://www.sitzextase.de/ns"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs"
    version="3.0"> 
    
    <xsl:param name="p_debug" select="true()"/>
    
    <!-- identity transform-->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- start on root -->
    <xsl:template match="/">
        <!-- output file name and path is set through oXygen project transformation -->
<!--        <xsl:result-document href="{substring-before(base-uri(.),'.')}-unescaped.TSS.xml">-->
            <xsl:value-of select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../../tss_tools/tss.css&quot;?>'" disable-output-escaping="yes"/>
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        <!--</xsl:result-document>-->
    </xsl:template>
    
    <!-- unescape all text() nodes -->
    <!-- PROBLEM: ampersand (&amp;) and individual &lt; should always be escaped because otherwise they will invalidate  the XML output -->
    <!-- do not unescape tss:title/text() -->
    <xsl:template match="tss:characteristic[@name='abstractText']//text() | tss:comment/text() | tss:quotation/text()">
        <xsl:variable name="v_preprocessed">
            <xsl:apply-templates select="." mode="m_preprocessing"/>
        </xsl:variable>
<!--        <xsl:value-of select="$v_preprocessed"/>-->
        <xsl:call-template name="t_unescape">
            <xsl:with-param name="p_input" select="$v_preprocessed"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="text()" mode="m_preprocessing">
        <xsl:value-of select="bach:string-correct-escaping(.)" disable-output-escaping="no"/>
    </xsl:template>
    
    <!-- preprocess function -->
    <xsl:function name="bach:string-correct-escaping">
        <xsl:param name="p_input" as="xs:string"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>Running `bach:string-correct-escapting()` on </xsl:text><xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <xsl:choose>
            <!-- strip-out potentially erroneous <add> tags (at some point Sente failed to recognise the opening tag <add> but accepted the closing </add>) -->
            <xsl:when test="contains($p_input,'&amp;lt;/add&amp;gt;')">
                <xsl:value-of  select="bach:string-correct-escaping(replace($p_input,'&amp;lt;/add&amp;gt;',' '))"/>
            </xsl:when>
            <xsl:when test="contains($p_input,'&amp;lt;add&amp;gt;')">
                <xsl:value-of  select="bach:string-correct-escaping(replace($p_input,'&amp;lt;add&amp;gt;',' '))"/>
            </xsl:when>
            <!-- correct smart quotes -->
            <xsl:when test="contains($p_input,'“')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'“','&quot;'))"/>
            </xsl:when>
            <xsl:when test="contains($p_input,'”')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'”','&quot;'))"/>
            </xsl:when>
            <!-- correct quotes -->
            <!--<xsl:when test="contains($p_input,'''')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'''','&quot;'))"/>
            </xsl:when>-->
            <!-- correct Sente's unclosed <br> tags -->
            <xsl:when test="contains($p_input,'&lt;br&gt;')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'&lt;br&gt;','&lt;br/&gt;'))"/>
            </xsl:when>
            <!-- correct my faulty encoding of unclosed <pb> tags -->
            <xsl:when test="contains($p_input,'&lt;pb&gt;')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'&lt;pb&gt;','&lt;pb/&gt;'))"/>
            </xsl:when>
            <!-- correct angled brackets -->
            <xsl:when test="contains($p_input,'&amp;lt;')">
                <xsl:value-of select="bach:string-correct-escaping(replace($p_input,'&amp;lt;','&lt;'))"/>
            </xsl:when>
            <xsl:when test="contains($p_input,'&amp;gt;')">
                <xsl:value-of  select="bach:string-correct-escaping(replace($p_input,'&amp;gt;','&gt;'))"/>
            </xsl:when>
            <!-- correct double ampersands -->
            <xsl:when test="contains($p_input,'&amp;amp;')">
                <xsl:value-of  select="bach:string-correct-escaping(replace($p_input,'&amp;amp;','&amp;'))"/>
            </xsl:when>
            <!-- correct quotation marks -->
            <xsl:when test="contains($p_input,'&amp;quot;')">
                <xsl:value-of  select="bach:string-correct-escaping(replace($p_input,'&amp;quot;','&quot;'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$p_input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="v_allowed-tags">
        <!-- HTML -->
        <br/>
        <i/>
        <u/>
        <b/>
        <!-- TEI -->
        <!-- structural information -->
        <pb/>
        <cb/>
        <lb/>
        <!-- editorial changes -->
        <!-- since at some point Sente failed to recognise the opening tag <add> but accepted the closing </add> all <add> tags must be left unescaped in order to avoid potentially erroneous tags -->
<!--        <add/>-->
        <del/>
        <note/>
        <ref/>
        <!-- named entities -->
        <name/>
        <persName/>
        <forename/>
        <surname/>
        <addName/>
        <roleName/>
        <geogName/>
        <orgName/>
        <placeName/>
        <!-- measures, dates -->
        <measureGrp/>
        <measure/>
        <date/>
        <!-- bibliographic information -->
        <title/>
        <!-- custom, faulty mark-up -->
        <price/>
    </xsl:variable>
    
    <xsl:template name="t_unescape">
        <xsl:param name="p_input" as="xs:string"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>Running `bach:string-unescape()` on </xsl:text><xsl:value-of select="$p_input"/>
            </xsl:message>
        </xsl:if>
        <!-- plan: tokenize at < -->
        <xsl:for-each select="tokenize($p_input,'&lt;')">
            <xsl:variable name="v_string-self" select="."/>
            <xsl:variable name="v_tag-full" select="substring-before(.,'&gt;')"/>
            <xsl:variable name="v_tag-parts" select="tokenize($v_tag-full,'[\s|\n]')"/>
            <xsl:variable name="v_tag-name">
                <xsl:choose>
                    <xsl:when test="starts-with($v_tag-parts[1],'/')">
                        <xsl:value-of select="substring-after($v_tag-parts[1],'/')"/>
                    </xsl:when>
                    <!-- take self-closing tags into account  -->
                    <xsl:when test="ends-with($v_tag-parts[1],'/')">
                        <xsl:value-of select="substring-before($v_tag-parts[1],'/')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$v_tag-parts[1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_string-after-tag" select="substring-after(.,'&gt;')"/>
            <!-- build output -->
            <!-- check if a tag is present -->
            <xsl:choose>
                <!-- the tag will always be at the beginning of the string -->
                <xsl:when test="$v_tag-name!=''">
                    <xsl:variable name="v_tag" select="concat('&lt;',$v_tag-full,'&gt;')"/>
                    <xsl:if test="$p_debug = true()">
                        <xsl:message>
                            <xsl:text>Found tag "</xsl:text><xsl:value-of select="$v_tag-full"/><xsl:text>"</xsl:text>
                        </xsl:message>
                    </xsl:if>
                    <!-- check if tag is allowed -->
                    <xsl:choose>
                        <xsl:when test="$v_allowed-tags/*[local-name()=$v_tag-name]">
                            <xsl:if test="$p_debug = true()">
                                <xsl:message>
                                    <xsl:text>This tag will be unescaped</xsl:text>
                                </xsl:message>
                            </xsl:if>
                            <xsl:value-of select="$v_tag" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$p_debug = true()">
                                <xsl:message>
                                    <xsl:text>This tag will will remain escaped</xsl:text>
                                </xsl:message>
                            </xsl:if>
                            <xsl:value-of select="$v_tag" disable-output-escaping="no"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="$v_string-after-tag"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$v_string-self"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>