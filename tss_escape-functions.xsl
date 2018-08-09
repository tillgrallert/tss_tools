<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:output method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes"/>
    
    <!-- this stylesheet provides the means to escape all XML content of text nodes in Sente XML  in order to be able to (re-) import files into Sente -->
    
    <!-- escape functions -->
    <xsl:template match="node()[not(self::text())]" mode="m_escape">
        <xsl:variable name="v_element-name">
            <!-- strip away all name spaces -->
            <xsl:analyze-string select="name()" regex="^\w+:(\w+)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <!-- single escape for all html:br nodes -->
            <xsl:when test="$v_element-name = 'br'">
                <xsl:value-of select="concat('&lt;',$v_element-name,'&gt;')" disable-output-escaping="no"/>
            </xsl:when>
            <!-- faulty "double" escaping for all other elements -->
            <xsl:otherwise>
                <!-- opening tag -->
                <xsl:value-of select="concat('&amp;lt;',$v_element-name)" disable-output-escaping="no"/>
                <!-- add potential attributes -->
                <xsl:apply-templates select="@*" mode="m_escape"/>
                <!-- check if element is empty -->
                <xsl:choose>
                    <xsl:when test=". = ''">
                        <xsl:value-of select="'/&amp;gt;'" disable-output-escaping="no"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'&amp;gt;'" disable-output-escaping="no"/>
                        <!-- element content -->
                        <xsl:apply-templates mode="m_escape"/>
                        <!-- closing tag -->
                        <xsl:value-of select="concat('&amp;lt;/',$v_element-name,'&amp;gt;')" disable-output-escaping="no"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@*" mode="m_escape">
        <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')" disable-output-escaping="no"/>
    </xsl:template>
    
    <!-- unescape functions -->
    <!-- list of tag names that will be unescaped -->
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
    <xsl:template match="node()" name="t_unescape" mode="m_unescape">
        <xsl:param name="p_input" select="."/>
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
                    <!-- check if tag is allowed -->
                    <xsl:choose>
                        <xsl:when test="$v_allowed-tags/*[local-name()=$v_tag-name]">
                            <xsl:value-of select="$v_tag" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
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
