<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs html tei tss"
    version="2.0">
    
    <!-- reproduce all nodes that lack a more specific match argument -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:result-document href="{substring-before(base-uri(.),'.')}-correctNs.TSS.xml">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <!-- html -->
    <xsl:template match="tss:br">
        <html:br/>
    </xsl:template>
    <!-- tei -->
    <xsl:template match="tss:characteristic/tss:date">
        <xsl:element name="tei:date">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:measureGrp">
        <xsl:element name="tei:measureGrp">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:measure">
        <xsl:element name="tei:measure">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:pb">
        <xsl:element name="tei:pb">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <!-- tei names -->
    <xsl:template match="tss:persName">
        <xsl:element name="tei:persName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:persName/tss:forename">
        <xsl:element name="tei:forename">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:persName/tss:surname">
        <xsl:element name="tei:surname">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:addName">
        <xsl:element name="tei:addName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:orgName">
        <xsl:element name="tei:orgName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:geogName">
        <xsl:element name="tei:geogName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:placeName">
        <xsl:element name="tei:placeName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <!-- tei diplomatic editions -->
    <xsl:template match="tss:add">
        <xsl:element name="tei:add">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tss:del">
        <xsl:element name="tei:del">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <!-- tei other stuff -->
    <xsl:template match="tss:ref">
        <xsl:element name="tei:ref">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>