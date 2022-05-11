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
    
    <xsl:template match="tss:characteristic[@name= ('articleTitle', 'publicationTitle')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="../tss:characteristic[@name= 'language'] = ('ar', 'ota')">
                    <xsl:choose>
                        <xsl:when test="starts-with(.,'al-')">
                            <xsl:value-of select="concat(substring(.,1,3), tss:capitalise-string(substring(.,4)))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tss:capitalise-string(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="tss:capitalise-string">
        <xsl:param name="p_string"/>
        <xsl:value-of select="concat(upper-case(substring($p_string,1,1)), substring($p_string,2))"/>
    </xsl:function>
</xsl:stylesheet>