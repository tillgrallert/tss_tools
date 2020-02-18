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
    
    <!-- this function checks, if one needs to switch volume and issue information based on a periodical's title.
        There should be an additional check for high issue numbers, let's say above 50, which indicate, that volume and issue need NOT be switched
    
    -->
    <xsl:function name="oape:bibliography-tss-switch-volume-and-issue">
        <xsl:param name="tss_reference"/>
        <xsl:variable name="v_title-short" select=" lower-case($tss_reference/descendant::tss:characteristic[@name = 'Short Titel'])"/>
        <xsl:choose>
            <xsl:when test="$v_title-short = ('ahrām', 'al-ʿaṣr', 'bashīr', 'ḥadīqat', 'iqbāl', 'ittiḥād', 'janna', 'jarīdat al-muqtabas', 'jildirim', 'laṭāʾif', 'lisān', 'quds', 'servet-i fünūn', 'shām', 'suriye', 'thamarāt')">
                <xsl:copy-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="tss:characteristic[@name='volume']">
        <xsl:copy>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="oape:bibliography-tss-switch-volume-and-issue(ancestor::tss:reference) = true()">
                        <xsl:text>issue</xsl:text>
                    </xsl:when>
                    <xsl:when test="oape:bibliography-tss-switch-volume-and-issue(ancestor::tss:reference) = false()">
                        <xsl:text>volume</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <!-- content -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tss:characteristic[@name='issue']">
        <xsl:copy>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="oape:bibliography-tss-switch-volume-and-issue(ancestor::tss:reference) = true()">
                        <xsl:text>volume</xsl:text>
                    </xsl:when>
                    <xsl:when test="oape:bibliography-tss-switch-volume-and-issue(ancestor::tss:reference) = false()">
                        <xsl:text>issue</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <!-- content -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>