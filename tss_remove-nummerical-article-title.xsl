<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs html tei tss"
    version="3.0">
    
    <!-- reproduce all nodes that lack a more specific match argument -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove article titles which are solely nummerical and which were exclusively generated automatically -->
    <xsl:template match="tss:characteristic[@name='articleTitle'][matches(.,'^\d+$')]">
        <xsl:copy>
            <xsl:apply-templates select="@* "/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>