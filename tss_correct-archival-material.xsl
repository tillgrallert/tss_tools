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
    
    <!-- this stylesheet fixes archival material by removing citations from the title -->
    <!-- it also fixes purely numerical article titles for periodicals -->
    <!-- to do: write all additional information helping to locate stuff in archives to the call-num -->
    
    
    <!-- identify transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
  
    
    <!-- fix titles of archival files -->
    <xsl:template match="tss:characteristic[@name='publicationTitle'][contains(ancestor::tss:reference/tss:publicationType/@name, 'Archival File')]">
        <!-- need to test if title is only an automatically formatted reference: indicator is the presence of the call number -->
        <!-- get the call-number -->
        <xsl:variable name="v_call-num">
            <xsl:choose>
                <xsl:when test="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name = 'Signatur'] != ''">
                    <xsl:value-of select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name = 'Signatur']"/>
                </xsl:when>
                <xsl:when test="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name = 'call-num'] != ''">
                    <xsl:value-of select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name = 'call-num']"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- remove call-number -->
        <xsl:variable name="v_title-temp" select="if($v_call-num != '') then(replace(., $v_call-num, '')) else(.)"/>
        <!-- get the name of the archive -->
        <xsl:variable name="v_archive" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name = 'Repository']"/>
        <!-- remove archive name -->
        <xsl:variable name="v_title-temp" select="if($v_archive != '') then(replace($v_title-temp, $v_archive, '')) else($v_title-temp)"/>
        <!-- last step: strip out leading non-word characters -->
        <xsl:variable name="v_title-temp">
            <xsl:analyze-string select="$v_title-temp" regex="^\W+(.+?)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="$v_title-temp"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <!-- debugging messages -->
        <!--<xsl:message>
            <xsl:value-of select="."/>
        </xsl:message>
        <xsl:message>
            <xsl:value-of select="$v_title-temp"/>
        </xsl:message>-->
        <!-- reconstruct node -->
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="$v_title-temp"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:reference[contains(tss:publicationType/@name, 'Archival')]">
        <xsl:variable name="v_type" select="tss:publicationType/@name"/>
        <xsl:variable name="v_date" select="descendant::tss:date[@type = 'Publication']"/>
        <xsl:variable name="v_year">
            <xsl:value-of select="$v_date/@year"/>
        </xsl:variable>
        <!--<xsl:message>
            <xsl:value-of select="$v_year"/>
        </xsl:message>-->
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tss:publicationType"/>
            <xsl:apply-templates select="tss:authors"/>
            <xsl:apply-templates select="tss:dates"/>
            <xsl:copy select="tss:characteristics">
                <xsl:apply-templates/>
                <!-- add a new article title for diary/ journal entries -->
                <xsl:if test="not(descendant::tss:characteristic[@name = 'articleTitle']) and contains($v_type, 'Entry')">
                    <!--<xsl:message terminate="no">
                        <xsl:value-of select="tss:publicationType/@name"/>
                        <xsl:value-of select="$v_type"/>
                    </xsl:message>-->
                    <xsl:variable name="v_date-of-entry">
                        <xsl:choose>
                            <xsl:when test="$v_date[@year][@month][@day]">
                                <xsl:value-of select="concat( format-number($v_date/@year, '0000'), '-', format-number($v_date/@month, '00'), '-', format-number($v_date/@day, '00'))"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name" select="'articleTitle'"/>
                        <xsl:text>[Entry of </xsl:text>
                        <!-- date: -->
                        <xsl:if test="matches($v_date-of-entry, '\d{4}-\d{2}-\d{2}')">
                            <!--<xsl:message>
                                <xsl:text>is ISO date</xsl:text>
                            </xsl:message>-->
                            <xsl:value-of select="format-date(xs:date($v_date-of-entry), '[D1] [MNn] [Y0001]')"/>
                        </xsl:if>
                        <xsl:text>]</xsl:text>
                    </xsl:element>
                </xsl:if>
                <!-- add new call-number -->
                <xsl:if test="not(descendant::tss:characteristic[@name = 'call-num']) and descendant::tss:characteristic[@name = ('Code', 'Item', 'File')]">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name" select="'call-num'"/>
                        <xsl:value-of select="descendant::tss:characteristic[@name = 'Code']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:if test="descendant::tss:characteristic[@name = 'Item']">
                            <xsl:value-of select="descendant::tss:characteristic[@name = 'Item']"/>
                            <xsl:text>/</xsl:text>
                        </xsl:if>
                        <xsl:if test="descendant::tss:characteristic[@name = 'File']">
                            <xsl:text>F.</xsl:text>
                            <xsl:value-of select="descendant::tss:characteristic[@name = 'File']"/>
                            <xsl:text>/</xsl:text>
                        </xsl:if>
                        <!-- this is still not working -->
                        <xsl:value-of select="replace($v_year,'\d+(\d{2})', '$1')"/>
                    </xsl:element>
                </xsl:if>
            </xsl:copy>
            <xsl:apply-templates select="tss:keywords"/>
            <xsl:apply-templates select="tss:notes"/>
            <xsl:apply-templates select="tss:attachments"/>
        </xsl:copy>
    </xsl:template>
    
    <!--  - a lot of periodical references have a purely numerical title, which needs to be removed in POSTPROCESSING the TSS XML -->
    <xsl:template match="tss:characteristic[@name='articleTitle'][ancestor::tss:reference/tss:publicationType/@name = ('Archival Periodical')][matches(.,'^\s*\d+\s*$')]">
        <!-- debugging messages -->
        <!--<xsl:message>
            <xsl:value-of select="."/>
            <xsl:text> is purely nummerical</xsl:text>
        </xsl:message>-->
    </xsl:template>
    <!-- archival journal entries often have no proper entry title -->
    
    <!-- fix reference types for bills: this is particularly relevant if the target format is Zotero -->
    <xsl:template match="tss:reference[tss:publicationType/@name = 'Bill']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tss:publicationType">
                <xsl:attribute name="name">
                    <!-- select reference type depending on other information -->
                    <xsl:choose>
                        <xsl:when test="descendant::tss:keyword = 'newspaper/periodical'">
                            <xsl:text>Newspaper article</xsl:text>
                        </xsl:when>
                        <xsl:when test="descendant::tss:characteristic[@name = 'publisher']">
                            <xsl:text>Book Chapter</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Bill</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
            <!-- reproduce content -->
            <xsl:apply-templates select="tss:authors | tss:dates | tss:characteristics"/>
            <xsl:copy select="tss:keywords">
                <xsl:apply-templates select="descendant::tss:keyword"/>
                <xsl:element name="tss:keyword">
                    <xsl:text>reference-type_bill</xsl:text>
                </xsl:element>
            </xsl:copy>
            <xsl:apply-templates select="tss:notes | tss:attachments"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:characteristic[@name='Short Titel']">
        <xsl:copy>
            <xsl:choose>
                <!-- For bills, I commonly recorded a short version of the container title in this field  -->
                <xsl:when test="ancestor::tss:reference/tss:publicationType/@name = 'Bill'"/>
                <xsl:otherwise>
                    <xsl:attribute name="name" select="'Shortened title'"/>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>