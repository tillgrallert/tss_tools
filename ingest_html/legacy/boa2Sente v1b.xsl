<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    >
    <xsl:output method="xml" version="1.0" xpath-default-namespace="http://www.thirdstreetsoftware.com/SenteXML-1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"  name="xml"/>
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"  name="text"/>
    
    <!-- This stylesheet builds Sente XML from the result pages returned by the BOA catalgue -->
    <!-- v1b: input changed to a simple text string produced by copy and paste from the website, as the code returned by the catalogue is too buggy to be quickly cleaned up. Each result page is copied into a <div/> of a html file. Each entry for a file, beginning with "Tarih: " is converted into a <p/> -->
    <!-- v1a:
       - implemented a transformation of BOA's abbreviations of Hijrī dates to IJMES-based ones using the BachFunctions
       - transformation of Hijrī dates to Gregorian dates implemented with BachFunctions -->
    
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. I used the unique call-numbers for this purpose -->
    
    <!-- provides various date functions and citations -->
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/> 
    
    <xsl:variable name="vgDate" select="current-date()"/>
    
    
    <xsl:template match="html:html">
        <xsl:apply-templates mode="m4"/> <!--select m4 or m5 -->
    </xsl:template>
    
    <xsl:template match="html:body" mode="m4">
        <xsl:result-document href="boa2Sente {format-date($vgDate,'[Y01][M01][D01]')}.xml" method="xml">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation">http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates mode="m4"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:p" mode="m4">
            <xsl:variable name="vFile" select="."/>
            
            <xsl:variable name="vDate">
                <xsl:analyze-string select="$vFile" regex="\s*Tarih:\s+(.*)\s+Dosya">
                    <xsl:matching-substring>
                        <xsl:variable name="vDateG">
                            <xsl:call-template name="funcDateBoa">
                                <xsl:with-param name="pDateString" select="regex-group(1)"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="$vDateG"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
        <xsl:variable name="vCal">
            <xsl:analyze-string select="$vFile" regex="\s*Tarih:\s+(.*)\s+Dosya">
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="contains(regex-group(1),'(Miladî)')">
                            <xsl:text>g</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(regex-group(1),'(Hicrî)')">
                            <xsl:text>h</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>m</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
            
            <xsl:variable name="vBoaID">
                <xsl:variable name="vFK">
                    <xsl:analyze-string select="$vFile" regex="Fon Kodu:\s*(.*)\s*\n">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:variable name="vD">
                    <xsl:analyze-string select="$vFile" regex="Dosya No:\s*(.*)\s+Gömlek">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:variable name="vG">
                    <xsl:analyze-string select="$vFile" regex="Gömlek No:\s*(.*)\s+Fon">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:value-of select="concat($vFK,' ',$vD,'/',$vG)"/>
            </xsl:variable>
            
            <xsl:variable name="vAbstract">
                <!--<xsl:analyze-string select="$vFile" regex="Kodu:.*\n\s*(.*)">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>-->
                <xsl:value-of select="normalize-space($vFile/html:br/following-sibling::text())"/>
            </xsl:variable>
            <xsl:variable name="vPubTitle">
                <xsl:value-of select="substring($vAbstract,1,20)"/>
                <xsl:value-of select="' ...'"/>
            </xsl:variable>
          
            <xsl:element name="tss:reference">
                <xsl:element name="tss:publicationType">
                    <xsl:attribute name="name">Archival File</xsl:attribute>
                </xsl:element>
                <xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Retrieval</xsl:attribute>
                        <xsl:attribute name="day">
                            <xsl:value-of select="format-date($vgDate,'[D01]')"/>
                        </xsl:attribute>
                        <xsl:attribute name="month">
                            <xsl:value-of select="format-date($vgDate,'[M01]')"/>
                        </xsl:attribute>
                        <xsl:attribute name="year">
                            <xsl:value-of select="format-date($vgDate,'[Y0001]')"/>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:if test="$vDate!=''">
                        <xsl:element name="tss:date">
                            <xsl:attribute name="type">Publication</xsl:attribute>
                            <xsl:attribute name="day">
                                <xsl:value-of select="tokenize(normalize-space($vDate),'-')[3]"/>
                            </xsl:attribute>
                            <xsl:attribute name="month">
                                <xsl:value-of select="tokenize(normalize-space($vDate),'-')[2]"/>
                            </xsl:attribute>
                            <xsl:attribute name="year">
                                <xsl:value-of select="tokenize(normalize-space($vDate),'-')[1]"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="tss:characteristics">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">articleTitle</xsl:attribute>
                        <xsl:value-of select="$vBoaID"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationTitle</xsl:attribute>
                        <xsl:value-of select="concat('BOA ',$vBoaID,' ',$vPubTitle)"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">abstractText</xsl:attribute>
                        <xsl:value-of select="$vAbstract"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Signatur</xsl:attribute>
                        <xsl:value-of select="$vBoaID"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Repository</xsl:attribute>
                        <xsl:value-of select="'BOA'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">language</xsl:attribute>
                        <xsl:value-of select="'Ottoman Turkish'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Web data source</xsl:attribute>
                        <xsl:text>devletarsivleri.gov.tr</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                       <xsl:if test="$vCal='h'">
                           <xsl:attribute name="name">Date Hijri</xsl:attribute>
                           <xsl:variable name="vDateH">
                               <xsl:call-template name="funcDateG2H">
                                   <xsl:with-param name="pDateG" select="$vDate"/>
                               </xsl:call-template>
                           </xsl:variable>
                           <xsl:value-of select="format-number(number(tokenize($vDateH,'-')[3]),'0')"/>
                           <xsl:text> </xsl:text>
                           <xsl:call-template name="funcDateMonthNameNumber">
                               <xsl:with-param name="pDate" select="$vDateH"/>
                               <xsl:with-param name="pMode" select="'name'"/>
                               <xsl:with-param name="pLang" select="'HIjmes'"/>
                           </xsl:call-template>
                           <xsl:text> </xsl:text>
                           <xsl:value-of select="tokenize($vDateH,'-')[1]"/>
                       </xsl:if>
                        <xsl:if test="$vCal='m'">
                            <xsl:attribute name="name">Date Rumi</xsl:attribute>
                            <xsl:variable name="vDateM">
                                <xsl:call-template name="funcDateG2M">
                                    <xsl:with-param name="pDateG" select="$vDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:value-of select="format-number(number(tokenize($vDateM,'-')[3]),'0')"/>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pDate" select="$vDateM"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                                <xsl:with-param name="pLang" select="'MIjmes'"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="tokenize($vDateM,'-')[1]"/>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:keywords">
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Damascus</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Ottoman source</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>official records</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Source</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
    </xsl:template>
  
</xsl:stylesheet>