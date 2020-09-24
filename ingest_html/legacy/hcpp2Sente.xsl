<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    >
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <xsl:template match="/">
        <tss:senteContainer version="1.0" xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd">
            <tss:library>
                <tss:references>
        <xsl:apply-templates select="descendant::html:a"/>
                </tss:references>
            </tss:library>
        </tss:senteContainer>
    </xsl:template>
    
    <xsl:template match="html:a">
        <xsl:variable name="v_year-publication">
            <xsl:analyze-string select="@href" regex="d75.(\d{{4}})-">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="v_url" select="substring-before(@href,'?')"/>
        <tss:reference>
            <tss:publicationType name="Archival Book Chapter"/>
            <tss:dates>
                <tss:date type="Publication" year="{$v_year-publication}"/>
            </tss:dates>
            <tss:characteristics>
                <tss:characteristic name="articleTitle"><xsl:text>Report for the year </xsl:text><xsl:value-of select="number($v_year-publication)-1"/><xsl:text> on the trade of XYZ</xsl:text></tss:characteristic>
                <tss:characteristic name="publicationTitle">Diplomatic and Consular Reports on Trade and Finance</tss:characteristic>
                <tss:characteristic name="issue">[C.]</tss:characteristic>
                <tss:characteristic name="publicationCountry">London</tss:characteristic>
                <tss:characteristic name="publisher">Harrison and Sons</tss:characteristic>
                <tss:characteristic name="Short Titel"><xsl:text>Commercial Report XYZ </xsl:text><xsl:value-of select="number($v_year-publication)-1"/></tss:characteristic>
                <tss:characteristic name="Signatur">C.</tss:characteristic>
                <tss:characteristic name="URL">
                    <xsl:value-of select="$v_url"/>
                </tss:characteristic>
                <tss:characteristic name="Repository">HCPP</tss:characteristic>
            </tss:characteristics>
            <tss:keywords>
                <tss:keyword assigner="Sente User Sebastian">Digital copy</tss:keyword>
                <tss:keyword assigner="Sente User Sebastian">official records</tss:keyword>
                <tss:keyword assigner="Sente User Sebastian">statistics</tss:keyword>
                <tss:keyword assigner="Sente User till">British source</tss:keyword>
                <tss:keyword assigner="Sente User till">Economic report</tss:keyword>
                <tss:keyword assigner="Sente User till">Source</tss:keyword>
            </tss:keywords>
        </tss:reference>
    </xsl:template>
</xsl:stylesheet>