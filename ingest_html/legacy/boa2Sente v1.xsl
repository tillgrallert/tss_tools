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
    
    <!-- This stylesheet builds Sente XML and an applescript from the result pages returned by the BOA catalgue -->
   
    
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. I used the unique call-numbers for this purpose -->
    <!-- provides replacement functions and citations -->
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v2.xsl"/> 
    
    <xsl:variable name="vgDate" select="current-date()"/>
    
    
    <xsl:template match="html">
        <xsl:apply-templates mode="m4"/> <!--select m4 or m5 -->
    </xsl:template>
   
    <xsl:template match="body" mode="m5">
       <xsl:call-template name="funcDateH2G">
           <xsl:with-param name="pDateH" select="'1330-10-12'"/>
       </xsl:call-template>
   </xsl:template>
    
    <xsl:template match="body" mode="m4">
        <xsl:result-document href="boa2Sente {format-date($vgDate,'[Y01][M01][D01]')}.xml" method="xml">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:attribute name="xsi:schemaLocation">http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:call-template name="templReferencesM4"/><!-- this is the line to trigger m1, m3, m4 -->
                </xsl:element>
            </xsl:element>
        </xsl:element>
        </xsl:result-document>
    </xsl:template>
     
    <xsl:template name="templReferencesM4">
        <xsl:for-each select="table[@class='pencere']/tr">
            
            <xsl:variable name="vBoaID">
                <xsl:value-of select="substring-after(.//table/tr[1]/td[4],'Fon Kodu: ')"/>
                <xsl:value-of select="' '"/>
                <xsl:value-of select="substring-after(.//table/tr[1]/td[2],'Dosya No:')"/>
                <xsl:value-of select="'/'"/>
                <xsl:value-of select="substring-after(.//table/tr[1]/td[3],'Gömlek No:')"/>
            </xsl:variable>
            
            <xsl:variable name="vAbstract">
                <xsl:value-of select=".//table/tr[2]/td"/>
            </xsl:variable>
            <xsl:variable name="vPubTitle">
                <xsl:value-of select="substring($vAbstract,1,20)"/>
                <xsl:value-of select="' ...'"/>
            </xsl:variable>
            <xsl:variable name="vBoaDateMil">
                <xsl:if test="contains(.//table/tr[1]/td[1],'(Miladî)')">
                    <xsl:variable name="vDateG" select="replace(substring-after(substring-before(.//table/tr[1]/td[1],'(Miladî)'),'Tarih:'),'/','-')"/>
                    <xsl:variable name="vYearG" select="tokenize(normalize-space($vDateG),'-')[3]"/>
                    <xsl:variable name="vMonthG" select="tokenize(normalize-space($vDateG),'-')[2]"/>
                    <xsl:variable name="vDayG" select="tokenize(normalize-space($vDateG),'-')[1]"/>
                    <xsl:value-of select="concat($vYearG,'-',$vMonthG,'-',$vDayG)"/>
                </xsl:if>
                <xsl:if test="contains(.//table/tr[1]/td[1],'(Hicrî)')">
                    <xsl:variable name="vDateH" select="replace(substring-after(substring-before(.//table/tr[1]/td[1],'(Hicrî)'),'Tarih:'),'/','-')"/>
                    <xsl:variable name="vYearH" select="tokenize(normalize-space($vDateH),'-')[3]"/>
                    <xsl:variable name="vMonthH">
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='M '">
                            <xsl:value-of select="1"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='S '">
                            <xsl:value-of select="2"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='Ra'">
                            <xsl:value-of select="3"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='R '">
                            <xsl:value-of select="4"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='Ca'">
                            <xsl:value-of select="5"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='C '">
                            <xsl:value-of select="6"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='B '">
                            <xsl:value-of select="7"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='Ş '">
                            <xsl:value-of select="8"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='N '">
                            <xsl:value-of select="9"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='L '">
                            <xsl:value-of select="10"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='Za'">
                            <xsl:value-of select="11"/>
                        </xsl:if>
                        <xsl:if test="tokenize(normalize-space($vDateH),'-')[2]='Z '">
                            <xsl:value-of select="12"/>
                        </xsl:if>
                        
                    </xsl:variable>
                    <xsl:variable name="vDayH" select="tokenize(normalize-space($vDateH),'-')[1]"/>
                    <xsl:call-template name="funcDateH2G">
                        <xsl:with-param name="pDateH" select="concat($vYearH,'-',$vMonthH,'-',$vDayH)"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="vBoaDateHic">
                <xsl:if test="contains(.//table/tr[1]/td[1],'(Hicrî)')">
                    <xsl:variable name="v1" select="substring-after(substring-before(.//table/tr[1]/td[1],'(Hicrî)'),'Tarih:')"/>
                    <xsl:value-of select=" format-number(number(tokenize(normalize-space($v1),'/')[1]),'0')"/>
                    <xsl:value-of select="' '"/>
                    <!-- repalce the abbreviations at BOA with mine -->
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='M '">
                        <xsl:value-of select="'Muḥ'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='S '">
                        <xsl:value-of select="'Ṣaf'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='Ra'">
                        <xsl:value-of select="'Rab I'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='R '">
                        <xsl:value-of select="'Rab II'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='Ca'">
                        <xsl:value-of select="'Jum I'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='C '">
                        <xsl:value-of select="'Jum II'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='B '">
                        <xsl:value-of select="'Raj'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='Ş '">
                        <xsl:value-of select="'Shaʿ'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='N '">
                        <xsl:value-of select="'Ram'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='L '">
                        <xsl:value-of select="'Shaw'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='Za'">
                        <xsl:value-of select="'Dhu I'"/>
                    </xsl:if>
                    <xsl:if test="tokenize(normalize-space($v1),'/')[2]='Z '">
                        <xsl:value-of select="'Dhu II'"/>
                    </xsl:if>
                    <xsl:value-of select="' '"/>
                    <xsl:value-of select="tokenize(normalize-space($v1),'/')[3]"/>
                </xsl:if>
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
                    <xsl:if test="$vBoaDateMil!=''">
                        <xsl:element name="tss:date">
                            <xsl:attribute name="type">Publication</xsl:attribute>
                            <xsl:attribute name="day">
                                <xsl:value-of select="tokenize(normalize-space($vBoaDateMil),'-')[3]"/>
                            </xsl:attribute>
                            <xsl:attribute name="month">
                                <xsl:value-of select="tokenize(normalize-space($vBoaDateMil),'-')[2]"/>
                            </xsl:attribute>
                            <xsl:attribute name="year">
                                <xsl:value-of select="tokenize(normalize-space($vBoaDateMil),'-')[1]"/>
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
                        <xsl:value-of select="$vPubTitle"/>
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
                        <xsl:attribute name="name">Web data source</xsl:attribute>
                        <xsl:text>devletarsivleri.gov.tr</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Date Hijri</xsl:attribute>
                        <xsl:value-of select="$vBoaDateHic"/>
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
        </xsl:for-each>
    </xsl:template>
  
</xsl:stylesheet>