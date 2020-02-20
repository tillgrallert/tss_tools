<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- indentiy transformation -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tss:reference"/>
    </xsl:template>
    
    <xsl:template match="tss:reference">
        <!-- output file name and path is set through oXygen project transformation -->
        <xsl:result-document href="_output/{descendant::tss:characteristic[@name='UUID']}.TSS.xml">
        <xsl:value-of select="'&lt;?xml-stylesheet type=&quot;text/css&quot; href=&quot;../../tss_tools/tss.css&quot;?>'" disable-output-escaping="yes"/>
            <tss:senteContainer version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0" >
                <tss:library>
                    <tss:references>
                        <xsl:copy>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </tss:references>
                </tss:library>
            </tss:senteContainer>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>