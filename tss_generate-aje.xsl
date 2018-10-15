<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:output method="xml" omit-xml-declaration="no" encoding="UTF-8" indent="yes"/>
    
    <!-- this stylesheet splits Sente references using the markdown content of the abstract field as a guideline. Currently this stylesheet deals with journal / diary entries only but it can be easily adapted to any other reference type -->
    
    <xsl:include href="tss_escape-functions.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tss:characteristic[@name = 'abstractText']"
            mode="m_split"/>
    </xsl:template>

    <xsl:template match="tss:characteristic[@name = 'abstractText']" mode="m_split">
        <tss:senteContainer>
            <tss:library>
                <tss:references>
                    <xsl:for-each-group
                        group-starting-with="html:br[matches(following-sibling::node()[1], '##\s+\d')]"
                        select="child::node()">
                        <xsl:variable name="v_entry-content" select="current-group()"/>
                        <!-- get the date from the first line -->
                        <xsl:variable name="v_entry-date">
                            <xsl:analyze-string select="current-group()[2]"
                                regex="(\d{{4}}-\d{{2}}-\d{{2}})">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:variable name="v_entry-first-page"
                            select="current-group()[1]/preceding::tei:pb[1]/@n"/>
                        <xsl:call-template name="t_generate-reference">
                            <xsl:with-param name="p_entry-content" select="$v_entry-content"/>
                            <xsl:with-param name="p_entry-date" select="$v_entry-date"/>
                            <xsl:with-param name="p_entry-first-page" select="$v_entry-first-page"/>
                        </xsl:call-template>
                    </xsl:for-each-group>
                    <!-- escaped content -->
                    <xsl:variable name="v_paragraphs">
                        <xsl:for-each select="tokenize(.,'&lt;br&gt;')">
                            <html:p><xsl:value-of select="."/></html:p>
                        </xsl:for-each>
                    </xsl:variable>
<!--                    <xsl:copy-of select="$v_paragraphs"></xsl:copy-of>-->
                    <xsl:for-each-group select="$v_paragraphs/descendant-or-self::html:p"  group-starting-with="self::html:p[matches(.,'##\s+\d')]">
                        <xsl:variable name="v_entry-content" select="current-group()"/>
                        <!-- get the date from the first line -->
                        <xsl:variable name="v_entry-date">
                            <xsl:analyze-string select="current-group()[1]"
                                regex="(\d{{4}}-\d{{2}}-\d{{2}})">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:call-template name="t_generate-reference">
                            <xsl:with-param name="p_entry-content" select="$v_entry-content"/>
                            <xsl:with-param name="p_entry-date" select="$v_entry-date"/>
                        </xsl:call-template>
                    </xsl:for-each-group>
                </tss:references>
            </tss:library>
        </tss:senteContainer>
    </xsl:template>

    <xsl:template match="node() | @*" mode="m_copy">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_copy"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="t_generate-reference">
        <xsl:param name="p_entry-date"/>
        <xsl:param name="p_entry-content"/>
        <xsl:param name="p_entry-first-page"/>
        <tss:reference>
            <tss:publicationType name="Archival Journal Entry"/>
            <xsl:copy-of select="ancestor::tss:reference/tss:authors"/>
            <!-- dates -->
            <tss:dates>
                <tss:date type="Publication" year="{tokenize($p_entry-date,'-')[1]}" month="{tokenize($p_entry-date,'-')[2]}" day="{tokenize($p_entry-date,'-')[3]}"/>
                <!-- map publication date to original publication date -->
                <tss:date type="Original"
                    year="{ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year}"
                    month="{ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month}"
                    day="{ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day}"/>
                <tss:date type="Entry" day="{ day-from-date( current-date())}"
                    month="{ month-from-date( current-date())}" year="{
                    year-from-date( current-date())}"/>
            </tss:dates>
            <tss:characteristics>
                <xsl:apply-templates
                    select="ancestor::tss:reference/tss:characteristics/tss:characteristic"
                    mode="m_copy"/>
                <tss:characteristic name="abstractText">
<!--                    <xsl:copy-of select="$p_entry-content"/>-->
                    <xsl:apply-templates select="$p_entry-content" mode="m_escape"/>
                </tss:characteristic>
                <tss:characteristic name="pages">
                    <xsl:value-of select="$p_entry-first-page"/>
                </tss:characteristic>
            </tss:characteristics>
            <xsl:copy-of select="ancestor::tss:reference/tss:keywords"/>
            <!-- it wouldn't probably be the worst idea to add a reference to an attached file, even if all new references point to the same file' -->
        </tss:reference>
    </xsl:template>

    <xsl:template match="tss:characteristic[@name = ('abstractText', 'UUID', 'pages','Citation identifier')]"
        mode="m_copy"/>
</xsl:stylesheet>
