<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bach="http://www.sitzextase.de"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs"
    version="2.0"> 
    
    <!-- reproduce all nodes that lack a more specific match argument -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:result-document href="{substring-before(base-uri(.),'.')}-unescaped.TSS.xml">
            <xsl:value-of select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../../tss_tools/tss.css&quot;?>'" disable-output-escaping="yes"/>
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <!-- unescape all text() nodes -->
    <xsl:template match="text()" priority="2">
        <xsl:value-of select="bach:funcStringCorrectSenteEscaping(.)" disable-output-escaping="yes"/>
    </xsl:template>
    
    
    <xsl:function name="bach:funcStringCorrectSenteEscaping">
        <xsl:param name="pInput"/>
        <xsl:choose>
            <!-- correct smart quotes -->
            <xsl:when test="contains($pInput,'“')">
                <xsl:value-of select="bach:funcStringCorrectSenteEscaping(replace($pInput,'“','&quot;'))"/>
            </xsl:when>
            <xsl:when test="contains($pInput,'”')">
                <xsl:value-of select="bach:funcStringCorrectSenteEscaping(replace($pInput,'”','&quot;'))"/>
            </xsl:when>
            <!-- correct Sente's unclosed <br> tags -->
            <xsl:when test="contains($pInput,'&lt;br&gt;')">
                <xsl:value-of select="bach:funcStringCorrectSenteEscaping(replace($pInput,'&lt;br&gt;','&lt;br/&gt;'))"/>
            </xsl:when>
            <!-- correct my faulty encoding of unclosed <pb> tags -->
            <xsl:when test="contains($pInput,'&lt;pb&gt;')">
                <xsl:value-of select="bach:funcStringCorrectSenteEscaping(replace($pInput,'&lt;pb&gt;','&lt;pb/&gt;'))"/>
            </xsl:when>
            <!-- correct angled brackets -->
            <xsl:when test="contains($pInput,'&amp;lt;')">
                <xsl:value-of select="bach:funcStringCorrectSenteEscaping(replace($pInput,'&amp;lt;','&lt;'))"/>
            </xsl:when>
            <xsl:when test="contains($pInput,'&amp;gt;')">
                <xsl:value-of  select="bach:funcStringCorrectSenteEscaping(replace($pInput,'&amp;gt;','&gt;'))"/>
            </xsl:when>
            <!-- correct double ampersands -->
            <xsl:when test="contains($pInput,'&amp;amp;')">
                <xsl:value-of  select="bach:funcStringCorrectSenteEscaping(replace($pInput,'&amp;amp;','&amp;'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$pInput"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>