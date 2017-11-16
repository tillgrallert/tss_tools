<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- this template takes dates from Sente XML as input (e.g. <tss:date type="Entry" day="7" month="8" year="2008"/>) and returns a single ISO-conformant string -->
    <xsl:template name="funcSenteNormalizeDate">
        <!-- input is a <tss:date> element -->
        <xsl:param name="pInput"/>
        <xsl:variable name="vDateY" select="number(@year)"/>
        <xsl:variable name="vDateM" select="if(@month='') then(1) else(@month)"/>
        <xsl:variable name="vDateD" select="if(@day='') then(1) else(@day)"/>
        <xsl:value-of select="concat($vDateY,'-',format-number(number($vDateM),'00'),'-',format-number(number($vDateD),'00'))"/>
    </xsl:template>

    <!-- this template takes a <tss:reference> as input and generates a reference in TEI: <tei:ref type="SenteCitation" target="some-citation-id"><tei:bibl>The formatted reference</tei:bibl></tei:ref> -->
    <xsl:template name="funcSente2TeiBibl">
        <!-- input is a <tss:reference> element -->
        <xsl:param name="pInput"/>
                <xsl:element name="tei:ref">
                    <xsl:attribute name="type" select="'SenteCitationID'"/>
                    <xsl:attribute name="target" select="$pInput//tss:characteristic[@name='Citation identifier']"/>
                    <xsl:element name="tei:bibl">
                    	<xsl:call-template name="funcCitation">
                        <xsl:with-param name="pRef" select="$pInput"/>
                        <xsl:with-param name="pMode" select="'fn'"/>
                        <xsl:with-param name="pOutputFormat" select="'mmd'"/>
                    </xsl:call-template>
                </xsl:element>
                </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>