<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    >
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />
    
    <!-- This stylesheet tries to build either Sente XML or BibTex from the links provided by the EAP -->
    
    <xsl:template match="html//div[@type='table']">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@type='link']">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vCallNum">
            <xsl:value-of select="substring-before(./a,':')"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vPubTitle">
            <xsl:value-of select="tokenize(substring-after(./a,': '),' ')[1]"/>
        </xsl:variable>
        <xsl:variable name="vYear">
            <xsl:value-of select="tokenize(substring-after(./a,': '),' ')[4]"/>
        </xsl:variable>
        <xsl:variable name="vMonth">
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Jan'">
                <xsl:value-of select="'01'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Feb'">
                <xsl:value-of select="'02'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Mar'">
                <xsl:value-of select="'03'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Apr'">
                <xsl:value-of select="'04'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='May'">
                <xsl:value-of select="'05'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Jun'">
                <xsl:value-of select="'06'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Jul'">
                <xsl:value-of select="'07'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Aug'">
                <xsl:value-of select="'08'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Sep'">
                <xsl:value-of select="'09'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Oct'">
                <xsl:value-of select="'10'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Nov'">
                <xsl:value-of select="'11'"/>
            </xsl:if>
            <xsl:if test="tokenize(substring-after(./a,': '),' ')[3]='Dec'">
                <xsl:value-of select="'12'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="vDay">
            <xsl:value-of select="tokenize(substring-after(./a,': '),' ')[2]"/>
        </xsl:variable>
        
        <xsl:element name="tss:reference">
            <xsl:element name="tss:publicationType">
                <xsl:attribute name="name">Newspaper article</xsl:attribute>
            </xsl:element>
            <xsl:element name="tss:dates">
                <xsl:element name="tss:date">
                    <xsl:attribute name="type">Publication</xsl:attribute>
                    <xsl:attribute name="day">
                        <xsl:value-of select="$vDay"/>
                    </xsl:attribute>
                    <xsl:attribute name="month">
                        <xsl:value-of select="$vMonth"/>
                    </xsl:attribute>
                    <xsl:attribute name="year">
                        <xsl:value-of select="$vYear"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tss:characteristics">
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">publicationTitle</xsl:attribute>
                    <xsl:value-of select="$vPubTitle"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">call-num</xsl:attribute>
                    <xsl:value-of select="$vCallNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">URL</xsl:attribute>
                    <xsl:value-of select="$vURL"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>