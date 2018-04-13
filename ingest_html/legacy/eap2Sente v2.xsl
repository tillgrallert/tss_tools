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
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
    
    <!-- v2: tries to directly queries the eap website 
    - PROBLEM: the source html is ill-formed (all the image link and image tags are not closed) and thus cannot be processed by Saxon
    - Solution: omit the doctype declaration and any non-closed elements as well as the ill-formed scripts
    - mode m4 produces a list of urls which can then be used with an applescript to download the image files to the hd 
    - mode m4a produces the Sente references with links to the downloaded images
    - mode m3 is dysfunctional
    - mode m1 is the standard mode for producing the Sente references with attached links to all pictures-->
    
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. As the eap links are unique for each number, I will use the catId-string from them for this purpose -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/replacement.xsl"/> <!-- provides replacement functions -->
    
    <xsl:param name="pSearch" select="'EAP119'"/> <!-- this param provides the possibility to search a specific eap project -->
    <!-- <xsl:variable name="vDoc" select="document('http://eap.bl.uk/database/results.a4d?projID={$pSearch}')"/> -->
    
    <xsl:template match="html//body">
        <xsl:apply-templates mode="m1"/>
    </xsl:template>
    
    <xsl:template match="div[@id='results']" mode="m2">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates mode="m2"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="html//div[@type='table']" mode="m1">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates mode="m4a"/> <!-- this is the line to trigger m1, m3, m4, m4a -->
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="table//td[not(./descendant::img)]" mode="m2">
        <xsl:variable name="vURL">
            <xsl:value-of select="'http://eap.bl.uk/database/'"/>
            <xsl:value-of select="./a/@href"/>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
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
                    <xsl:attribute name="name">articleTitle</xsl:attribute>
                    <xsl:value-of select="$vCatId"/>
                </xsl:element>
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
    
    <xsl:template match="div[@type='link']" mode="m1">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
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
        <xsl:variable name="vPubDate">
            <xsl:value-of select="$vYear"/><xsl:text>-</xsl:text><xsl:value-of select="$vMonth"/><xsl:text>-</xsl:text><xsl:value-of select="$vDay"/>
        </xsl:variable>
        
        <!--source EAP119/1/19/100: al-Muqtabas 16 May 1910 target http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_19_100-EAP119_mqs19100516_1_L.jpg -->
        
        <xsl:variable name="vEapNum">
            <xsl:value-of select="tokenize($vCallNum,'/')[1]"/>
        </xsl:variable>
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="'http://eap.bl.uk/EAPDigitalItems/'"/>
            <xsl:value-of select="$vEapNum"/><xsl:text>/</xsl:text>
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select="$vCallNum"/>
                <xsl:with-param name="pFind" select="'/'"/>
                <xsl:with-param name="pReplace" select="'_'"/>
            </xsl:call-template>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$vEapNum"/>
            <xsl:text>_mqs</xsl:text><!-- this part must be known and cannot be guessed -->
            <xsl:value-of select="format-date($vPubDate,'[Y0001][M01][D01]')"/>
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
                    <xsl:attribute name="name">articleTitle</xsl:attribute>
                    <xsl:value-of select="$vCatId"/>
                </xsl:element>
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
            <xsl:element name="tss:attachments">
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_1_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_2_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_3_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_4_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@type='link']" mode="m4">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
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
        <xsl:variable name="vPubDate">
            <xsl:value-of select="$vYear"/><xsl:text>-</xsl:text><xsl:value-of select="$vMonth"/><xsl:text>-</xsl:text><xsl:value-of select="$vDay"/>
        </xsl:variable>
        
        <!--source EAP119/1/19/100: al-Muqtabas 16 May 1910 target http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_19_100-EAP119_mqs19100516_1_L.jpg -->
        
        <xsl:variable name="vEapNum">
            <xsl:value-of select="tokenize($vCallNum,'/')[1]"/>
        </xsl:variable>
        <xsl:variable name="vUrlImgBase">
            <!-- <xsl:value-of select="'http://eap.bl.uk/EAPDigitalItems/'"/>
            <xsl:value-of select="$vEapNum"/><xsl:text>/</xsl:text> -->
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select="$vCallNum"/>
                <xsl:with-param name="pFind" select="'/'"/>
                <xsl:with-param name="pReplace" select="'_'"/>
            </xsl:call-template>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$vEapNum"/>
            <xsl:text>_mqs</xsl:text><!-- this part must be known and cannot be guessed -->
            <xsl:value-of select="format-date($vPubDate,'[Y0001][M01][D01]')"/>
        </xsl:variable>
        <xsl:text>"</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_1_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_2_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_3_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_4_L.jpg",</xsl:text>
                   
    </xsl:template>
    
    <xsl:template match="div[@type='link']" mode="m4a">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
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
        <xsl:variable name="vPubDate">
            <xsl:value-of select="$vYear"/><xsl:text>-</xsl:text><xsl:value-of select="$vMonth"/><xsl:text>-</xsl:text><xsl:value-of select="$vDay"/>
        </xsl:variable>
        
        <!--source EAP119/1/19/100: al-Muqtabas 16 May 1910 target http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_19_100-EAP119_mqs19100516_1_L.jpg -->
        
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="'/muqtabas/'"/>
            <xsl:value-of select="format-date($vPubDate,'[Y0001]')"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="format-date($vPubDate,'[Y0001][M01][D01]')"/>
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
                    <xsl:attribute name="name">articleTitle</xsl:attribute>
                    <xsl:value-of select="$vCatId"/>
                </xsl:element>
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
            <xsl:element name="tss:attachments">
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>.pdf</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_1_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_2_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_3_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrlImgBase"/><xsl:text>_4_L.jpg</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@type='link']" mode="m3">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"></xsl:value-of>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
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
        <xsl:variable name="vPubDate">
            <xsl:value-of select="$vYear"/><xsl:text>-</xsl:text><xsl:value-of select="$vMonth"/><xsl:text>-</xsl:text><xsl:value-of select="$vDay"/>
        </xsl:variable>
        
        <!--source EAP119/1/19/100: al-Muqtabas 16 May 1910 target http://eap.bl.uk/EAPDigitalItems/EAP119/EAP119_1_19_100-EAP119_mqs19100516_1_L.jpg -->
        
        <xsl:variable name="vEapNum">
            <xsl:value-of select="tokenize($vCallNum,'/')[1]"/>
        </xsl:variable>
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="'http://eap.bl.uk/EAPDigitalItems/'"/>
            <xsl:value-of select="$vEapNum"/><xsl:text>/</xsl:text>
            <xsl:call-template name="templReplaceString">
                <xsl:with-param name="pString" select="$vCallNum"/>
                <xsl:with-param name="pFind" select="'/'"/>
                <xsl:with-param name="pReplace" select="'_'"/>
            </xsl:call-template>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$vEapNum"/>
            <xsl:text>_mqs</xsl:text><!-- this part must be known and cannot be guessed -->
            <xsl:value-of select="format-date($vPubDate,'[Y0001][M01][D01]')"/>
        </xsl:variable>
        <xsl:variable name="vUrlImgP1">
            <xsl:value-of select="$vUrlImgBase"/>
            <xsl:text>_1_L.jpg</xsl:text>
        </xsl:variable>
        
        <xsl:result-document href="/volumes/Lenya HD/muqtabas/{format-date($vPubDate,'[Y0001]-[M01]-[D01]')}/muqtabas-{format-date($vPubDate,'[Y0001]-[M01]-[D01]')}-p1-l.jpg">
            <xsl:copy-of select="doc($vUrlImgP1)"/>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>