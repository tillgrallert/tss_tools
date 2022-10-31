<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs html tei tss"
    version="3.0">
    
    <!-- this stylesheet fixes the URL for material at EAP -->
    
    <xsl:param name="p_debug" select="true()"/>
    
    <!-- https://images.eap.bl.uk/EAP119/EAP119_1_19_4/4.jp2/full/4000,/0/default.jpg -->
    <xsl:variable name="v_iiif-base" select="'https://images.eap.bl.uk/'"/>
    <xsl:variable name="v_iiif-params" select="'4.jp2/full/4000,/0/default.jpg'"/>
    <xsl:variable name="v_url-item" select="'https://eap.bl.uk/archive-file/'"/>
    
    <!-- identify transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:characteristic[@name = 'call-num'][matches(., '^EAP')]">
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>found reference from EAP</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
        <!-- create new URL sibling -->
        <xsl:element name="tss:characteristic">
            <xsl:attribute name="name" select="'URL'"/>
            <xsl:value-of select="concat($v_url-item, replace(replace(., '/', '-'), '^(.*?)\s.+$', '$1'))"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>