<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <xsl:include href="/BachUni/programming/XML/Functions/BachFunctions%20v3.xsl"/>
    
    <!-- this stylesheet unites two or more Sente XML files and matches the references through their UUID. At the moment it is used to provide both jpg and pdf attachments -->
    
    <!-- this parameter provides a secondary Sente XML with additional information. References are matched through their UUID -->
<!--    <xsl:param name="pgAddInfo" select="document('/BachUni/projekte/Damascus/sources damascus/al-muqtabas daily/eap119.xml')"/>-->
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add Hijri and Rumi dates -->
    <xsl:template match="tss:characteristics">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="not(child::tss:characteristic[@name='Date Hijri'])">
                <xsl:variable name="vDateG">
                    <xsl:value-of select="concat(ancestor::tss:reference//tss:date[@type='Publication']/@year,'-',ancestor::tss:reference//tss:date[@type='Publication']/@month,'-',ancestor::tss:reference//tss:date[@type='Publication']/@day)"/>
                </xsl:variable>
                <xsl:variable name="vDateH">
                    <xsl:call-template name="funcDateG2H">
                        <xsl:with-param name="pDateG" select="$vDateG"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Date Hijri</xsl:attribute>
                    <xsl:value-of select="format-number(number(tokenize($vDateH,'-')[3]),'0')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="funcDateMonthNameNumber">
                        <xsl:with-param name="pMonth" select="number(tokenize($vDateH,'-')[2])"/>
                        <xsl:with-param name="pLang" select="'hijmes'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="number(tokenize($vDateH,'-')[1])"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="not(child::tss:characteristic[@name='Date Rumi'])">
                <xsl:variable name="vDateG">
                    <xsl:value-of select="concat(ancestor::tss:reference//tss:date[@type='Publication']/@year,'-',ancestor::tss:reference//tss:date[@type='Publication']/@month,'-',ancestor::tss:reference//tss:date[@type='Publication']/@day)"/>
                </xsl:variable>
                <xsl:variable name="vDateJ">
                    <xsl:call-template name="funcDateG2J">
                        <xsl:with-param name="pDateG" select="$vDateG"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Date Rumi</xsl:attribute>
                    <xsl:value-of select="format-number(number(tokenize($vDateJ,'-')[3]),'0')"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="funcDateMonthNameNumber">
                        <xsl:with-param name="pMonth" select="number(tokenize($vDateJ,'-')[2])"/>
                        <xsl:with-param name="pLang" select="'jijmes'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="number(tokenize($vDateJ,'-')[1])"/>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:characteristic | tss:keywords | tss:notes">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="tss:attachments">
        <xsl:variable name="vUUID" select="ancestor::tss:reference//tss:characteristic[@name='UUID']"/>
        <xsl:element name="tss:attachments">
            <xsl:for-each select="$pgAddInfo//tss:reference[.//tss:characteristic[@name='UUID']=$vUUID]//tss:attachmentReference">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>-->
    <xsl:template match="tss:attachmentReference">
        <xsl:if test="ends-with(./URL,'.pdf')">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>