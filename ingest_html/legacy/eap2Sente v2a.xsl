<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    >
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"  name="xml"/>
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"  name="text"/>
    
    <!-- This stylesheet tries to build either Sente XML or BibTex from the links provided by the EAP -->
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
    <!-- v2a: uses a source file that is closer to the original
        - in addition, the param pSearch allows to select individual papers -->
    <!-- v2: tries to directly queries the eap website 
    - PROBLEM: the source html is ill-formed (all the image link and image tags are not closed) and thus cannot be processed by Saxon
    - Solution: omit the doctype declaration and any non-closed elements as well as the ill-formed scripts
    - mode m5 produces a list of urls which can then be used with an applescript to download the image files to the hd 
    - mode m4 produces the Sente references with links to the downloaded images
    - mode m3 is dysfunctional
    - mode m1 is the standard mode for producing the Sente references with attached links to all pictures-->
    
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. As the eap links are unique for each number, I will use the catId-string from them for this purpose -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/replacement.xsl"/> <!-- provides replacement functions -->
    
    <xsl:param name="pSearch" select="'7'"/> <!-- this param provides the possibility to search a specific eap119 project:
        1: Majallat Rawdat al-Ma'arif, bad date format (1 January 1922)
        3: al-Huquq, bad date
        4: al-Muqtabas Volume 2-7, no usable date
        5: al-Arab, bad date
        7: al-Mahaba', bad date, 1901, photos carry the actual page number, and can, again not be guessed. damn.
        8: al-Hasna Volume 1-3, no usable date
        9: al-Zahra, bad date
        10: Rawdat al-Ma'arif, bad date
        11: al-Fajr, bad date
        12: al-Jami'ah al-Islamiyah, standard date
        13: al-Jami'ah al-Arabiyah, standard date
        14: al-Sirat al-Mustaqim, standard date
        15: Sawt al-Sha'b, standard date
        16: al-Awqat al-Arabiyah
        17: al-Liwa'
        18: Tasvir-i Efkar, standard date
        19: al-Muqtabas
        20: al-Qabas
        21: al-Difa'
        22: Filastin
        23: al-Aqdam
        24: Mir'at al-Sharq, standard date, 1920s-30s
    -->
    <xsl:variable name="vPeriodShort">
        <xsl:if test="$pSearch='7'">
            <xsl:value-of select="'_mah'"/>
        </xsl:if>
        <xsl:if test="$pSearch='17'">
            <xsl:value-of select="'_liw'"/>
        </xsl:if>
        <xsl:if test="$pSearch='18'">
            <xsl:value-of select="'_taz'"/>
        </xsl:if>
        <xsl:if test="$pSearch='19'">
            <xsl:value-of select="'_mqs'"/>
        </xsl:if>
        <xsl:if test="$pSearch='20'">
            <xsl:value-of select="'_qab'"/>
        </xsl:if>
        <xsl:if test="$pSearch='22'">
            <xsl:value-of select="'_fil'"/>
        </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="vPeriodLong">
        <xsl:if test="$pSearch='7'">
            <xsl:value-of select="'/mahabba/'"/>
        </xsl:if>
        <xsl:if test="$pSearch='17'">
            <xsl:value-of select="'/liwa/'"/>
        </xsl:if>
        <xsl:if test="$pSearch='18'">
            <xsl:value-of select="'/tasvir-i efkar/'"/>
        </xsl:if>
        <xsl:if test="$pSearch='19'">
            <xsl:value-of select="'/muqtabas/'"/>
        </xsl:if>
        <xsl:if test="$pSearch='20'">
            <xsl:value-of select="'/qabas/'"/>
        </xsl:if>
        <xsl:if test="$pSearch='22'">
            <xsl:value-of select="'/filastin/'"/>
        </xsl:if>
    </xsl:variable>
    <!-- <xsl:variable name="vDoc" select="document('http://eap.bl.uk/database/results.a4d?projID={$pSearch}')"/> -->
    
    <xsl:template match="html//body">
        <xsl:apply-templates mode="m1"/> <!-- select m1, m2, m5 -->
    </xsl:template>
   
    
    <xsl:template match="html//div[@type='table']" mode="m1">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:apply-templates mode="m1"/> <!-- this is the line to trigger m1, m3, m4 -->
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="html//div[@type='table']" mode="m5">
        <!-- this section creates the full applescript -->
        <![CDATA[set vUrlBase to "http://eap.bl.uk/EAPDigitalItems/EAP119/"
set vUrlDoc to {]]>
        <xsl:apply-templates mode="m5"/>
        <![CDATA[}

set vErrors to {}
set vFolder1 to "]]><xsl:value-of select="$vPeriodLong"/><![CDATA["

tell application "URL Access Scripting"
	repeat with Y from 1 to (number of items) of vUrlDoc
		set vUrlDocSelected to item Y of vUrlDoc
		set vOffset1 to offset of "]]><xsl:value-of select="$vPeriodShort"/><![CDATA[" in vUrlDocSelected
		set vFolder2 to text (vOffset1 + 4) thru (vOffset1 + 7) of vUrlDocSelected

		set vDocName to text (vOffset1 + 4) thru (vOffset1 + 15) of vUrlDocSelected
		
		set vDoc to (vUrlBase & vUrlDocSelected as string)
		try
			download vDoc to vFolder1 & vFolder2 & "/" & (vDocName as string) & ".jpg" replacing yes
		on error
			set end of vErrors to vUrlDocSelected
		end try
		
	end repeat
	
	set the clipboard to (vErrors as string)
	
end tell

tell application "TextEdit"
	make new document
	set text of document 1 to (the clipboard as text)
	save document 1 in "/Users/BachPrivat/Desktop/eap-errors.txt"
end tell]]>
    </xsl:template>
    
    
    <xsl:template match="div[not(descendant::img)]" mode="m1">
        <xsl:if test="tokenize(./a,'/')[3]=$pSearch"> 
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
            <xsl:value-of select="$vPeriodShort"/><!-- this part must be known and cannot be guessed -->
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
                <!-- this element is to be omitted for all but muqtabas and qabas -->
                <xsl:if test="$pSearch=('19','20')">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">volume</xsl:attribute> <!-- this should actually be issue, but for the sake of file organisation i made this decision some years ago -->
                        <xsl:for-each select="$vIssue/issue">
                            <xsl:if test="substring-after(.,',')=format-date($vPubDate,'[Y0001]-[M01]-[D01]')">
                                <xsl:value-of select="substring-before(.,',')"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">call-num</xsl:attribute>
                    <xsl:value-of select="$vCallNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    <xsl:if test="$pSearch='7'">
                        <xsl:text>mahabba </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='17'">
                        <xsl:text>liwa </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='18'">
                        <xsl:text>tesvir </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='19'">
                        <xsl:text>muqtabas </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='20'">
                        <xsl:text>qabas </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="tokenize($vCallNum,'/')[4]"/>
                    <xsl:text>-eap</xsl:text>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">URL</xsl:attribute>
                    <xsl:value-of select="$vURL"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tss:attachments">
                <xsl:if test="$pSearch!='7'">
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
                </xsl:if>
            </xsl:element>
        </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="div[not(descendant::img)]" mode="m5">
        <xsl:if test="tokenize(./a,'/')[3]=$pSearch">
        <xsl:variable name="vURL">
            <xsl:value-of select="./a/@href"/>
        </xsl:variable>
        <xsl:variable name="vCatId">
            <xsl:value-of select="substring-before(substring-after($vURL,'catId='),';r')"/>
        </xsl:variable>
        <xsl:variable name="vCallNum">
            <xsl:value-of select="substring-before(./a,':')"/>
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
            <xsl:value-of select="$vPeriodShort"/>
            <xsl:value-of select="format-date($vPubDate,'[Y0001][M01][D01]')"/>
        </xsl:variable>
            <xsl:text>"</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_1_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_2_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_3_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_4_L.jpg",</xsl:text>
            <xsl:if test="$pSearch='18'">
                <xsl:text>"</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_5_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_6_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_7_L.jpg","</xsl:text><xsl:value-of select="$vUrlImgBase"/><xsl:text>_8_L.jpg",</xsl:text>
            </xsl:if>
        </xsl:if>
                   
    </xsl:template>
    
    <xsl:template match="div[not(descendant::img)]" mode="m4">
        <xsl:if test="tokenize(./a,'/')[3]=$pSearch"> 
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
            <xsl:if test="$pSearch='18'">
                <xsl:value-of select="tokenize(substring-after(./a,': '),' ')[2]"/>
            </xsl:if>
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
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="$vPeriodLong"/> <!-- change according to paper -->
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
                <!-- this element is to be omitted for all but muqtabas and qabas -->
                <xsl:if test="$pSearch=('19','20')">
                    <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">volume</xsl:attribute> <!-- this should actually be issue, but for the sake of file organisation i made this decision some years ago -->
                    <xsl:for-each select="$vIssue/issue">
                        <xsl:if test="substring-after(.,',')=format-date($vPubDate,'[Y0001]-[M01]-[D01]')">
                            <xsl:value-of select="substring-before(.,',')"/>
                        </xsl:if>
                    </xsl:for-each>
                    </xsl:element>
                </xsl:if>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">call-num</xsl:attribute>
                    <xsl:value-of select="$vCallNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    <xsl:if test="$pSearch='7'">
                        <xsl:text>mahabba </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='17'">
                        <xsl:text>liwa </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='18'">
                        <xsl:text>tesvir </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='19'">
                        <xsl:text>muqtabas </xsl:text>
                    </xsl:if>
                    <xsl:if test="$pSearch='20'">
                        <xsl:text>qabas </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="tokenize($vCallNum,'/')[4]"/>
                    <xsl:text>-eap</xsl:text>
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
                <xsl:if test="$pSearch='18'">
                    <xsl:element name="tss:attachmentReference">
                        <xsl:element name="URL">
                            <xsl:value-of select="$vUrlImgBase"/><xsl:text>_5_L.jpg</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="tss:attachmentReference">
                        <xsl:element name="URL">
                            <xsl:value-of select="$vUrlImgBase"/><xsl:text>_6_L.jpg</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="tss:attachmentReference">
                        <xsl:element name="URL">
                            <xsl:value-of select="$vUrlImgBase"/><xsl:text>_7_L.jpg</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="tss:attachmentReference">
                        <xsl:element name="URL">
                            <xsl:value-of select="$vUrlImgBase"/><xsl:text>_8_L.jpg</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:variable name="vIssue">
        <issue>2518,1916-12-31</issue>
        <issue>2517,1916-12-29</issue>
        <issue>2516,1916-12-28</issue>
        <issue>2515,1916-12-27</issue>
        <issue>2514,1916-12-26</issue>
        <issue>2513,1916-12-25</issue>
        <issue>2512,1916-12-24</issue>
        <issue>2511,1916-12-22</issue>
        <issue>2510,1916-12-21</issue>
        <issue>2509,1916-12-20</issue>
        <issue>2508,1916-12-19</issue>
        <issue>2507,1916-12-18</issue>
        <issue>2506,1916-12-17</issue>
        <issue>2505,1916-12-15</issue>
        <issue>2504,1916-12-14</issue>
        <issue>2503,1916-12-13</issue>
        <issue>2502,1916-12-12</issue>
        <issue>2501,1916-12-11</issue>
        <issue>2500,1916-12-10</issue>
        <issue>2499,1916-12-08</issue>
        <issue>2498,1916-12-07</issue>
        <issue>2497,1916-12-06</issue>
        <issue>2496,1916-12-05</issue>
        <issue>2495,1916-12-04</issue>
        <issue>2494,1916-12-03</issue>
        <issue>2493,1916-12-01</issue>
        <issue>2492,1916-11-30</issue>
        <issue>2491,1916-11-29</issue>
        <issue>2490,1916-11-28</issue>
        <issue>2489,1916-11-27</issue>
        <issue>2488,1916-11-26</issue>
        <issue>2487,1916-11-24</issue>
        <issue>2486,1916-11-23</issue>
        <issue>2485,1916-11-22</issue>
        <issue>2484,1916-11-21</issue>
        <issue>2483,1916-11-20</issue>
        <issue>2482,1916-11-19</issue>
        <issue>2481,1916-11-17</issue>
        <issue>2480,1916-11-16</issue>
        <issue>2479,1916-11-15</issue>
        <issue>2478,1916-11-14</issue>
        <issue>2477,1916-11-13</issue>
        <issue>2476,1916-11-12</issue>
        <issue>2475,1916-11-10</issue>
        <issue>2474,1916-11-09</issue>
        <issue>2473,1916-11-08</issue>
        <issue>2472,1916-11-07</issue>
        <issue>2471,1916-11-06</issue>
        <issue>2470,1916-11-05</issue>
        <issue>2469,1916-11-03</issue>
        <issue>2468,1916-11-02</issue>
        <issue>2467,1916-11-01</issue>
        <issue>2466,1916-10-31</issue>
        <issue>2465,1916-10-30</issue>
        <issue>2464,1916-10-29</issue>
        <issue>2463,1916-10-27</issue>
        <issue>2462,1916-10-26</issue>
        <issue>2461,1916-10-25</issue>
        <issue>2460,1916-10-24</issue>
        <issue>2459,1916-10-23</issue>
        <issue>2458,1916-10-22</issue>
        <issue>2457,1916-10-20</issue>
        <issue>2456,1916-10-19</issue>
        <issue>2455,1916-10-18</issue>
        <issue>2454,1916-10-17</issue>
        <issue>2453,1916-10-16</issue>
        <issue>2452,1916-10-15</issue>
        <issue>2451,1916-10-13</issue>
        <issue>2450,1916-10-12</issue>
        <issue>2449,1916-10-11</issue>
        <issue>2448,1916-10-10</issue>
        <issue>2447,1916-10-09</issue>
        <issue>2446,1916-10-08</issue>
        <issue>2445,1916-10-06</issue>
        <issue>2444,1916-10-05</issue>
        <issue>2443,1916-10-04</issue>
        <issue>2442,1916-10-03</issue>
        <issue>2441,1916-10-02</issue>
        <issue>2440,1916-10-01</issue>
        <issue>2439,1916-09-29</issue>
        <issue>2438,1916-09-28</issue>
        <issue>2437,1916-09-27</issue>
        <issue>2436,1916-09-26</issue>
        <issue>2435,1916-09-25</issue>
        <issue>2434,1916-09-24</issue>
        <issue>2433,1916-09-22</issue>
        <issue>2432,1916-09-21</issue>
        <issue>2431,1916-09-20</issue>
        <issue>2430,1916-09-19</issue>
        <issue>2429,1916-09-18</issue>
        <issue>2428,1916-09-17</issue>
        <issue>2427,1916-09-15</issue>
        <issue>2426,1916-09-14</issue>
        <issue>2425,1916-09-13</issue>
        <issue>2424,1916-09-12</issue>
        <issue>2423,1916-09-11</issue>
        <issue>2422,1916-09-10</issue>
        <issue>2421,1916-09-08</issue>
        <issue>2420,1916-09-07</issue>
        <issue>2419,1916-09-06</issue>
        <issue>2418,1916-09-05</issue>
        <issue>2417,1916-09-04</issue>
        <issue>2416,1916-09-03</issue>
        <issue>2415,1916-09-01</issue>
        <issue>2414,1916-08-31</issue>
        <issue>2413,1916-08-30</issue>
        <issue>2412,1916-08-29</issue>
        <issue>2411,1916-08-28</issue>
        <issue>2410,1916-08-27</issue>
        <issue>2409,1916-08-25</issue>
        <issue>2408,1916-08-24</issue>
        <issue>2407,1916-08-23</issue>
        <issue>2406,1916-08-22</issue>
        <issue>2405,1916-08-21</issue>
        <issue>2404,1916-08-20</issue>
        <issue>2403,1916-08-18</issue>
        <issue>2402,1916-08-17</issue>
        <issue>2401,1916-08-16</issue>
        <issue>2400,1916-08-15</issue>
        <issue>2399,1916-08-14</issue>
        <issue>2398,1916-08-13</issue>
        <issue>2397,1916-08-11</issue>
        <issue>2396,1916-08-10</issue>
        <issue>2395,1916-08-09</issue>
        <issue>2394,1916-08-08</issue>
        <issue>2393,1916-08-07</issue>
        <issue>2392,1916-08-06</issue>
        <issue>2391,1916-08-04</issue>
        <issue>2390,1916-08-03</issue>
        <issue>2389,1916-08-02</issue>
        <issue>2388,1916-08-01</issue>
        <issue>2387,1916-07-31</issue>
        <issue>2386,1916-07-30</issue>
        <issue>2385,1916-07-28</issue>
        <issue>2384,1916-07-27</issue>
        <issue>2383,1916-07-26</issue>
        <issue>2382,1916-07-25</issue>
        <issue>2381,1916-07-24</issue>
        <issue>2380,1916-07-23</issue>
        <issue>2379,1916-07-21</issue>
        <issue>2378,1916-07-20</issue>
        <issue>2377,1916-07-19</issue>
        <issue>2376,1916-07-18</issue>
        <issue>2375,1916-07-17</issue>
        <issue>2374,1916-07-16</issue>
        <issue>2373,1916-07-14</issue>
        <issue>2372,1916-07-13</issue>
        <issue>2371,1916-07-12</issue>
        <issue>2370,1916-07-11</issue>
        <issue>2369,1916-07-10</issue>
        <issue>2368,1916-07-09</issue>
        <issue>2367,1916-07-07</issue>
        <issue>2366,1916-07-06</issue>
        <issue>2365,1916-07-05</issue>
        <issue>2364,1916-07-04</issue>
        <issue>2363,1916-07-03</issue>
        <issue>2362,1916-07-02</issue>
        <issue>2361,1916-06-30</issue>
        <issue>2360,1916-06-29</issue>
        <issue>2359,1916-06-28</issue>
        <issue>2358,1916-06-27</issue>
        <issue>2357,1916-06-26</issue>
        <issue>2356,1916-06-25</issue>
        <issue>2355,1916-06-23</issue>
        <issue>2354,1916-06-22</issue>
        <issue>2353,1916-06-21</issue>
        <issue>2352,1916-06-20</issue>
        <issue>2351,1916-06-19</issue>
        <issue>2350,1916-06-18</issue>
        <issue>2349,1916-06-16</issue>
        <issue>2348,1916-06-15</issue>
        <issue>2347,1916-06-14</issue>
        <issue>2346,1916-06-13</issue>
        <issue>2345,1916-06-12</issue>
        <issue>2344,1916-06-11</issue>
        <issue>2343,1916-06-09</issue>
        <issue>2342,1916-06-08</issue>
        <issue>2341,1916-06-07</issue>
        <issue>2340,1916-06-06</issue>
        <issue>2339,1916-06-05</issue>
        <issue>2338,1916-06-04</issue>
        <issue>2337,1916-06-02</issue>
        <issue>2336,1916-06-01</issue>
        <issue>2335,1916-05-31</issue>
        <issue>2334,1916-05-30</issue>
        <issue>2333,1916-05-29</issue>
        <issue>2332,1916-05-28</issue>
        <issue>2331,1916-05-26</issue>
        <issue>2330,1916-05-25</issue>
        <issue>2329,1916-05-24</issue>
        <issue>2328,1916-05-23</issue>
        <issue>2327,1916-05-22</issue>
        <issue>2326,1916-05-21</issue>
        <issue>2325,1916-05-19</issue>
        <issue>2324,1916-05-18</issue>
        <issue>2323,1916-05-17</issue>
        <issue>2322,1916-05-16</issue>
        <issue>2321,1916-05-15</issue>
        <issue>2320,1916-05-14</issue>
        <issue>2319,1916-05-12</issue>
        <issue>2318,1916-05-11</issue>
        <issue>2317,1916-05-10</issue>
        <issue>2316,1916-05-09</issue>
        <issue>2315,1916-05-08</issue>
        <issue>2314,1916-05-07</issue>
        <issue>2313,1916-05-05</issue>
        <issue>2312,1916-05-04</issue>
        <issue>2311,1916-05-03</issue>
        <issue>2310,1916-05-02</issue>
        <issue>2309,1916-05-01</issue>
        <issue>2308,1916-04-30</issue>
        <issue>2307,1916-04-28</issue>
        <issue>2306,1916-04-27</issue>
        <issue>2305,1916-04-26</issue>
        <issue>2304,1916-04-25</issue>
        <issue>2303,1916-04-24</issue>
        <issue>2302,1916-04-23</issue>
        <issue>2301,1916-04-21</issue>
        <issue>2300,1916-04-20</issue>
        <issue>2299,1916-04-19</issue>
        <issue>2298,1916-04-18</issue>
        <issue>2297,1916-04-17</issue>
        <issue>2296,1916-04-16</issue>
        <issue>2295,1916-04-14</issue>
        <issue>2294,1916-04-13</issue>
        <issue>2293,1916-04-12</issue>
        <issue>2292,1916-04-11</issue>
        <issue>2291,1916-04-10</issue>
        <issue>2290,1916-04-09</issue>
        <issue>2289,1916-04-07</issue>
        <issue>2288,1916-04-06</issue>
        <issue>2287,1916-04-05</issue>
        <issue>2286,1916-04-04</issue>
        <issue>2285,1916-04-03</issue>
        <issue>2284,1916-04-02</issue>
        <issue>2283,1916-03-31</issue>
        <issue>2282,1916-03-30</issue>
        <issue>2281,1916-03-29</issue>
        <issue>2280,1916-03-28</issue>
        <issue>2279,1916-03-27</issue>
        <issue>2278,1916-03-26</issue>
        <issue>2277,1916-03-24</issue>
        <issue>2276,1916-03-23</issue>
        <issue>2275,1916-03-22</issue>
        <issue>2274,1916-03-21</issue>
        <issue>2273,1916-03-20</issue>
        <issue>2272,1916-03-19</issue>
        <issue>2271,1916-03-17</issue>
        <issue>2270,1916-03-16</issue>
        <issue>2269,1916-03-15</issue>
        <issue>2268,1916-03-14</issue>
        <issue>2267,1916-03-13</issue>
        <issue>2266,1916-03-12</issue>
        <issue>2265,1916-03-10</issue>
        <issue>2264,1916-03-09</issue>
        <issue>2263,1916-03-08</issue>
        <issue>2262,1916-03-07</issue>
        <issue>2261,1916-03-06</issue>
        <issue>2260,1916-03-05</issue>
        <issue>2259,1916-03-03</issue>
        <issue>2258,1916-03-02</issue>
        <issue>2257,1916-03-01</issue>
        <issue>2256,1916-02-29</issue>
        <issue>2255,1916-02-28</issue>
        <issue>2254,1916-02-27</issue>
        <issue>2253,1916-02-25</issue>
        <issue>2252,1916-02-24</issue>
        <issue>2251,1916-02-23</issue>
        <issue>2250,1916-02-22</issue>
        <issue>2249,1916-02-21</issue>
        <issue>2248,1916-02-20</issue>
        <issue>2247,1916-02-18</issue>
        <issue>2246,1916-02-17</issue>
        <issue>2245,1916-02-16</issue>
        <issue>2244,1916-02-15</issue>
        <issue>2243,1916-02-14</issue>
        <issue>2242,1916-02-13</issue>
        <issue>2241,1916-02-11</issue>
        <issue>2240,1916-02-10</issue>
        <issue>2239,1916-02-09</issue>
        <issue>2238,1916-02-08</issue>
        <issue>2237,1916-02-07</issue>
        <issue>2236,1916-02-06</issue>
        <issue>2235,1916-02-04</issue>
        <issue>2234,1916-02-03</issue>
        <issue>2233,1916-02-02</issue>
        <issue>2232,1916-02-01</issue>
        <issue>2231,1916-01-31</issue>
        <issue>2230,1916-01-30</issue>
        <issue>2229,1916-01-28</issue>
        <issue>2228,1916-01-27</issue>
        <issue>2227,1916-01-26</issue>
        <issue>2226,1916-01-25</issue>
        <issue>2225,1916-01-24</issue>
        <issue>2224,1916-01-23</issue>
        <issue>2223,1916-01-21</issue>
        <issue>2222,1916-01-20</issue>
        <issue>2221,1916-01-19</issue>
        <issue>2220,1916-01-18</issue>
        <issue>2219,1916-01-17</issue>
        <issue>2218,1916-01-16</issue>
        <issue>2217,1916-01-14</issue>
        <issue>2216,1916-01-13</issue>
        <issue>2215,1916-01-12</issue>
        <issue>2214,1916-01-11</issue>
        <issue>2213,1916-01-10</issue>
        <issue>2212,1916-01-09</issue>
        <issue>2211,1916-01-07</issue>
        <issue>2210,1916-01-06</issue>
        <issue>2209,1916-01-05</issue>
        <issue>2208,1916-01-04</issue>
        <issue>2207,1916-01-03</issue>
        <issue>2206,1916-01-02</issue>
        <issue>2205,1915-12-31</issue>
        <issue>2204,1915-12-30</issue>
        <issue>2203,1915-12-29</issue>
        <issue>2202,1915-12-28</issue>
        <issue>2201,1915-12-27</issue>
        <issue>2200,1915-12-26</issue>
        <issue>2199,1915-12-24</issue>
        <issue>2198,1915-12-23</issue>
        <issue>2197,1915-12-22</issue>
        <issue>2196,1915-12-21</issue>
        <issue>2195,1915-12-20</issue>
        <issue>2194,1915-12-19</issue>
        <issue>2193,1915-12-17</issue>
        <issue>2192,1915-12-16</issue>
        <issue>2191,1915-12-15</issue>
        <issue>2190,1915-12-14</issue>
        <issue>2189,1915-12-13</issue>
        <issue>2188,1915-12-12</issue>
        <issue>2187,1915-12-10</issue>
        <issue>2186,1915-12-09</issue>
        <issue>2185,1915-12-08</issue>
        <issue>2184,1915-12-07</issue>
        <issue>2183,1915-12-06</issue>
        <issue>2182,1915-12-05</issue>
        <issue>2181,1915-12-03</issue>
        <issue>2180,1915-12-02</issue>
        <issue>2179,1915-12-01</issue>
        <issue>2178,1915-11-30</issue>
        <issue>2177,1915-11-29</issue>
        <issue>2176,1915-11-28</issue>
        <issue>2175,1915-11-26</issue>
        <issue>2174,1915-11-25</issue>
        <issue>2173,1915-11-24</issue>
        <issue>2172,1915-11-23</issue>
        <issue>2171,1915-11-22</issue>
        <issue>2170,1915-11-21</issue>
        <issue>2169,1915-11-19</issue>
        <issue>2168,1915-11-18</issue>
        <issue>2167,1915-11-17</issue>
        <issue>2166,1915-11-16</issue>
        <issue>2165,1915-11-15</issue>
        <issue>2164,1915-11-14</issue>
        <issue>2163,1915-11-12</issue>
        <issue>2162,1915-11-11</issue>
        <issue>2161,1915-11-10</issue>
        <issue>2160,1915-11-09</issue>
        <issue>2159,1915-11-08</issue>
        <issue>2158,1915-11-07</issue>
        <issue>2157,1915-11-05</issue>
        <issue>2156,1915-11-04</issue>
        <issue>2155,1915-11-03</issue>
        <issue>2154,1915-11-02</issue>
        <issue>2153,1915-11-01</issue>
        <issue>2152,1915-10-31</issue>
        <issue>2151,1915-10-29</issue>
        <issue>2150,1915-10-28</issue>
        <issue>2149,1915-10-27</issue>
        <issue>2148,1915-10-26</issue>
        <issue>2147,1915-10-25</issue>
        <issue>2146,1915-10-24</issue>
        <issue>2145,1915-10-22</issue>
        <issue>2144,1915-10-21</issue>
        <issue>2143,1915-10-20</issue>
        <issue>2142,1915-10-19</issue>
        <issue>2141,1915-10-18</issue>
        <issue>2140,1915-10-17</issue>
        <issue>2139,1915-10-15</issue>
        <issue>2138,1915-10-14</issue>
        <issue>2137,1915-10-13</issue>
        <issue>2136,1915-10-12</issue>
        <issue>2135,1915-10-11</issue>
        <issue>2134,1915-10-10</issue>
        <issue>2133,1915-10-08</issue>
        <issue>2132,1915-10-07</issue>
        <issue>2131,1915-10-06</issue>
        <issue>2130,1915-10-05</issue>
        <issue>2129,1915-10-04</issue>
        <issue>2128,1915-10-03</issue>
        <issue>2127,1915-10-01</issue>
        <issue>2126,1915-09-30</issue>
        <issue>2125,1915-09-29</issue>
        <issue>2124,1915-09-28</issue>
        <issue>2123,1915-09-27</issue>
        <issue>2122,1915-09-26</issue>
        <issue>2121,1915-09-24</issue>
        <issue>2120,1915-09-23</issue>
        <issue>2119,1915-09-22</issue>
        <issue>2118,1915-09-21</issue>
        <issue>2117,1915-09-20</issue>
        <issue>2116,1915-09-19</issue>
        <issue>2115,1915-09-17</issue>
        <issue>2114,1915-09-16</issue>
        <issue>2113,1915-09-15</issue>
        <issue>2112,1915-09-14</issue>
        <issue>2111,1915-09-13</issue>
        <issue>2110,1915-09-12</issue>
        <issue>2109,1915-09-10</issue>
        <issue>2108,1915-09-09</issue>
        <issue>2107,1915-09-08</issue>
        <issue>2106,1915-09-07</issue>
        <issue>2105,1915-09-06</issue>
        <issue>2104,1915-09-05</issue>
        <issue>2103,1915-09-03</issue>
        <issue>2102,1915-09-02</issue>
        <issue>2101,1915-09-01</issue>
        <issue>2100,1915-08-31</issue>
        <issue>2099,1915-08-30</issue>
        <issue>2098,1915-08-29</issue>
        <issue>2097,1915-08-27</issue>
        <issue>2096,1915-08-26</issue>
        <issue>2095,1915-08-25</issue>
        <issue>2094,1915-08-24</issue>
        <issue>2093,1915-08-23</issue>
        <issue>2092,1915-08-22</issue>
        <issue>2091,1915-08-20</issue>
        <issue>2090,1915-08-19</issue>
        <issue>2089,1915-08-18</issue>
        <issue>2088,1915-08-17</issue>
        <issue>2087,1915-08-16</issue>
        <issue>2086,1915-08-15</issue>
        <issue>2085,1915-08-13</issue>
        <issue>2084,1915-08-12</issue>
        <issue>2083,1915-08-11</issue>
        <issue>2082,1915-08-10</issue>
        <issue>2081,1915-08-09</issue>
        <issue>2080,1915-08-08</issue>
        <issue>2079,1915-08-06</issue>
        <issue>2078,1915-08-05</issue>
        <issue>2077,1915-08-04</issue>
        <issue>2076,1915-08-03</issue>
        <issue>2075,1915-08-02</issue>
        <issue>2074,1915-08-01</issue>
        <issue>2073,1915-07-30</issue>
        <issue>2072,1915-07-29</issue>
        <issue>2071,1915-07-28</issue>
        <issue>2070,1915-07-27</issue>
        <issue>2069,1915-07-26</issue>
        <issue>2068,1915-07-25</issue>
        <issue>2067,1915-07-23</issue>
        <issue>2066,1915-07-22</issue>
        <issue>2065,1915-07-21</issue>
        <issue>2064,1915-07-20</issue>
        <issue>2063,1915-07-19</issue>
        <issue>2062,1915-07-18</issue>
        <issue>2061,1915-07-16</issue>
        <issue>2060,1915-07-15</issue>
        <issue>2059,1915-07-14</issue>
        <issue>2058,1915-07-13</issue>
        <issue>2057,1915-07-12</issue>
        <issue>2056,1915-07-11</issue>
        <issue>2055,1915-07-09</issue>
        <issue>2054,1915-07-08</issue>
        <issue>2053,1915-07-07</issue>
        <issue>2052,1915-07-06</issue>
        <issue>2051,1915-07-05</issue>
        <issue>2050,1915-07-04</issue>
        <issue>2049,1915-07-02</issue>
        <issue>2048,1915-07-01</issue>
        <issue>2047,1915-06-30</issue>
        <issue>2046,1915-06-29</issue>
        <issue>2045,1915-06-28</issue>
        <issue>2044,1915-06-27</issue>
        <issue>2043,1915-06-25</issue>
        <issue>2042,1915-06-24</issue>
        <issue>2041,1915-06-23</issue>
        <issue>2040,1915-06-22</issue>
        <issue>2039,1915-06-21</issue>
        <issue>2038,1915-06-20</issue>
        <issue>2037,1915-06-18</issue>
        <issue>2036,1915-06-17</issue>
        <issue>2035,1915-06-16</issue>
        <issue>2034,1915-06-15</issue>
        <issue>2033,1915-06-14</issue>
        <issue>2032,1915-06-13</issue>
        <issue>2031,1915-06-11</issue>
        <issue>2030,1915-06-10</issue>
        <issue>2029,1915-06-09</issue>
        <issue>2028,1915-06-08</issue>
        <issue>2027,1915-06-07</issue>
        <issue>2026,1915-06-06</issue>
        <issue>2025,1915-06-04</issue>
        <issue>2024,1915-06-03</issue>
        <issue>2023,1915-06-02</issue>
        <issue>2022,1915-06-01</issue>
        <issue>2021,1915-05-31</issue>
        <issue>2020,1915-05-30</issue>
        <issue>2019,1915-05-28</issue>
        <issue>2018,1915-05-27</issue>
        <issue>2017,1915-05-26</issue>
        <issue>2016,1915-05-25</issue>
        <issue>2015,1915-05-24</issue>
        <issue>2014,1915-05-23</issue>
        <issue>2013,1915-05-21</issue>
        <issue>2012,1915-05-20</issue>
        <issue>2011,1915-05-19</issue>
        <issue>2010,1915-05-18</issue>
        <issue>2009,1915-05-17</issue>
        <issue>2008,1915-05-16</issue>
        <issue>2007,1915-05-14</issue>
        <issue>2006,1915-05-13</issue>
        <issue>2005,1915-05-12</issue>
        <issue>2004,1915-05-11</issue>
        <issue>2003,1915-05-10</issue>
        <issue>2002,1915-05-09</issue>
        <issue>2001,1915-05-07</issue>
        <issue>2000,1915-05-06</issue>
        <issue>1999,1915-05-05</issue>
        <issue>1998,1915-05-04</issue>
        <issue>1997,1915-05-03</issue>
        <issue>1996,1915-05-02</issue>
        <issue>1995,1915-04-30</issue>
        <issue>1994,1915-04-29</issue>
        <issue>1993,1915-04-28</issue>
        <issue>1992,1915-04-27</issue>
        <issue>1991,1915-04-26</issue>
        <issue>1990,1915-04-25</issue>
        <issue>1989,1915-04-23</issue>
        <issue>1988,1915-04-22</issue>
        <issue>1987,1915-04-21</issue>
        <issue>1986,1915-04-20</issue>
        <issue>1985,1915-04-19</issue>
        <issue>1984,1915-04-18</issue>
        <issue>1983,1915-04-16</issue>
        <issue>1982,1915-04-15</issue>
        <issue>1981,1915-04-14</issue>
        <issue>1980,1915-04-13</issue>
        <issue>1979,1915-04-12</issue>
        <issue>1978,1915-04-11</issue>
        <issue>1977,1915-04-09</issue>
        <issue>1976,1915-04-08</issue>
        <issue>1975,1915-04-07</issue>
        <issue>1974,1915-04-06</issue>
        <issue>1973,1915-04-05</issue>
        <issue>1972,1915-04-04</issue>
        <issue>1971,1915-04-02</issue>
        <issue>1970,1915-04-01</issue>
        <issue>1969,1915-03-31</issue>
        <issue>1968,1915-03-30</issue>
        <issue>1967,1915-03-29</issue>
        <issue>1966,1915-03-28</issue>
        <issue>1965,1915-03-26</issue>
        <issue>1964,1915-03-25</issue>
        <issue>1963,1915-03-24</issue>
        <issue>1962,1915-03-23</issue>
        <issue>1961,1915-03-22</issue>
        <issue>1960,1915-03-21</issue>
        <issue>1959,1915-03-19</issue>
        <issue>1958,1915-03-18</issue>
        <issue>1957,1915-03-17</issue>
        <issue>1956,1915-03-16</issue>
        <issue>1955,1915-03-15</issue>
        <issue>1954,1915-03-14</issue>
        <issue>1953,1915-03-12</issue>
        <issue>1952,1915-03-11</issue>
        <issue>1951,1915-03-10</issue>
        <issue>1950,1915-03-09</issue>
        <issue>1949,1915-03-08</issue>
        <issue>1948,1915-03-07</issue>
        <issue>1947,1915-03-05</issue>
        <issue>1946,1915-03-04</issue>
        <issue>1945,1915-03-03</issue>
        <issue>1944,1915-03-02</issue>
        <issue>1943,1915-03-01</issue>
        <issue>1942,1915-02-28</issue>
        <issue>1941,1915-02-26</issue>
        <issue>1940,1915-02-25</issue>
        <issue>1939,1915-02-24</issue>
        <issue>1938,1915-02-23</issue>
        <issue>1937,1915-02-22</issue>
        <issue>1936,1915-02-21</issue>
        <issue>1935,1915-02-19</issue>
        <issue>1934,1915-02-18</issue>
        <issue>1933,1915-02-17</issue>
        <issue>1932,1915-02-16</issue>
        <issue>1931,1915-02-15</issue>
        <issue>1930,1915-02-14</issue>
        <issue>1929,1915-02-12</issue>
        <issue>1928,1915-02-11</issue>
        <issue>1927,1915-02-10</issue>
        <issue>1926,1915-02-09</issue>
        <issue>1925,1915-02-08</issue>
        <issue>1924,1915-02-07</issue>
        <issue>1923,1915-02-05</issue>
        <issue>1922,1915-02-04</issue>
        <issue>1921,1915-02-03</issue>
        <issue>1920,1915-02-02</issue>
        <issue>1919,1915-02-01</issue>
        <issue>1918,1915-01-31</issue>
        <issue>1917,1915-01-29</issue>
        <issue>1916,1915-01-28</issue>
        <issue>1915,1915-01-27</issue>
        <issue>1914,1915-01-26</issue>
        <issue>1913,1915-01-25</issue>
        <issue>1912,1915-01-24</issue>
        <issue>1911,1915-01-22</issue>
        <issue>1910,1915-01-21</issue>
        <issue>1909,1915-01-20</issue>
        <issue>1908,1915-01-19</issue>
        <issue>1907,1915-01-18</issue>
        <issue>1906,1915-01-17</issue>
        <issue>1905,1915-01-15</issue>
        <issue>1904,1915-01-14</issue>
        <issue>1903,1915-01-13</issue>
        <issue>1902,1915-01-12</issue>
        <issue>1901,1915-01-11</issue>
        <issue>1900,1915-01-10</issue>
        <issue>1899,1915-01-08</issue>
        <issue>1898,1915-01-07</issue>
        <issue>1897,1915-01-06</issue>
        <issue>1896,1915-01-05</issue>
        <issue>1895,1915-01-04</issue>
        <issue>1894,1915-01-03</issue>
        <issue>1893,1915-01-01</issue>
        <issue>1892,1914-12-31</issue>
        <issue>1891,1914-12-30</issue>
        <issue>1890,1914-12-29</issue>
        <issue>1889,1914-12-28</issue>
        <issue>1888,1914-12-27</issue>
        <issue>1887,1914-12-25</issue>
        <issue>1886,1914-12-24</issue>
        <issue>1885,1914-12-23</issue>
        <issue>1884,1914-12-22</issue>
        <issue>1883,1914-12-21</issue>
        <issue>1882,1914-12-20</issue>
        <issue>1881,1914-12-18</issue>
        <issue>1880,1914-12-17</issue>
        <issue>1879,1914-12-16</issue>
        <issue>1878,1914-12-15</issue>
        <issue>1877,1914-12-14</issue>
        <issue>1876,1914-12-13</issue>
        <issue>1875,1914-12-11</issue>
        <issue>1874,1914-12-10</issue>
        <issue>1873,1914-12-09</issue>
        <issue>1872,1914-12-08</issue>
        <issue>1871,1914-12-07</issue>
        <issue>1870,1914-12-06</issue>
        <issue>1869,1914-12-04</issue>
        <issue>1868,1914-12-03</issue>
        <issue>1867,1914-12-02</issue>
        <issue>1866,1914-12-01</issue>
        <issue>1865,1914-11-30</issue>
        <issue>1864,1914-11-29</issue>
        <issue>1863,1914-11-27</issue>
        <issue>1862,1914-11-26</issue>
        <issue>1861,1914-11-25</issue>
        <issue>1860,1914-11-24</issue>
        <issue>1859,1914-11-23</issue>
        <issue>1858,1914-11-22</issue>
        <issue>1857,1914-11-20</issue>
        <issue>1856,1914-11-19</issue>
        <issue>1855,1914-11-18</issue>
        <issue>1854,1914-11-17</issue>
        <issue>1853,1914-11-16</issue>
        <issue>1852,1914-11-15</issue>
        <issue>1851,1914-11-13</issue>
        <issue>1850,1914-11-12</issue>
        <issue>1849,1914-11-11</issue>
        <issue>1848,1914-11-10</issue>
        <issue>1847,1914-11-09</issue>
        <issue>1846,1914-11-08</issue>
        <issue>1845,1914-11-06</issue>
        <issue>1844,1914-11-05</issue>
        <issue>1843,1914-11-04</issue>
        <issue>1842,1914-11-03</issue>
        <issue>1841,1914-11-02</issue>
        <issue>1840,1914-11-01</issue>
        <issue>1839,1914-10-30</issue>
        <issue>1838,1914-10-29</issue>
        <issue>1837,1914-10-28</issue>
        <issue>1836,1914-10-27</issue>
        <issue>1835,1914-10-26</issue>
        <issue>1834,1914-10-25</issue>
        <issue>1833,1914-10-23</issue>
        <issue>1832,1914-10-22</issue>
        <issue>1831,1914-10-21</issue>
        <issue>1830,1914-10-20</issue>
        <issue>1829,1914-10-19</issue>
        <issue>1828,1914-10-18</issue>
        <issue>1827,1914-10-16</issue>
        <issue>1826,1914-10-15</issue>
        <issue>1825,1914-10-14</issue>
        <issue>1824,1914-10-13</issue>
        <issue>1823,1914-10-12</issue>
        <issue>1822,1914-10-11</issue>
        <issue>1821,1914-10-09</issue>
        <issue>1820,1914-10-08</issue>
        <issue>1819,1914-10-07</issue>
        <issue>1818,1914-10-06</issue>
        <issue>1817,1914-10-05</issue>
        <issue>1816,1914-10-04</issue>
        <issue>1815,1914-10-02</issue>
        <issue>1814,1914-10-01</issue>
        <issue>1813,1914-09-30</issue>
        <issue>1812,1914-09-29</issue>
        <issue>1811,1914-09-28</issue>
        <issue>1810,1914-09-27</issue>
        <issue>1809,1914-09-25</issue>
        <issue>1808,1914-09-24</issue>
        <issue>1807,1914-09-23</issue>
        <issue>1806,1914-09-22</issue>
        <issue>1805,1914-09-21</issue>
        <issue>1804,1914-09-20</issue>
        <issue>1803,1914-09-18</issue>
        <issue>1802,1914-09-17</issue>
        <issue>1801,1914-09-16</issue>
        <issue>1800,1914-09-15</issue>
        <issue>1799,1914-09-14</issue>
        <issue>1798,1914-09-13</issue>
        <issue>1797,1914-09-11</issue>
        <issue>1796,1914-09-10</issue>
        <issue>1795,1914-09-09</issue>
        <issue>1794,1914-09-08</issue>
        <issue>1793,1914-09-07</issue>
        <issue>1792,1914-09-06</issue>
        <issue>1791,1914-09-04</issue>
        <issue>1790,1914-09-03</issue>
        <issue>1789,1914-09-02</issue>
        <issue>1788,1914-09-01</issue>
        <issue>1787,1914-08-31</issue>
        <issue>1786,1914-08-30</issue>
        <issue>1785,1914-08-28</issue>
        <issue>1784,1914-08-27</issue>
        <issue>1783,1914-08-26</issue>
        <issue>1782,1914-08-25</issue>
        <issue>1781,1914-08-24</issue>
        <issue>1780,1914-08-23</issue>
        <issue>1779,1914-08-21</issue>
        <issue>1778,1914-08-20</issue>
        <issue>1777,1914-08-19</issue>
        <issue>1776,1914-08-18</issue>
        <issue>1775,1914-08-17</issue>
        <issue>1774,1914-08-16</issue>
        <issue>1773,1914-08-14</issue>
        <issue>1772,1914-08-13</issue>
        <issue>1771,1914-08-12</issue>
        <issue>1770,1914-08-11</issue>
        <issue>1769,1914-08-10</issue>
        <issue>1768,1914-08-09</issue>
        <issue>1767,1914-08-07</issue>
        <issue>1766,1914-08-06</issue>
        <issue>1765,1914-08-05</issue>
        <issue>1764,1914-08-04</issue>
        <issue>1763,1914-08-03</issue>
        <issue>1762,1914-08-02</issue>
        <issue>1761,1914-07-31</issue>
        <issue>1760,1914-07-30</issue>
        <issue>1759,1914-07-29</issue>
        <issue>1758,1914-07-28</issue>
        <issue>1757,1914-07-27</issue>
        <issue>1756,1914-07-26</issue>
        <issue>1755,1914-07-24</issue>
        <issue>1754,1914-07-23</issue>
        <issue>1753,1914-07-22</issue>
        <issue>1752,1914-07-21</issue>
        <issue>1751,1914-07-20</issue>
        <issue>1750,1914-07-19</issue>
        <issue>1749,1914-07-17</issue>
        <issue>1748,1914-07-16</issue>
        <issue>1747,1914-07-15</issue>
        <issue>1746,1914-07-14</issue>
        <issue>1745,1914-07-13</issue>
        <issue>1744,1914-07-12</issue>
        <issue>1743,1914-07-10</issue>
        <issue>1742,1914-07-09</issue>
        <issue>1741,1914-07-08</issue>
        <issue>1740,1914-07-07</issue>
        <issue>1739,1914-07-06</issue>
        <issue>1738,1914-07-05</issue>
        <issue>1737,1914-07-03</issue>
        <issue>1736,1914-07-02</issue>
        <issue>1735,1914-07-01</issue>
        <issue>1734,1914-06-30</issue>
        <issue>1733,1914-06-29</issue>
        <issue>1732,1914-06-28</issue>
        <issue>1731,1914-06-26</issue>
        <issue>1730,1914-06-25</issue>
        <issue>1729,1914-06-24</issue>
        <issue>1728,1914-06-23</issue>
        <issue>1727,1914-06-22</issue>
        <issue>1726,1914-06-21</issue>
        <issue>1725,1914-06-19</issue>
        <issue>1724,1914-06-18</issue>
        <issue>1723,1914-06-17</issue>
        <issue>1722,1914-06-16</issue>
        <issue>1721,1914-06-15</issue>
        <issue>1720,1914-06-14</issue>
        <issue>1719,1914-06-12</issue>
        <issue>1718,1914-06-11</issue>
        <issue>1717,1914-06-10</issue>
        <issue>1716,1914-06-09</issue>
        <issue>1715,1914-06-08</issue>
        <issue>1714,1914-06-07</issue>
        <issue>1713,1914-06-05</issue>
        <issue>1712,1914-06-04</issue>
        <issue>1711,1914-06-03</issue>
        <issue>1710,1914-06-02</issue>
        <issue>1709,1914-06-01</issue>
        <issue>1708,1914-05-31</issue>
        <issue>1707,1914-05-29</issue>
        <issue>1706,1914-05-28</issue>
        <issue>1705,1914-05-27</issue>
        <issue>1704,1914-05-26</issue>
        <issue>1703,1914-05-25</issue>
        <issue>1702,1914-05-24</issue>
        <issue>1701,1914-05-22</issue>
        <issue>1700,1914-05-21</issue>
        <issue>1699,1914-05-20</issue>
        <issue>1698,1914-05-19</issue>
        <issue>1697,1914-05-18</issue>
        <issue>1696,1914-05-17</issue>
        <issue>1695,1914-05-15</issue>
        <issue>1694,1914-05-14</issue>
        <issue>1693,1914-05-13</issue>
        <issue>1692,1914-05-12</issue>
        <issue>1691,1914-05-11</issue>
        <issue>1690,1914-05-10</issue>
        <issue>1689,1914-05-08</issue>
        <issue>1688,1914-05-07</issue>
        <issue>1687,1914-05-06</issue>
        <issue>1686,1914-05-05</issue>
        <issue>1685,1914-05-04</issue>
        <issue>1684,1914-05-03</issue>
        <issue>1683,1914-05-01</issue>
        <issue>1682,1914-04-30</issue>
        <issue>1681,1914-04-29</issue>
        <issue>1680,1914-04-28</issue>
        <issue>1679,1914-04-27</issue>
        <issue>1678,1914-04-26</issue>
        <issue>1677,1914-04-24</issue>
        <issue>1676,1914-04-23</issue>
        <issue>1675,1914-04-22</issue>
        <issue>1674,1914-04-21</issue>
        <issue>1673,1914-04-20</issue>
        <issue>1672,1914-04-19</issue>
        <issue>1671,1914-04-17</issue>
        <issue>1670,1914-04-16</issue>
        <issue>1669,1914-04-15</issue>
        <issue>1668,1914-04-14</issue>
        <issue>1667,1914-04-13</issue>
        <issue>1666,1914-04-12</issue>
        <issue>1665,1914-04-10</issue>
        <issue>1664,1914-04-09</issue>
        <issue>1663,1914-04-08</issue>
        <issue>1662,1914-04-07</issue>
        <issue>1661,1914-04-06</issue>
        <issue>1660,1914-04-05</issue>
        <issue>1659,1914-04-03</issue>
        <issue>1658,1914-04-02</issue>
        <issue>1657,1914-04-01</issue>
        <issue>1656,1914-03-31</issue>
        <issue>1655,1914-03-30</issue>
        <issue>1654,1914-03-29</issue>
        <issue>1653,1914-03-27</issue>
        <issue>1652,1914-03-26</issue>
        <issue>1651,1914-03-25</issue>
        <issue>1650,1914-03-24</issue>
        <issue>1649,1914-03-23</issue>
        <issue>1648,1914-03-22</issue>
        <issue>1647,1914-03-20</issue>
        <issue>1646,1914-03-19</issue>
        <issue>1645,1914-03-18</issue>
        <issue>1644,1914-03-17</issue>
        <issue>1643,1914-03-16</issue>
        <issue>1642,1914-03-15</issue>
        <issue>1641,1914-03-13</issue>
        <issue>1640,1914-03-12</issue>
        <issue>1639,1914-03-11</issue>
        <issue>1638,1914-03-10</issue>
        <issue>1637,1914-03-09</issue>
        <issue>1636,1914-03-08</issue>
        <issue>1635,1914-03-06</issue>
        <issue>1634,1914-03-05</issue>
        <issue>1633,1914-03-04</issue>
        <issue>1632,1914-03-03</issue>
        <issue>1631,1914-03-02</issue>
        <issue>1630,1914-03-01</issue>
        <issue>1629,1914-02-27</issue>
        <issue>1628,1914-02-26</issue>
        <issue>1627,1914-02-25</issue>
        <issue>1626,1914-02-24</issue>
        <issue>1625,1914-02-23</issue>
        <issue>1624,1914-02-22</issue>
        <issue>1623,1914-02-20</issue>
        <issue>1622,1914-02-19</issue>
        <issue>1621,1914-02-18</issue>
        <issue>1620,1914-02-17</issue>
        <issue>1619,1914-02-16</issue>
        <issue>1618,1914-02-15</issue>
        <issue>1617,1914-02-13</issue>
        <issue>1616,1914-02-12</issue>
        <issue>1615,1914-02-11</issue>
        <issue>1614,1914-02-10</issue>
        <issue>1613,1914-02-09</issue>
        <issue>1612,1914-02-08</issue>
        <issue>1611,1914-02-06</issue>
        <issue>1610,1914-02-05</issue>
        <issue>1609,1914-02-04</issue>
        <issue>1608,1914-02-03</issue>
        <issue>1607,1914-02-02</issue>
        <issue>1606,1914-02-01</issue>
        <issue>1605,1914-01-30</issue>
        <issue>1604,1914-01-29</issue>
        <issue>1603,1914-01-28</issue>
        <issue>1602,1914-01-27</issue>
        <issue>1601,1914-01-26</issue>
        <issue>1600,1914-01-25</issue>
        <issue>1599,1914-01-23</issue>
        <issue>1598,1914-01-22</issue>
        <issue>1597,1914-01-21</issue>
        <issue>1596,1914-01-20</issue>
        <issue>1595,1914-01-19</issue>
        <issue>1594,1914-01-18</issue>
        <issue>1593,1914-01-16</issue>
        <issue>1592,1914-01-15</issue>
        <issue>1591,1914-01-14</issue>
        <issue>1590,1914-01-13</issue>
        <issue>1589,1914-01-12</issue>
        <issue>1588,1914-01-11</issue>
        <issue>1587,1914-01-09</issue>
        <issue>1586,1914-01-08</issue>
        <issue>1585,1914-01-07</issue>
        <issue>1584,1914-01-06</issue>
        <issue>1583,1914-01-05</issue>
        <issue>1582,1914-01-04</issue>
        <issue>1581,1914-01-02</issue>
        <issue>1580,1914-01-01</issue>
        <issue>1579,1913-12-31</issue>
        <issue>1578,1913-12-30</issue>
        <issue>1577,1913-12-29</issue>
        <issue>1576,1913-12-28</issue>
        <issue>1575,1913-12-26</issue>
        <issue>1574,1913-12-25</issue>
        <issue>1573,1913-12-24</issue>
        <issue>1572,1913-12-23</issue>
        <issue>1571,1913-12-22</issue>
        <issue>1570,1913-12-21</issue>
        <issue>1569,1913-12-19</issue>
        <issue>1568,1913-12-18</issue>
        <issue>1567,1913-12-17</issue>
        <issue>1566,1913-12-16</issue>
        <issue>1565,1913-12-15</issue>
        <issue>1564,1913-12-14</issue>
        <issue>1563,1913-12-12</issue>
        <issue>1562,1913-12-11</issue>
        <issue>1561,1913-12-10</issue>
        <issue>1560,1913-12-09</issue>
        <issue>1559,1913-12-08</issue>
        <issue>1558,1913-12-07</issue>
        <issue>1557,1913-12-05</issue>
        <issue>1556,1913-12-04</issue>
        <issue>1555,1913-12-03</issue>
        <issue>1554,1913-12-02</issue>
        <issue>1553,1913-12-01</issue>
        <issue>1552,1913-11-30</issue>
        <issue>1551,1913-11-28</issue>
        <issue>1550,1913-11-27</issue>
        <issue>1549,1913-11-26</issue>
        <issue>1548,1913-11-25</issue>
        <issue>1547,1913-11-24</issue>
        <issue>1546,1913-11-23</issue>
        <issue>1545,1913-11-21</issue>
        <issue>1544,1913-11-20</issue>
        <issue>1543,1913-11-19</issue>
        <issue>1542,1913-11-18</issue>
        <issue>1541,1913-11-17</issue>
        <issue>1540,1913-11-16</issue>
        <issue>1539,1913-11-14</issue>
        <issue>1538,1913-11-13</issue>
        <issue>1537,1913-11-12</issue>
        <issue>1536,1913-11-11</issue>
        <issue>1535,1913-11-10</issue>
        <issue>1534,1913-11-09</issue>
        <issue>1533,1913-11-07</issue>
        <issue>1532,1913-11-06</issue>
        <issue>1531,1913-11-05</issue>
        <issue>1530,1913-11-04</issue>
        <issue>1529,1913-11-03</issue>
        <issue>1528,1913-11-02</issue>
        <issue>1527,1913-10-31</issue>
        <issue>1526,1913-10-30</issue>
        <issue>1525,1913-10-29</issue>
        <issue>1524,1913-10-28</issue>
        <issue>1523,1913-10-27</issue>
        <issue>1522,1913-10-26</issue>
        <issue>1521,1913-10-24</issue>
        <issue>1520,1913-10-23</issue>
        <issue>1519,1913-10-22</issue>
        <issue>1518,1913-10-21</issue>
        <issue>1517,1913-10-20</issue>
        <issue>1516,1913-10-19</issue>
        <issue>1515,1913-10-17</issue>
        <issue>1514,1913-10-16</issue>
        <issue>1513,1913-10-15</issue>
        <issue>1512,1913-10-14</issue>
        <issue>1511,1913-10-13</issue>
        <issue>1510,1913-10-12</issue>
        <issue>1509,1913-10-10</issue>
        <issue>1508,1913-10-09</issue>
        <issue>1507,1913-10-08</issue>
        <issue>1506,1913-10-07</issue>
        <issue>1505,1913-10-06</issue>
        <issue>1504,1913-10-05</issue>
        <issue>1503,1913-10-03</issue>
        <issue>1502,1913-10-02</issue>
        <issue>1501,1913-10-01</issue>
        <issue>1500,1913-09-30</issue>
        <issue>1499,1913-09-29</issue>
        <issue>1498,1913-09-28</issue>
        <issue>1497,1913-09-26</issue>
        <issue>1496,1913-09-25</issue>
        <issue>1495,1913-09-24</issue>
        <issue>1494,1913-09-23</issue>
        <issue>1493,1913-09-22</issue>
        <issue>1492,1913-09-21</issue>
        <issue>1491,1913-09-19</issue>
        <issue>1490,1913-09-18</issue>
        <issue>1489,1913-09-17</issue>
        <issue>1488,1913-09-16</issue>
        <issue>1487,1913-09-15</issue>
        <issue>1486,1913-09-14</issue>
        <issue>1485,1913-09-12</issue>
        <issue>1484,1913-09-11</issue>
        <issue>1483,1913-09-10</issue>
        <issue>1482,1913-09-09</issue>
        <issue>1481,1913-09-08</issue>
        <issue>1480,1913-09-07</issue>
        <issue>1479,1913-09-05</issue>
        <issue>1478,1913-09-04</issue>
        <issue>1477,1913-09-03</issue>
        <issue>1476,1913-09-02</issue>
        <issue>1475,1913-09-01</issue>
        <issue>1474,1913-08-31</issue>
        <issue>1473,1913-08-29</issue>
        <issue>1472,1913-08-28</issue>
        <issue>1471,1913-08-27</issue>
        <issue>1470,1913-08-26</issue>
        <issue>1469,1913-08-25</issue>
        <issue>1468,1913-08-24</issue>
        <issue>1467,1913-08-22</issue>
        <issue>1466,1913-08-21</issue>
        <issue>1465,1913-08-20</issue>
        <issue>1464,1913-08-19</issue>
        <issue>1463,1913-08-18</issue>
        <issue>1462,1913-08-17</issue>
        <issue>1461,1913-08-15</issue>
        <issue>1460,1913-08-14</issue>
        <issue>1459,1913-08-13</issue>
        <issue>1458,1913-08-12</issue>
        <issue>1457,1913-08-11</issue>
        <issue>1456,1913-08-10</issue>
        <issue>1455,1913-08-08</issue>
        <issue>1454,1913-08-07</issue>
        <issue>1453,1913-08-06</issue>
        <issue>1452,1913-08-05</issue>
        <issue>1451,1913-08-04</issue>
        <issue>1450,1913-08-03</issue>
        <issue>1449,1913-08-01</issue>
        <issue>1448,1913-07-31</issue>
        <issue>1447,1913-07-30</issue>
        <issue>1446,1913-07-29</issue>
        <issue>1445,1913-07-28</issue>
        <issue>1444,1913-07-27</issue>
        <issue>1443,1913-07-25</issue>
        <issue>1442,1913-07-24</issue>
        <issue>1441,1913-07-23</issue>
        <issue>1440,1913-07-22</issue>
        <issue>1439,1913-07-21</issue>
        <issue>1438,1913-07-20</issue>
        <issue>1437,1913-07-18</issue>
        <issue>1436,1913-07-17</issue>
        <issue>1435,1913-07-16</issue>
        <issue>1434,1913-07-15</issue>
        <issue>1433,1913-07-14</issue>
        <issue>1432,1913-07-13</issue>
        <issue>1431,1913-07-11</issue>
        <issue>1430,1913-07-10</issue>
        <issue>1429,1913-07-09</issue>
        <issue>1428,1913-07-08</issue>
        <issue>1427,1913-07-07</issue>
        <issue>1426,1913-07-06</issue>
        <issue>1425,1913-07-04</issue>
        <issue>1424,1913-07-03</issue>
        <issue>1423,1913-07-02</issue>
        <issue>1422,1913-07-01</issue>
        <issue>1421,1913-06-30</issue>
        <issue>1420,1913-06-29</issue>
        <issue>1419,1913-06-27</issue>
        <issue>1418,1913-06-26</issue>
        <issue>1417,1913-06-25</issue>
        <issue>1416,1913-06-24</issue>
        <issue>1415,1913-06-23</issue>
        <issue>1414,1913-06-22</issue>
        <issue>1413,1913-06-20</issue>
        <issue>1412,1913-06-19</issue>
        <issue>1411,1913-06-18</issue>
        <issue>1410,1913-06-17</issue>
        <issue>1409,1913-06-16</issue>
        <issue>1408,1913-06-15</issue>
        <issue>1407,1913-06-13</issue>
        <issue>1406,1913-06-12</issue>
        <issue>1405,1913-06-11</issue>
        <issue>1404,1913-06-10</issue>
        <issue>1403,1913-06-09</issue>
        <issue>1402,1913-06-08</issue>
        <issue>1401,1913-06-06</issue>
        <issue>1400,1913-06-05</issue>
        <issue>1399,1913-06-04</issue>
        <issue>1398,1913-06-03</issue>
        <issue>1397,1913-06-02</issue>
        <issue>1396,1913-06-01</issue>
        <issue>1395,1913-05-30</issue>
        <issue>1394,1913-05-29</issue>
        <issue>1393,1913-05-28</issue>
        <issue>1392,1913-05-27</issue>
        <issue>1391,1913-05-26</issue>
        <issue>1390,1913-05-25</issue>
        <issue>1389,1913-05-23</issue>
        <issue>1388,1913-05-22</issue>
        <issue>1387,1913-05-21</issue>
        <issue>1386,1913-05-20</issue>
        <issue>1385,1913-05-19</issue>
        <issue>1384,1913-05-18</issue>
        <issue>1383,1913-05-16</issue>
        <issue>1382,1913-05-15</issue>
        <issue>1381,1913-05-14</issue>
        <issue>1380,1913-05-13</issue>
        <issue>1379,1913-05-12</issue>
        <issue>1378,1913-05-11</issue>
        <issue>1377,1913-05-09</issue>
        <issue>1376,1913-05-08</issue>
        <issue>1375,1913-05-07</issue>
        <issue>1374,1913-05-06</issue>
        <issue>1373,1913-05-05</issue>
        <issue>1372,1913-05-04</issue>
        <issue>1371,1913-05-02</issue>
        <issue>1370,1913-05-01</issue>
        <issue>1369,1913-04-30</issue>
        <issue>1368,1913-04-29</issue>
        <issue>1367,1913-04-28</issue>
        <issue>1366,1913-04-27</issue>
        <issue>1365,1913-04-25</issue>
        <issue>1364,1913-04-24</issue>
        <issue>1363,1913-04-23</issue>
        <issue>1362,1913-04-22</issue>
        <issue>1361,1913-04-21</issue>
        <issue>1360,1913-04-20</issue>
        <issue>1359,1913-04-18</issue>
        <issue>1358,1913-04-17</issue>
        <issue>1357,1913-04-16</issue>
        <issue>1356,1913-04-15</issue>
        <issue>1355,1913-04-14</issue>
        <issue>1354,1913-04-13</issue>
        <issue>1353,1913-04-11</issue>
        <issue>1352,1913-04-10</issue>
        <issue>1351,1913-04-09</issue>
        <issue>1350,1913-04-08</issue>
        <issue>1349,1913-04-07</issue>
        <issue>1348,1913-04-06</issue>
        <issue>1347,1913-04-04</issue>
        <issue>1346,1913-04-03</issue>
        <issue>1345,1913-04-02</issue>
        <issue>1344,1913-04-01</issue>
        <issue>1343,1913-03-31</issue>
        <issue>1342,1913-03-30</issue>
        <issue>1341,1913-03-28</issue>
        <issue>1340,1913-03-27</issue>
        <issue>1339,1913-03-26</issue>
        <issue>1338,1913-03-25</issue>
        <issue>1337,1913-03-24</issue>
        <issue>1336,1913-03-23</issue>
        <issue>1335,1913-03-21</issue>
        <issue>1334,1913-03-20</issue>
        <issue>1333,1913-03-19</issue>
        <issue>1332,1913-03-18</issue>
        <issue>1331,1913-03-17</issue>
        <issue>1330,1913-03-16</issue>
        <issue>1329,1913-03-14</issue>
        <issue>1328,1913-03-13</issue>
        <issue>1327,1913-03-12</issue>
        <issue>1326,1913-03-11</issue>
        <issue>1325,1913-03-10</issue>
        <issue>1324,1913-03-09</issue>
        <issue>1323,1913-03-07</issue>
        <issue>1322,1913-03-06</issue>
        <issue>1321,1913-03-05</issue>
        <issue>1320,1913-03-04</issue>
        <issue>1319,1913-03-03</issue>
        <issue>1318,1913-03-02</issue>
        <issue>1317,1913-02-28</issue>
        <issue>1316,1913-02-27</issue>
        <issue>1315,1913-02-26</issue>
        <issue>1314,1913-02-25</issue>
        <issue>1313,1913-02-24</issue>
        <issue>1312,1913-02-23</issue>
        <issue>1311,1913-02-21</issue>
        <issue>1310,1913-02-20</issue>
        <issue>1309,1913-02-19</issue>
        <issue>1308,1913-02-18</issue>
        <issue>1307,1913-02-17</issue>
        <issue>1306,1913-02-16</issue>
        <issue>1305,1913-02-14</issue>
        <issue>1304,1913-02-13</issue>
        <issue>1303,1913-02-12</issue>
        <issue>1302,1913-02-11</issue>
        <issue>1301,1913-02-10</issue>
        <issue>1300,1913-02-09</issue>
        <issue>1299,1913-02-07</issue>
        <issue>1298,1913-02-06</issue>
        <issue>1297,1913-02-05</issue>
        <issue>1296,1913-02-04</issue>
        <issue>1295,1913-02-03</issue>
        <issue>1294,1913-02-02</issue>
        <issue>1293,1913-01-31</issue>
        <issue>1292,1913-01-30</issue>
        <issue>1291,1913-01-29</issue>
        <issue>1290,1913-01-28</issue>
        <issue>1289,1913-01-27</issue>
        <issue>1288,1913-01-26</issue>
        <issue>1287,1913-01-24</issue>
        <issue>1286,1913-01-23</issue>
        <issue>1285,1913-01-22</issue>
        <issue>1284,1913-01-21</issue>
        <issue>1283,1913-01-20</issue>
        <issue>1282,1913-01-19</issue>
        <issue>1281,1913-01-17</issue>
        <issue>1280,1913-01-16</issue>
        <issue>1279,1913-01-15</issue>
        <issue>1278,1913-01-14</issue>
        <issue>1277,1913-01-13</issue>
        <issue>1276,1913-01-12</issue>
        <issue>1275,1913-01-10</issue>
        <issue>1274,1913-01-09</issue>
        <issue>1273,1913-01-08</issue>
        <issue>1272,1913-01-07</issue>
        <issue>1271,1913-01-06</issue>
        <issue>1270,1913-01-05</issue>
        <issue>1269,1913-01-03</issue>
        <issue>1268,1913-01-02</issue>
        <issue>1267,1913-01-01</issue>
        <issue>1266,1912-12-31</issue>
        <issue>1265,1912-12-30</issue>
        <issue>1264,1912-12-29</issue>
        <issue>1263,1912-12-27</issue>
        <issue>1262,1912-12-26</issue>
        <issue>1261,1912-12-25</issue>
        <issue>1260,1912-12-24</issue>
        <issue>1259,1912-12-23</issue>
        <issue>1258,1912-12-22</issue>
        <issue>1257,1912-12-20</issue>
        <issue>1256,1912-12-19</issue>
        <issue>1255,1912-12-18</issue>
        <issue>1254,1912-12-17</issue>
        <issue>1253,1912-12-16</issue>
        <issue>1252,1912-12-15</issue>
        <issue>1251,1912-12-13</issue>
        <issue>1250,1912-12-12</issue>
        <issue>1249,1912-12-11</issue>
        <issue>1248,1912-12-10</issue>
        <issue>1247,1912-12-09</issue>
        <issue>1246,1912-12-08</issue>
        <issue>1245,1912-12-06</issue>
        <issue>1244,1912-12-05</issue>
        <issue>1243,1912-12-04</issue>
        <issue>1242,1912-12-03</issue>
        <issue>1241,1912-12-02</issue>
        <issue>1240,1912-12-01</issue>
        <issue>1239,1912-11-29</issue>
        <issue>1238,1912-11-28</issue>
        <issue>1237,1912-11-27</issue>
        <issue>1236,1912-11-26</issue>
        <issue>1235,1912-11-25</issue>
        <issue>1234,1912-11-24</issue>
        <issue>1233,1912-11-22</issue>
        <issue>1232,1912-11-21</issue>
        <issue>1231,1912-11-20</issue>
        <issue>1230,1912-11-19</issue>
        <issue>1229,1912-11-18</issue>
        <issue>1228,1912-11-17</issue>
        <issue>1227,1912-11-15</issue>
        <issue>1226,1912-11-14</issue>
        <issue>1225,1912-11-13</issue>
        <issue>1224,1912-11-12</issue>
        <issue>1223,1912-11-11</issue>
        <issue>1222,1912-11-10</issue>
        <issue>1221,1912-11-08</issue>
        <issue>1220,1912-11-07</issue>
        <issue>1219,1912-11-06</issue>
        <issue>1218,1912-11-05</issue>
        <issue>1217,1912-11-04</issue>
        <issue>1216,1912-11-03</issue>
        <issue>1215,1912-11-01</issue>
        <issue>1214,1912-10-31</issue>
        <issue>1213,1912-10-30</issue>
        <issue>1212,1912-10-29</issue>
        <issue>1211,1912-10-28</issue>
        <issue>1210,1912-10-27</issue>
        <issue>1209,1912-10-25</issue>
        <issue>1208,1912-10-24</issue>
        <issue>1207,1912-10-23</issue>
        <issue>1206,1912-10-22</issue>
        <issue>1205,1912-10-21</issue>
        <issue>1204,1912-10-20</issue>
        <issue>1203,1912-10-18</issue>
        <issue>1202,1912-10-17</issue>
        <issue>1201,1912-10-16</issue>
        <issue>1200,1912-10-15</issue>
        <issue>1199,1912-10-14</issue>
        <issue>1198,1912-10-13</issue>
        <issue>1197,1912-10-11</issue>
        <issue>1196,1912-10-10</issue>
        <issue>1195,1912-10-09</issue>
        <issue>1194,1912-10-08</issue>
        <issue>1193,1912-10-07</issue>
        <issue>1192,1912-10-06</issue>
        <issue>1191,1912-10-04</issue>
        <issue>1190,1912-10-03</issue>
        <issue>1189,1912-10-02</issue>
        <issue>1188,1912-10-01</issue>
        <issue>1187,1912-09-30</issue>
        <issue>1186,1912-09-29</issue>
        <issue>1185,1912-09-27</issue>
        <issue>1184,1912-09-26</issue>
        <issue>1183,1912-09-25</issue>
        <issue>1182,1912-09-24</issue>
        <issue>1181,1912-09-23</issue>
        <issue>1180,1912-09-22</issue>
        <issue>1179,1912-09-20</issue>
        <issue>1178,1912-09-19</issue>
        <issue>1177,1912-09-18</issue>
        <issue>1176,1912-09-17</issue>
        <issue>1175,1912-09-16</issue>
        <issue>1174,1912-09-15</issue>
        <issue>1173,1912-09-13</issue>
        <issue>1172,1912-09-12</issue>
        <issue>1171,1912-09-11</issue>
        <issue>1170,1912-09-10</issue>
        <issue>1169,1912-09-09</issue>
        <issue>1168,1912-09-08</issue>
        <issue>1167,1912-09-06</issue>
        <issue>1166,1912-09-05</issue>
        <issue>1165,1912-09-04</issue>
        <issue>1164,1912-09-03</issue>
        <issue>1163,1912-09-02</issue>
        <issue>1162,1912-09-01</issue>
        <issue>1161,1912-08-30</issue>
        <issue>1160,1912-08-29</issue>
        <issue>1159,1912-08-28</issue>
        <issue>1158,1912-08-27</issue>
        <issue>1157,1912-08-26</issue>
        <issue>1156,1912-08-25</issue>
        <issue>1155,1912-08-23</issue>
        <issue>1154,1912-08-22</issue>
        <issue>1153,1912-08-21</issue>
        <issue>1152,1912-08-20</issue>
        <issue>1151,1912-08-19</issue>
        <issue>1150,1912-08-18</issue>
        <issue>1149,1912-08-16</issue>
        <issue>1148,1912-08-15</issue>
        <issue>1147,1912-08-14</issue>
        <issue>1146,1912-08-13</issue>
        <issue>1145,1912-08-12</issue>
        <issue>1144,1912-08-11</issue>
        <issue>1143,1912-08-09</issue>
        <issue>1142,1912-08-08</issue>
        <issue>1141,1912-08-07</issue>
        <issue>1140,1912-08-06</issue>
        <issue>1139,1912-08-05</issue>
        <issue>1138,1912-08-04</issue>
        <issue>1137,1912-08-02</issue>
        <issue>1136,1912-08-01</issue>
        <issue>1135,1912-07-31</issue>
        <issue>1134,1912-07-30</issue>
        <issue>1133,1912-07-29</issue>
        <issue>1132,1912-07-28</issue>
        <issue>1131,1912-07-26</issue>
        <issue>1130,1912-07-25</issue>
        <issue>1129,1912-07-24</issue>
        <issue>1128,1912-07-23</issue>
        <issue>1127,1912-07-22</issue>
        <issue>1126,1912-07-21</issue>
        <issue>1125,1912-07-19</issue>
        <issue>1124,1912-07-18</issue>
        <issue>1123,1912-07-17</issue>
        <issue>1122,1912-07-16</issue>
        <issue>1121,1912-07-15</issue>
        <issue>1120,1912-07-14</issue>
        <issue>1119,1912-07-12</issue>
        <issue>1118,1912-07-11</issue>
        <issue>1117,1912-07-10</issue>
        <issue>1116,1912-07-09</issue>
        <issue>1115,1912-07-08</issue>
        <issue>1114,1912-07-07</issue>
        <issue>1113,1912-07-05</issue>
        <issue>1112,1912-07-04</issue>
        <issue>1111,1912-07-03</issue>
        <issue>1110,1912-07-02</issue>
        <issue>1109,1912-07-01</issue>
        <issue>1108,1912-06-30</issue>
        <issue>1107,1912-06-28</issue>
        <issue>1106,1912-06-27</issue>
        <issue>1105,1912-06-26</issue>
        <issue>1104,1912-06-25</issue>
        <issue>1103,1912-06-24</issue>
        <issue>1102,1912-06-23</issue>
        <issue>1101,1912-06-21</issue>
        <issue>1100,1912-06-20</issue>
        <issue>1099,1912-06-19</issue>
        <issue>1098,1912-06-18</issue>
        <issue>1097,1912-06-17</issue>
        <issue>1096,1912-06-16</issue>
        <issue>1095,1912-06-14</issue>
        <issue>1094,1912-06-13</issue>
        <issue>1093,1912-06-12</issue>
        <issue>1092,1912-06-11</issue>
        <issue>1091,1912-06-10</issue>
        <issue>1090,1912-06-09</issue>
        <issue>1089,1912-06-07</issue>
        <issue>1088,1912-06-06</issue>
        <issue>1087,1912-06-05</issue>
        <issue>1086,1912-06-04</issue>
        <issue>1085,1912-06-03</issue>
        <issue>1084,1912-06-02</issue>
        <issue>1083,1912-05-31</issue>
        <issue>1082,1912-05-30</issue>
        <issue>1081,1912-05-29</issue>
        <issue>1080,1912-05-28</issue>
        <issue>1079,1912-05-27</issue>
        <issue>1078,1912-05-26</issue>
        <issue>1077,1912-05-24</issue>
        <issue>1076,1912-05-23</issue>
        <issue>1075,1912-05-22</issue>
        <issue>1074,1912-05-21</issue>
        <issue>1073,1912-05-20</issue>
        <issue>1072,1912-05-19</issue>
        <issue>1071,1912-05-17</issue>
        <issue>1070,1912-05-16</issue>
        <issue>1069,1912-05-15</issue>
        <issue>1068,1912-05-14</issue>
        <issue>1067,1912-05-13</issue>
        <issue>1066,1912-05-12</issue>
        <issue>1065,1912-05-10</issue>
        <issue>1064,1912-05-09</issue>
        <issue>1063,1912-05-08</issue>
        <issue>1062,1912-05-07</issue>
        <issue>1061,1912-05-06</issue>
        <issue>1060,1912-05-05</issue>
        <issue>1059,1912-05-03</issue>
        <issue>1058,1912-05-02</issue>
        <issue>1057,1912-05-01</issue>
        <issue>1056,1912-04-30</issue>
        <issue>1055,1912-04-29</issue>
        <issue>1054,1912-04-28</issue>
        <issue>1053,1912-04-26</issue>
        <issue>1052,1912-04-25</issue>
        <issue>1051,1912-04-24</issue>
        <issue>1050,1912-04-23</issue>
        <issue>1049,1912-04-22</issue>
        <issue>1048,1912-04-21</issue>
        <issue>1047,1912-04-19</issue>
        <issue>1046,1912-04-18</issue>
        <issue>1045,1912-04-17</issue>
        <issue>1044,1912-04-16</issue>
        <issue>1043,1912-04-15</issue>
        <issue>1042,1912-04-14</issue>
        <issue>1041,1912-04-12</issue>
        <issue>1040,1912-04-11</issue>
        <issue>1039,1912-04-10</issue>
        <issue>1038,1912-04-09</issue>
        <issue>1037,1912-04-08</issue>
        <issue>1036,1912-04-07</issue>
        <issue>1035,1912-04-05</issue>
        <issue>1034,1912-04-04</issue>
        <issue>1033,1912-04-03</issue>
        <issue>1032,1912-04-02</issue>
        <issue>1031,1912-04-01</issue>
        <issue>1030,1912-03-31</issue>
        <issue>1029,1912-03-29</issue>
        <issue>1028,1912-03-28</issue>
        <issue>1027,1912-03-27</issue>
        <issue>1026,1912-03-26</issue>
        <issue>1025,1912-03-25</issue>
        <issue>1024,1912-03-24</issue>
        <issue>1023,1912-03-22</issue>
        <issue>1022,1912-03-21</issue>
        <issue>1021,1912-03-20</issue>
        <issue>1020,1912-03-19</issue>
        <issue>1019,1912-03-18</issue>
        <issue>1018,1912-03-17</issue>
        <issue>1017,1912-03-15</issue>
        <issue>1016,1912-03-14</issue>
        <issue>1015,1912-03-13</issue>
        <issue>1014,1912-03-12</issue>
        <issue>1013,1912-03-11</issue>
        <issue>1012,1912-03-10</issue>
        <issue>1011,1912-03-08</issue>
        <issue>1010,1912-03-07</issue>
        <issue>1009,1912-03-06</issue>
        <issue>1008,1912-03-05</issue>
        <issue>1007,1912-03-04</issue>
        <issue>1006,1912-03-03</issue>
        <issue>1005,1912-03-01</issue>
        <issue>1004,1912-02-29</issue>
        <issue>1003,1912-02-28</issue>
        <issue>1002,1912-02-27</issue>
        <issue>1001,1912-02-26</issue>
        <issue>1000,1912-02-25</issue>
        <issue>999,1912-02-23</issue>
        <issue>998,1912-02-22</issue>
        <issue>997,1912-02-21</issue>
        <issue>996,1912-02-20</issue>
        <issue>995,1912-02-19</issue>
        <issue>994,1912-02-18</issue>
        <issue>993,1912-02-16</issue>
        <issue>992,1912-02-15</issue>
        <issue>991,1912-02-14</issue>
        <issue>990,1912-02-13</issue>
        <issue>989,1912-02-12</issue>
        <issue>988,1912-02-11</issue>
        <issue>987,1912-02-09</issue>
        <issue>986,1912-02-08</issue>
        <issue>985,1912-02-07</issue>
        <issue>984,1912-02-06</issue>
        <issue>983,1912-02-05</issue>
        <issue>982,1912-02-04</issue>
        <issue>981,1912-02-02</issue>
        <issue>980,1912-02-01</issue>
        <issue>979,1912-01-31</issue>
        <issue>978,1912-01-30</issue>
        <issue>977,1912-01-29</issue>
        <issue>976,1912-01-28</issue>
        <issue>975,1912-01-26</issue>
        <issue>974,1912-01-25</issue>
        <issue>973,1912-01-24</issue>
        <issue>972,1912-01-23</issue>
        <issue>971,1912-01-22</issue>
        <issue>970,1912-01-21</issue>
        <issue>969,1912-01-19</issue>
        <issue>968,1912-01-18</issue>
        <issue>967,1912-01-17</issue>
        <issue>966,1912-01-16</issue>
        <issue>965,1912-01-15</issue>
        <issue>964,1912-01-14</issue>
        <issue>963,1912-01-12</issue>
        <issue>962,1912-01-11</issue>
        <issue>961,1912-01-10</issue>
        <issue>960,1912-01-09</issue>
        <issue>959,1912-01-08</issue>
        <issue>958,1912-01-07</issue>
        <issue>957,1912-01-05</issue>
        <issue>956,1912-01-04</issue>
        <issue>955,1912-01-03</issue>
        <issue>954,1912-01-02</issue>
        <issue>953,1912-01-01</issue>
        <issue>952,1911-12-31</issue>
        <issue>951,1911-12-29</issue>
        <issue>950,1911-12-28</issue>
        <issue>949,1911-12-27</issue>
        <issue>948,1911-12-26</issue>
        <issue>947,1911-12-25</issue>
        <issue>946,1911-12-24</issue>
        <issue>945,1911-12-22</issue>
        <issue>944,1911-12-21</issue>
        <issue>943,1911-12-20</issue>
        <issue>942,1911-12-19</issue>
        <issue>941,1911-12-18</issue>
        <issue>940,1911-12-17</issue>
        <issue>939,1911-12-15</issue>
        <issue>938,1911-12-14</issue>
        <issue>937,1911-12-13</issue>
        <issue>936,1911-12-12</issue>
        <issue>935,1911-12-11</issue>
        <issue>934,1911-12-10</issue>
        <issue>933,1911-12-08</issue>
        <issue>932,1911-12-07</issue>
        <issue>931,1911-12-06</issue>
        <issue>930,1911-12-05</issue>
        <issue>929,1911-12-04</issue>
        <issue>928,1911-12-03</issue>
        <issue>927,1911-12-01</issue>
        <issue>926,1911-11-30</issue>
        <issue>925,1911-11-29</issue>
        <issue>924,1911-11-28</issue>
        <issue>923,1911-11-27</issue>
        <issue>922,1911-11-26</issue>
        <issue>921,1911-11-24</issue>
        <issue>920,1911-11-23</issue>
        <issue>919,1911-11-22</issue>
        <issue>918,1911-11-21</issue>
        <issue>917,1911-11-20</issue>
        <issue>916,1911-11-19</issue>
        <issue>915,1911-11-17</issue>
        <issue>914,1911-11-16</issue>
        <issue>913,1911-11-15</issue>
        <issue>912,1911-11-14</issue>
        <issue>911,1911-11-13</issue>
        <issue>910,1911-11-12</issue>
        <issue>909,1911-11-10</issue>
        <issue>908,1911-11-09</issue>
        <issue>907,1911-11-08</issue>
        <issue>906,1911-11-07</issue>
        <issue>905,1911-11-06</issue>
        <issue>904,1911-11-05</issue>
        <issue>903,1911-11-03</issue>
        <issue>902,1911-11-02</issue>
        <issue>901,1911-11-01</issue>
        <issue>900,1911-10-31</issue>
        <issue>899,1911-10-30</issue>
        <issue>898,1911-10-29</issue>
        <issue>897,1911-10-27</issue>
        <issue>896,1911-10-26</issue>
        <issue>895,1911-10-25</issue>
        <issue>894,1911-10-24</issue>
        <issue>893,1911-10-23</issue>
        <issue>892,1911-10-22</issue>
        <issue>891,1911-10-20</issue>
        <issue>890,1911-10-19</issue>
        <issue>889,1911-10-18</issue>
        <issue>888,1911-10-17</issue>
        <issue>887,1911-10-16</issue>
        <issue>886,1911-10-15</issue>
        <issue>885,1911-10-13</issue>
        <issue>884,1911-10-12</issue>
        <issue>883,1911-10-11</issue>
        <issue>882,1911-10-10</issue>
        <issue>881,1911-10-09</issue>
        <issue>880,1911-10-08</issue>
        <issue>879,1911-10-06</issue>
        <issue>878,1911-10-05</issue>
        <issue>877,1911-10-04</issue>
        <issue>876,1911-10-03</issue>
        <issue>875,1911-10-02</issue>
        <issue>874,1911-10-01</issue>
        <issue>873,1911-09-29</issue>
        <issue>872,1911-09-28</issue>
        <issue>871,1911-09-27</issue>
        <issue>870,1911-09-26</issue>
        <issue>869,1911-09-25</issue>
        <issue>868,1911-09-24</issue>
        <issue>867,1911-09-22</issue>
        <issue>866,1911-09-21</issue>
        <issue>865,1911-09-20</issue>
        <issue>864,1911-09-19</issue>
        <issue>863,1911-09-18</issue>
        <issue>862,1911-09-17</issue>
        <issue>861,1911-09-15</issue>
        <issue>860,1911-09-14</issue>
        <issue>859,1911-09-13</issue>
        <issue>858,1911-09-12</issue>
        <issue>857,1911-09-11</issue>
        <issue>856,1911-09-10</issue>
        <issue>855,1911-09-08</issue>
        <issue>854,1911-09-07</issue>
        <issue>853,1911-09-06</issue>
        <issue>852,1911-09-05</issue>
        <issue>851,1911-09-04</issue>
        <issue>850,1911-09-03</issue>
        <issue>849,1911-09-01</issue>
        <issue>848,1911-08-31</issue>
        <issue>847,1911-08-30</issue>
        <issue>846,1911-08-29</issue>
        <issue>845,1911-08-28</issue>
        <issue>844,1911-08-27</issue>
        <issue>843,1911-08-25</issue>
        <issue>842,1911-08-24</issue>
        <issue>841,1911-08-23</issue>
        <issue>840,1911-08-22</issue>
        <issue>839,1911-08-21</issue>
        <issue>838,1911-08-20</issue>
        <issue>837,1911-08-18</issue>
        <issue>836,1911-08-17</issue>
        <issue>835,1911-08-16</issue>
        <issue>834,1911-08-15</issue>
        <issue>833,1911-08-14</issue>
        <issue>832,1911-08-13</issue>
        <issue>831,1911-08-11</issue>
        <issue>830,1911-08-10</issue>
        <issue>829,1911-08-09</issue>
        <issue>828,1911-08-08</issue>
        <issue>827,1911-08-07</issue>
        <issue>826,1911-08-06</issue>
        <issue>825,1911-08-04</issue>
        <issue>824,1911-08-03</issue>
        <issue>823,1911-08-02</issue>
        <issue>822,1911-08-01</issue>
        <issue>821,1911-07-31</issue>
        <issue>820,1911-07-30</issue>
        <issue>819,1911-07-28</issue>
        <issue>818,1911-07-27</issue>
        <issue>817,1911-07-26</issue>
        <issue>816,1911-07-25</issue>
        <issue>815,1911-07-24</issue>
        <issue>814,1911-07-23</issue>
        <issue>813,1911-07-21</issue>
        <issue>812,1911-07-20</issue>
        <issue>811,1911-07-19</issue>
        <issue>810,1911-07-18</issue>
        <issue>809,1911-07-17</issue>
        <issue>808,1911-07-16</issue>
        <issue>807,1911-07-14</issue>
        <issue>806,1911-07-13</issue>
        <issue>805,1911-07-12</issue>
        <issue>804,1911-07-11</issue>
        <issue>803,1911-07-10</issue>
        <issue>802,1911-07-09</issue>
        <issue>801,1911-07-07</issue>
        <issue>800,1911-07-06</issue>
        <issue>799,1911-07-05</issue>
        <issue>798,1911-07-04</issue>
        <issue>797,1911-07-03</issue>
        <issue>796,1911-07-02</issue>
        <issue>795,1911-06-30</issue>
        <issue>794,1911-06-29</issue>
        <issue>793,1911-06-28</issue>
        <issue>792,1911-06-27</issue>
        <issue>791,1911-06-26</issue>
        <issue>790,1911-06-25</issue>
        <issue>789,1911-06-23</issue>
        <issue>788,1911-06-22</issue>
        <issue>787,1911-06-21</issue>
        <issue>786,1911-06-20</issue>
        <issue>785,1911-06-19</issue>
        <issue>784,1911-06-18</issue>
        <issue>783,1911-06-16</issue>
        <issue>782,1911-06-15</issue>
        <issue>781,1911-06-14</issue>
        <issue>780,1911-06-13</issue>
        <issue>779,1911-06-12</issue>
        <issue>778,1911-06-11</issue>
        <issue>777,1911-06-09</issue>
        <issue>776,1911-06-08</issue>
        <issue>775,1911-06-07</issue>
        <issue>774,1911-06-06</issue>
        <issue>773,1911-06-05</issue>
        <issue>772,1911-06-04</issue>
        <issue>771,1911-06-02</issue>
        <issue>770,1911-06-01</issue>
        <issue>769,1911-05-31</issue>
        <issue>768,1911-05-30</issue>
        <issue>767,1911-05-29</issue>
        <issue>766,1911-05-28</issue>
        <issue>765,1911-05-26</issue>
        <issue>764,1911-05-25</issue>
        <issue>763,1911-05-24</issue>
        <issue>762,1911-05-23</issue>
        <issue>761,1911-05-22</issue>
        <issue>760,1911-05-21</issue>
        <issue>759,1911-05-19</issue>
        <issue>758,1911-05-18</issue>
        <issue>757,1911-05-17</issue>
        <issue>756,1911-05-16</issue>
        <issue>755,1911-05-15</issue>
        <issue>754,1911-05-14</issue>
        <issue>753,1911-05-12</issue>
        <issue>752,1911-05-11</issue>
        <issue>751,1911-05-10</issue>
        <issue>750,1911-05-09</issue>
        <issue>749,1911-05-08</issue>
        <issue>748,1911-05-07</issue>
        <issue>747,1911-05-05</issue>
        <issue>746,1911-05-04</issue>
        <issue>745,1911-05-03</issue>
        <issue>744,1911-05-02</issue>
        <issue>743,1911-05-01</issue>
        <issue>742,1911-04-30</issue>
        <issue>741,1911-04-28</issue>
        <issue>740,1911-04-27</issue>
        <issue>739,1911-04-26</issue>
        <issue>738,1911-04-25</issue>
        <issue>737,1911-04-24</issue>
        <issue>736,1911-04-23</issue>
        <issue>735,1911-04-21</issue>
        <issue>734,1911-04-20</issue>
        <issue>733,1911-04-19</issue>
        <issue>732,1911-04-18</issue>
        <issue>731,1911-04-17</issue>
        <issue>730,1911-04-16</issue>
        <issue>729,1911-04-14</issue>
        <issue>728,1911-04-13</issue>
        <issue>727,1911-04-12</issue>
        <issue>726,1911-04-11</issue>
        <issue>725,1911-04-10</issue>
        <issue>724,1911-04-09</issue>
        <issue>723,1911-04-07</issue>
        <issue>722,1911-04-06</issue>
        <issue>721,1911-04-05</issue>
        <issue>720,1911-04-04</issue>
        <issue>719,1911-04-03</issue>
        <issue>718,1911-04-02</issue>
        <issue>717,1911-03-31</issue>
        <issue>716,1911-03-30</issue>
        <issue>715,1911-03-29</issue>
        <issue>714,1911-03-28</issue>
        <issue>713,1911-03-27</issue>
        <issue>712,1911-03-26</issue>
        <issue>711,1911-03-24</issue>
        <issue>710,1911-03-23</issue>
        <issue>709,1911-03-22</issue>
        <issue>708,1911-03-21</issue>
        <issue>707,1911-03-20</issue>
        <issue>706,1911-03-19</issue>
        <issue>705,1911-03-17</issue>
        <issue>704,1911-03-16</issue>
        <issue>703,1911-03-15</issue>
        <issue>702,1911-03-14</issue>
        <issue>701,1911-03-13</issue>
        <issue>700,1911-03-12</issue>
        <issue>699,1911-03-10</issue>
        <issue>698,1911-03-09</issue>
        <issue>697,1911-03-08</issue>
        <issue>696,1911-03-07</issue>
        <issue>695,1911-03-06</issue>
        <issue>694,1911-03-05</issue>
        <issue>693,1911-03-03</issue>
        <issue>692,1911-03-02</issue>
        <issue>691,1911-03-01</issue>
        <issue>690,1911-02-28</issue>
        <issue>689,1911-02-27</issue>
        <issue>688,1911-02-26</issue>
        <issue>687,1911-02-24</issue>
        <issue>686,1911-02-23</issue>
        <issue>685,1911-02-22</issue>
        <issue>684,1911-02-21</issue>
        <issue>683,1911-02-20</issue>
        <issue>682,1911-02-19</issue>
        <issue>681,1911-02-17</issue>
        <issue>680,1911-02-16</issue>
        <issue>679,1911-02-15</issue>
        <issue>678,1911-02-14</issue>
        <issue>677,1911-02-13</issue>
        <issue>676,1911-02-12</issue>
        <issue>675,1911-02-10</issue>
        <issue>674,1911-02-09</issue>
        <issue>673,1911-02-08</issue>
        <issue>672,1911-02-07</issue>
        <issue>671,1911-02-06</issue>
        <issue>670,1911-02-05</issue>
        <issue>669,1911-02-03</issue>
        <issue>668,1911-02-02</issue>
        <issue>667,1911-02-01</issue>
        <issue>666,1911-01-31</issue>
        <issue>665,1911-01-30</issue>
        <issue>664,1911-01-29</issue>
        <issue>663,1911-01-27</issue>
        <issue>662,1911-01-26</issue>
        <issue>661,1911-01-25</issue>
        <issue>660,1911-01-24</issue>
        <issue>659,1911-01-23</issue>
        <issue>658,1911-01-22</issue>
        <issue>657,1911-01-20</issue>
        <issue>656,1911-01-19</issue>
        <issue>655,1911-01-18</issue>
        <issue>654,1911-01-17</issue>
        <issue>653,1911-01-16</issue>
        <issue>652,1911-01-15</issue>
        <issue>651,1911-01-13</issue>
        <issue>650,1911-01-12</issue>
        <issue>649,1911-01-11</issue>
        <issue>648,1911-01-10</issue>
        <issue>647,1911-01-09</issue>
        <issue>646,1911-01-08</issue>
        <issue>645,1911-01-06</issue>
        <issue>644,1911-01-05</issue>
        <issue>643,1911-01-04</issue>
        <issue>642,1911-01-03</issue>
        <issue>641,1911-01-02</issue>
        <issue>640,1911-01-01</issue>
        <issue>639,1910-12-30</issue>
        <issue>638,1910-12-29</issue>
        <issue>637,1910-12-28</issue>
        <issue>636,1910-12-27</issue>
        <issue>635,1910-12-26</issue>
        <issue>634,1910-12-25</issue>
        <issue>633,1910-12-23</issue>
        <issue>632,1910-12-22</issue>
        <issue>631,1910-12-21</issue>
        <issue>630,1910-12-20</issue>
        <issue>629,1910-12-19</issue>
        <issue>628,1910-12-18</issue>
        <issue>627,1910-12-16</issue>
        <issue>626,1910-12-15</issue>
        <issue>625,1910-12-14</issue>
        <issue>624,1910-12-13</issue>
        <issue>623,1910-12-12</issue>
        <issue>622,1910-12-11</issue>
        <issue>621,1910-12-09</issue>
        <issue>620,1910-12-08</issue>
        <issue>619,1910-12-07</issue>
        <issue>618,1910-12-06</issue>
        <issue>617,1910-12-05</issue>
        <issue>616,1910-12-04</issue>
        <issue>615,1910-12-02</issue>
        <issue>614,1910-12-01</issue>
        <issue>613,1910-11-30</issue>
        <issue>612,1910-11-29</issue>
        <issue>611,1910-11-28</issue>
        <issue>610,1910-11-27</issue>
        <issue>609,1910-11-25</issue>
        <issue>608,1910-11-24</issue>
        <issue>607,1910-11-23</issue>
        <issue>606,1910-11-22</issue>
        <issue>605,1910-11-21</issue>
        <issue>604,1910-11-20</issue>
        <issue>603,1910-11-18</issue>
        <issue>602,1910-11-17</issue>
        <issue>601,1910-11-16</issue>
        <issue>600,1910-11-15</issue>
        <issue>599,1910-11-14</issue>
        <issue>598,1910-11-13</issue>
        <issue>597,1910-11-11</issue>
        <issue>596,1910-11-10</issue>
        <issue>595,1910-11-09</issue>
        <issue>594,1910-11-08</issue>
        <issue>593,1910-11-07</issue>
        <issue>592,1910-11-06</issue>
        <issue>591,1910-11-04</issue>
        <issue>590,1910-11-03</issue>
        <issue>589,1910-11-02</issue>
        <issue>588,1910-11-01</issue>
        <issue>587,1910-10-31</issue>
        <issue>586,1910-10-30</issue>
        <issue>585,1910-10-28</issue>
        <issue>584,1910-10-27</issue>
        <issue>583,1910-10-26</issue>
        <issue>582,1910-10-25</issue>
        <issue>581,1910-10-24</issue>
        <issue>580,1910-10-23</issue>
        <issue>579,1910-10-21</issue>
        <issue>578,1910-10-20</issue>
        <issue>577,1910-10-19</issue>
        <issue>576,1910-10-18</issue>
        <issue>575,1910-10-17</issue>
        <issue>574,1910-10-16</issue>
        <issue>573,1910-10-14</issue>
        <issue>572,1910-10-13</issue>
        <issue>571,1910-10-12</issue>
        <issue>570,1910-10-11</issue>
        <issue>569,1910-10-10</issue>
        <issue>568,1910-10-09</issue>
        <issue>567,1910-10-07</issue>
        <issue>566,1910-10-06</issue>
        <issue>565,1910-10-05</issue>
        <issue>564,1910-10-04</issue>
        <issue>563,1910-10-03</issue>
        <issue>562,1910-10-02</issue>
        <issue>561,1910-09-30</issue>
        <issue>560,1910-09-29</issue>
        <issue>559,1910-09-28</issue>
        <issue>558,1910-09-27</issue>
        <issue>557,1910-09-26</issue>
        <issue>556,1910-09-25</issue>
        <issue>555,1910-09-23</issue>
        <issue>554,1910-09-22</issue>
        <issue>553,1910-09-21</issue>
        <issue>552,1910-09-20</issue>
        <issue>551,1910-09-19</issue>
        <issue>550,1910-09-18</issue>
        <issue>549,1910-09-16</issue>
        <issue>548,1910-09-15</issue>
        <issue>547,1910-09-14</issue>
        <issue>546,1910-09-13</issue>
        <issue>545,1910-09-12</issue>
        <issue>544,1910-09-11</issue>
        <issue>543,1910-09-09</issue>
        <issue>542,1910-09-08</issue>
        <issue>541,1910-09-07</issue>
        <issue>540,1910-09-06</issue>
        <issue>539,1910-09-05</issue>
        <issue>538,1910-09-04</issue>
        <issue>537,1910-09-02</issue>
        <issue>536,1910-09-01</issue>
        <issue>535,1910-08-31</issue>
        <issue>534,1910-08-30</issue>
        <issue>533,1910-08-29</issue>
        <issue>532,1910-08-28</issue>
        <issue>531,1910-08-26</issue>
        <issue>530,1910-08-25</issue>
        <issue>529,1910-08-24</issue>
        <issue>528,1910-08-23</issue>
        <issue>527,1910-08-22</issue>
        <issue>526,1910-08-21</issue>
        <issue>525,1910-08-19</issue>
        <issue>524,1910-08-18</issue>
        <issue>523,1910-08-17</issue>
        <issue>522,1910-08-16</issue>
        <issue>521,1910-08-15</issue>
        <issue>520,1910-08-14</issue>
        <issue>519,1910-08-12</issue>
        <issue>518,1910-08-11</issue>
        <issue>517,1910-08-10</issue>
        <issue>516,1910-08-09</issue>
        <issue>515,1910-08-08</issue>
        <issue>514,1910-08-07</issue>
        <issue>513,1910-08-05</issue>
        <issue>512,1910-08-04</issue>
        <issue>511,1910-08-03</issue>
        <issue>510,1910-08-02</issue>
        <issue>509,1910-08-01</issue>
        <issue>508,1910-07-31</issue>
        <issue>507,1910-07-29</issue>
        <issue>506,1910-07-28</issue>
        <issue>505,1910-07-27</issue>
        <issue>504,1910-07-26</issue>
        <issue>503,1910-07-25</issue>
        <issue>502,1910-07-24</issue>
        <issue>501,1910-07-22</issue>
        <issue>500,1910-07-21</issue>
        <issue>499,1910-07-20</issue>
        <issue>498,1910-07-19</issue>
        <issue>497,1910-07-18</issue>
        <issue>496,1910-07-17</issue>
        <issue>495,1910-07-15</issue>
        <issue>494,1910-07-14</issue>
        <issue>493,1910-07-13</issue>
        <issue>492,1910-07-12</issue>
        <issue>491,1910-07-11</issue>
        <issue>490,1910-07-10</issue>
        <issue>489,1910-07-08</issue>
        <issue>488,1910-07-07</issue>
        <issue>487,1910-07-06</issue>
        <issue>486,1910-07-05</issue>
        <issue>485,1910-07-04</issue>
        <issue>484,1910-07-03</issue>
        <issue>483,1910-07-01</issue>
        <issue>482,1910-06-30</issue>
        <issue>481,1910-06-29</issue>
        <issue>480,1910-06-28</issue>
        <issue>479,1910-06-27</issue>
        <issue>478,1910-06-26</issue>
        <issue>477,1910-06-24</issue>
        <issue>476,1910-06-23</issue>
        <issue>475,1910-06-22</issue>
        <issue>474,1910-06-21</issue>
        <issue>473,1910-06-20</issue>
        <issue>472,1910-06-19</issue>
        <issue>471,1910-06-17</issue>
        <issue>470,1910-06-16</issue>
        <issue>469,1910-06-15</issue>
        <issue>468,1910-06-14</issue>
        <issue>467,1910-06-13</issue>
        <issue>466,1910-06-12</issue>
        <issue>465,1910-06-10</issue>
        <issue>464,1910-06-09</issue>
        <issue>463,1910-06-08</issue>
        <issue>462,1910-06-07</issue>
        <issue>461,1910-06-06</issue>
        <issue>460,1910-06-05</issue>
        <issue>459,1910-06-03</issue>
        <issue>458,1910-06-02</issue>
        <issue>457,1910-06-01</issue>
        <issue>456,1910-05-31</issue>
        <issue>455,1910-05-30</issue>
        <issue>454,1910-05-29</issue>
        <issue>453,1910-05-27</issue>
        <issue>452,1910-05-26</issue>
        <issue>451,1910-05-25</issue>
        <issue>450,1910-05-24</issue>
        <issue>449,1910-05-23</issue>
        <issue>448,1910-05-22</issue>
        <issue>447,1910-05-20</issue>
        <issue>446,1910-05-19</issue>
        <issue>445,1910-05-18</issue>
        <issue>444,1910-05-17</issue>
        <issue>443,1910-05-16</issue>
        <issue>442,1910-05-15</issue>
        <issue>441,1910-05-13</issue>
        <issue>440,1910-05-12</issue>
        <issue>439,1910-05-11</issue>
        <issue>438,1910-05-10</issue>
        <issue>437,1910-05-09</issue>
        <issue>436,1910-05-08</issue>
        <issue>435,1910-05-06</issue>
        <issue>434,1910-05-05</issue>
        <issue>433,1910-05-04</issue>
        <issue>432,1910-05-03</issue>
        <issue>431,1910-05-02</issue>
        <issue>430,1910-05-01</issue>
        <issue>429,1910-04-29</issue>
        <issue>428,1910-04-28</issue>
        <issue>427,1910-04-27</issue>
        <issue>426,1910-04-26</issue>
        <issue>425,1910-04-25</issue>
        <issue>424,1910-04-24</issue>
        <issue>423,1910-04-22</issue>
        <issue>422,1910-04-21</issue>
        <issue>421,1910-04-20</issue>
        <issue>420,1910-04-19</issue>
        <issue>419,1910-04-18</issue>
        <issue>418,1910-04-17</issue>
        <issue>417,1910-04-15</issue>
        <issue>416,1910-04-14</issue>
        <issue>415,1910-04-13</issue>
        <issue>414,1910-04-12</issue>
        <issue>413,1910-04-11</issue>
        <issue>412,1910-04-10</issue>
        <issue>411,1910-04-08</issue>
        <issue>410,1910-04-07</issue>
        <issue>409,1910-04-06</issue>
        <issue>408,1910-04-05</issue>
        <issue>407,1910-04-04</issue>
        <issue>406,1910-04-03</issue>
        <issue>405,1910-04-01</issue>
        <issue>404,1910-03-31</issue>
        <issue>403,1910-03-30</issue>
        <issue>402,1910-03-29</issue>
        <issue>401,1910-03-28</issue>
        <issue>400,1910-03-27</issue>
        <issue>399,1910-03-25</issue>
        <issue>398,1910-03-24</issue>
        <issue>397,1910-03-23</issue>
        <issue>396,1910-03-22</issue>
        <issue>395,1910-03-21</issue>
        <issue>394,1910-03-20</issue>
        <issue>393,1910-03-18</issue>
        <issue>392,1910-03-17</issue>
        <issue>391,1910-03-16</issue>
        <issue>390,1910-03-15</issue>
        <issue>389,1910-03-14</issue>
        <issue>388,1910-03-13</issue>
        <issue>387,1910-03-11</issue>
        <issue>386,1910-03-10</issue>
        <issue>385,1910-03-09</issue>
        <issue>384,1910-03-08</issue>
        <issue>383,1910-03-07</issue>
        <issue>382,1910-03-06</issue>
        <issue>381,1910-03-04</issue>
        <issue>380,1910-03-03</issue>
        <issue>379,1910-03-02</issue>
        <issue>378,1910-03-01</issue>
        <issue>377,1910-02-28</issue>
        <issue>376,1910-02-27</issue>
        <issue>375,1910-02-25</issue>
        <issue>374,1910-02-24</issue>
        <issue>373,1910-02-23</issue>
        <issue>372,1910-02-22</issue>
        <issue>371,1910-02-21</issue>
        <issue>370,1910-02-20</issue>
        <issue>369,1910-02-18</issue>
        <issue>368,1910-02-17</issue>
        <issue>367,1910-02-16</issue>
        <issue>366,1910-02-15</issue>
        <issue>365,1910-02-14</issue>
        <issue>364,1910-02-13</issue>
        <issue>363,1910-02-11</issue>
        <issue>362,1910-02-10</issue>
        <issue>361,1910-02-09</issue>
        <issue>360,1910-02-08</issue>
        <issue>359,1910-02-07</issue>
        <issue>358,1910-02-06</issue>
        <issue>357,1910-02-04</issue>
        <issue>356,1910-02-03</issue>
        <issue>355,1910-02-02</issue>
        <issue>354,1910-02-01</issue>
        <issue>353,1910-01-31</issue>
        <issue>352,1910-01-30</issue>
        <issue>351,1910-01-28</issue>
        <issue>350,1910-01-27</issue>
        <issue>349,1910-01-26</issue>
        <issue>348,1910-01-25</issue>
        <issue>347,1910-01-24</issue>
        <issue>346,1910-01-23</issue>
        <issue>345,1910-01-21</issue>
        <issue>344,1910-01-20</issue>
        <issue>343,1910-01-19</issue>
        <issue>342,1910-01-18</issue>
        <issue>341,1910-01-17</issue>
        <issue>340,1910-01-16</issue>
        <issue>339,1910-01-14</issue>
        <issue>338,1910-01-13</issue>
        <issue>337,1910-01-12</issue>
        <issue>336,1910-01-11</issue>
        <issue>335,1910-01-10</issue>
        <issue>334,1910-01-09</issue>
        <issue>333,1910-01-07</issue>
        <issue>332,1910-01-06</issue>
        <issue>331,1910-01-05</issue>
        <issue>330,1910-01-04</issue>
        <issue>329,1910-01-03</issue>
        <issue>328,1910-01-02</issue>
        <issue>327,1909-12-31</issue>
        <issue>326,1909-12-30</issue>
        <issue>325,1909-12-29</issue>
        <issue>324,1909-12-28</issue>
        <issue>323,1909-12-27</issue>
        <issue>322,1909-12-26</issue>
        <issue>321,1909-12-24</issue>
        <issue>320,1909-12-23</issue>
        <issue>319,1909-12-22</issue>
        <issue>318,1909-12-21</issue>
        <issue>317,1909-12-20</issue>
        <issue>316,1909-12-19</issue>
        <issue>315,1909-12-17</issue>
        <issue>314,1909-12-16</issue>
        <issue>313,1909-12-15</issue>
        <issue>312,1909-12-14</issue>
        <issue>311,1909-12-13</issue>
        <issue>310,1909-12-12</issue>
        <issue>309,1909-12-10</issue>
        <issue>308,1909-12-09</issue>
        <issue>307,1909-12-08</issue>
        <issue>306,1909-12-07</issue>
        <issue>305,1909-12-06</issue>
        <issue>304,1909-12-05</issue>
        <issue>303,1909-12-03</issue>
        <issue>302,1909-12-02</issue>
        <issue>301,1909-12-01</issue>
        <issue>300,1909-11-30</issue>
        <issue>299,1909-11-29</issue>
        <issue>298,1909-11-28</issue>
        <issue>297,1909-11-26</issue>
        <issue>296,1909-11-25</issue>
        <issue>295,1909-11-24</issue>
        <issue>294,1909-11-23</issue>
        <issue>293,1909-11-22</issue>
        <issue>292,1909-11-21</issue>
        <issue>291,1909-11-19</issue>
        <issue>290,1909-11-18</issue>
        <issue>289,1909-11-17</issue>
        <issue>288,1909-11-16</issue>
        <issue>287,1909-11-15</issue>
        <issue>286,1909-11-14</issue>
        <issue>285,1909-11-12</issue>
        <issue>284,1909-11-11</issue>
        <issue>283,1909-11-10</issue>
        <issue>282,1909-11-09</issue>
        <issue>281,1909-11-08</issue>
        <issue>280,1909-11-07</issue>
        <issue>279,1909-11-05</issue>
        <issue>278,1909-11-04</issue>
        <issue>277,1909-11-03</issue>
        <issue>276,1909-11-02</issue>
        <issue>275,1909-11-01</issue>
        <issue>274,1909-10-31</issue>
        <issue>273,1909-10-29</issue>
        <issue>272,1909-10-28</issue>
        <issue>271,1909-10-27</issue>
        <issue>270,1909-10-26</issue>
        <issue>269,1909-10-25</issue>
        <issue>268,1909-10-24</issue>
        <issue>267,1909-10-22</issue>
        <issue>266,1909-10-21</issue>
        <issue>265,1909-10-20</issue>
        <issue>264,1909-10-19</issue>
        <issue>263,1909-10-18</issue>
        <issue>262,1909-10-17</issue>
        <issue>261,1909-10-15</issue>
        <issue>260,1909-10-14</issue>
        <issue>259,1909-10-13</issue>
        <issue>258,1909-10-12</issue>
        <issue>257,1909-10-11</issue>
        <issue>256,1909-10-10</issue>
        <issue>255,1909-10-08</issue>
        <issue>254,1909-10-07</issue>
        <issue>253,1909-10-06</issue>
        <issue>252,1909-10-05</issue>
        <issue>251,1909-10-04</issue>
        <issue>250,1909-10-03</issue>
        <issue>249,1909-10-01</issue>
        <issue>248,1909-09-30</issue>
        <issue>247,1909-09-29</issue>
        <issue>246,1909-09-28</issue>
        <issue>245,1909-09-27</issue>
        <issue>244,1909-09-26</issue>
        <issue>243,1909-09-24</issue>
        <issue>242,1909-09-23</issue>
        <issue>241,1909-09-22</issue>
        <issue>240,1909-09-21</issue>
        <issue>239,1909-09-20</issue>
        <issue>238,1909-09-19</issue>
        <issue>237,1909-09-17</issue>
        <issue>236,1909-09-16</issue>
        <issue>235,1909-09-15</issue>
        <issue>234,1909-09-14</issue>
        <issue>233,1909-09-13</issue>
        <issue>232,1909-09-12</issue>
        <issue>231,1909-09-10</issue>
        <issue>230,1909-09-09</issue>
        <issue>229,1909-09-08</issue>
        <issue>228,1909-09-07</issue>
        <issue>227,1909-09-06</issue>
        <issue>226,1909-09-05</issue>
        <issue>225,1909-09-03</issue>
        <issue>224,1909-09-02</issue>
        <issue>223,1909-09-01</issue>
        <issue>222,1909-08-31</issue>
        <issue>221,1909-08-30</issue>
        <issue>220,1909-08-29</issue>
        <issue>219,1909-08-27</issue>
        <issue>218,1909-08-26</issue>
        <issue>217,1909-08-25</issue>
        <issue>216,1909-08-24</issue>
        <issue>215,1909-08-23</issue>
        <issue>214,1909-08-22</issue>
        <issue>213,1909-08-20</issue>
        <issue>212,1909-08-19</issue>
        <issue>211,1909-08-18</issue>
        <issue>210,1909-08-17</issue>
        <issue>209,1909-08-16</issue>
        <issue>208,1909-08-15</issue>
        <issue>207,1909-08-13</issue>
        <issue>206,1909-08-12</issue>
        <issue>205,1909-08-11</issue>
        <issue>204,1909-08-10</issue>
        <issue>203,1909-08-09</issue>
        <issue>202,1909-08-08</issue>
        <issue>201,1909-08-06</issue>
        <issue>200,1909-08-05</issue>
        <issue>199,1909-08-04</issue>
        <issue>198,1909-08-03</issue>
        <issue>197,1909-08-02</issue>
        <issue>196,1909-08-01</issue>
        <issue>195,1909-07-30</issue>
        <issue>194,1909-07-29</issue>
        <issue>193,1909-07-28</issue>
        <issue>192,1909-07-27</issue>
        <issue>191,1909-07-26</issue>
        <issue>190,1909-07-25</issue>
        <issue>189,1909-07-23</issue>
        <issue>188,1909-07-22</issue>
        <issue>187,1909-07-21</issue>
        <issue>186,1909-07-20</issue>
        <issue>185,1909-07-19</issue>
        <issue>184,1909-07-18</issue>
        <issue>183,1909-07-16</issue>
        <issue>182,1909-07-15</issue>
        <issue>181,1909-07-14</issue>
        <issue>180,1909-07-13</issue>
        <issue>179,1909-07-12</issue>
        <issue>178,1909-07-11</issue>
        <issue>177,1909-07-09</issue>
        <issue>176,1909-07-08</issue>
        <issue>175,1909-07-07</issue>
        <issue>174,1909-07-06</issue>
        <issue>173,1909-07-05</issue>
        <issue>172,1909-07-04</issue>
        <issue>171,1909-07-02</issue>
        <issue>170,1909-07-01</issue>
        <issue>169,1909-06-30</issue>
        <issue>168,1909-06-29</issue>
        <issue>167,1909-06-28</issue>
        <issue>166,1909-06-27</issue>
        <issue>165,1909-06-25</issue>
        <issue>164,1909-06-24</issue>
        <issue>163,1909-06-23</issue>
        <issue>162,1909-06-22</issue>
        <issue>161,1909-06-21</issue>
        <issue>160,1909-06-20</issue>
        <issue>159,1909-06-18</issue>
        <issue>158,1909-06-17</issue>
        <issue>157,1909-06-16</issue>
        <issue>156,1909-06-15</issue>
        <issue>155,1909-06-14</issue>
        <issue>154,1909-06-13</issue>
        <issue>153,1909-06-11</issue>
        <issue>152,1909-06-10</issue>
        <issue>151,1909-06-09</issue>
        <issue>150,1909-06-08</issue>
        <issue>149,1909-06-07</issue>
        <issue>148,1909-06-06</issue>
        <issue>147,1909-06-04</issue>
        <issue>146,1909-06-03</issue>
        <issue>145,1909-06-02</issue>
        <issue>144,1909-06-01</issue>
        <issue>143,1909-05-31</issue>
        <issue>142,1909-05-30</issue>
        <issue>141,1909-05-28</issue>
        <issue>140,1909-05-27</issue>
        <issue>139,1909-05-26</issue>
        <issue>138,1909-05-25</issue>
        <issue>137,1909-05-24</issue>
        <issue>136,1909-05-23</issue>
        <issue>135,1909-05-21</issue>
        <issue>134,1909-05-20</issue>
        <issue>133,1909-05-19</issue>
        <issue>132,1909-05-18</issue>
        <issue>131,1909-05-17</issue>
        <issue>130,1909-05-16</issue>
        <issue>129,1909-05-14</issue>
        <issue>128,1909-05-13</issue>
        <issue>127,1909-05-12</issue>
        <issue>126,1909-05-11</issue>
        <issue>125,1909-05-10</issue>
        <issue>124,1909-05-09</issue>
        <issue>123,1909-05-07</issue>
        <issue>122,1909-05-06</issue>
        <issue>121,1909-05-05</issue>
        <issue>120,1909-05-04</issue>
        <issue>119,1909-05-03</issue>
        <issue>118,1909-05-02</issue>
        <issue>117,1909-04-30</issue>
        <issue>116,1909-04-29</issue>
        <issue>115,1909-04-28</issue>
        <issue>114,1909-04-27</issue>
        <issue>113,1909-04-26</issue>
        <issue>112,1909-04-25</issue>
        <issue>111,1909-04-23</issue>
        <issue>110,1909-04-22</issue>
        <issue>109,1909-04-21</issue>
        <issue>108,1909-04-20</issue>
        <issue>107,1909-04-19</issue>
        <issue>106,1909-04-18</issue>
        <issue>105,1909-04-16</issue>
        <issue>104,1909-04-15</issue>
        <issue>103,1909-04-14</issue>
        <issue>102,1909-04-13</issue>
        <issue>101,1909-04-12</issue>
        <issue>100,1909-04-11</issue>
        <issue>99,1909-04-09</issue>
        <issue>98,1909-04-08</issue>
        <issue>97,1909-04-07</issue>
        <issue>96,1909-04-06</issue>
        <issue>95,1909-04-05</issue>
        <issue>94,1909-04-04</issue>
        <issue>93,1909-04-02</issue>
        <issue>92,1909-04-01</issue>
        <issue>91,1909-03-31</issue>
        <issue>90,1909-03-30</issue>
        <issue>89,1909-03-29</issue>
        <issue>88,1909-03-28</issue>
        <issue>87,1909-03-26</issue>
        <issue>86,1909-03-25</issue>
        <issue>85,1909-03-24</issue>
        <issue>84,1909-03-23</issue>
        <issue>83,1909-03-22</issue>
        <issue>82,1909-03-21</issue>
        <issue>81,1909-03-19</issue>
        <issue>80,1909-03-18</issue>
        <issue>79,1909-03-17</issue>
        <issue>78,1909-03-16</issue>
        <issue>77,1909-03-15</issue>
        <issue>76,1909-03-14</issue>
        <issue>75,1909-03-12</issue>
        <issue>74,1909-03-11</issue>
        <issue>73,1909-03-10</issue>
        <issue>72,1909-03-09</issue>
        <issue>71,1909-03-08</issue>
        <issue>70,1909-03-07</issue>
        <issue>69,1909-03-05</issue>
        <issue>68,1909-03-04</issue>
        <issue>67,1909-03-03</issue>
        <issue>66,1909-03-02</issue>
        <issue>65,1909-03-01</issue>
        <issue>64,1909-02-28</issue>
        <issue>63,1909-02-26</issue>
        <issue>62,1909-02-25</issue>
        <issue>61,1909-02-24</issue>
        <issue>60,1909-02-23</issue>
        <issue>59,1909-02-22</issue>
        <issue>58,1909-02-21</issue>
        <issue>57,1909-02-19</issue>
        <issue>56,1909-02-18</issue>
        <issue>55,1909-02-17</issue>
        <issue>54,1909-02-16</issue>
        <issue>53,1909-02-15</issue>
        <issue>52,1909-02-14</issue>
        <issue>51,1909-02-12</issue>
        <issue>50,1909-02-11</issue>
        <issue>49,1909-02-10</issue>
        <issue>48,1909-02-09</issue>
        <issue>47,1909-02-08</issue>
        <issue>46,1909-02-07</issue>
        <issue>45,1909-02-05</issue>
        <issue>44,1909-02-04</issue>
        <issue>43,1909-02-03</issue>
        <issue>42,1909-02-02</issue>
        <issue>41,1909-02-01</issue>
        <issue>40,1909-01-31</issue>
        <issue>39,1909-01-29</issue>
        <issue>38,1909-01-28</issue>
        <issue>37,1909-01-27</issue>
        <issue>36,1909-01-26</issue>
        <issue>35,1909-01-25</issue>
        <issue>34,1909-01-24</issue>
        <issue>33,1909-01-22</issue>
        <issue>32,1909-01-21</issue>
        <issue>31,1909-01-20</issue>
        <issue>30,1909-01-19</issue>
        <issue>29,1909-01-18</issue>
        <issue>28,1909-01-17</issue>
        <issue>27,1909-01-15</issue>
        <issue>26,1909-01-14</issue>
        <issue>25,1909-01-13</issue>
        <issue>24,1909-01-12</issue>
        <issue>23,1909-01-11</issue>
        <issue>22,1909-01-10</issue>
        <issue>21,1909-01-08</issue>
        <issue>20,1909-01-07</issue>
        <issue>19,1909-01-06</issue>
        <issue>18,1909-01-05</issue>
        <issue>17,1909-01-04</issue>
        <issue>16,1909-01-03</issue>
        <issue>15,1909-01-01</issue>
        <issue>14,1908-12-31</issue>
        <issue>13,1908-12-30</issue>
        <issue>12,1908-12-29</issue>
        <issue>11,1908-12-28</issue>
        <issue>10,1908-12-27</issue>
        <issue>9,1908-12-25</issue>
        <issue>8,1908-12-24</issue>
        <issue>7,1908-12-23</issue>
        <issue>6,1908-12-22</issue>
        <issue>5,1908-12-21</issue>
        <issue>4,1908-12-20</issue>
        <issue>3,1908-12-19</issue>
    </xsl:variable>
    
  
    <xsl:variable name="vIssue1">
        <xsl:call-template name="templIssue"/>        
    </xsl:variable>  

    <xsl:template name="templIssue">
        <xsl:param name="pDateCheck" select="'1916-11-09'"/> <!-- date of last issue of al-muqtabas available at eap 119 -->
        <xsl:param name="pDate" select="xs:date('1908-12-19')"/><!-- was a Thu -->
        <xsl:param name="pIssue" select="3"/>
        <!-- <xsl:text>No.</xsl:text><xsl:value-of select="$pIssue"/><xsl:text> </xsl:text><xsl:value-of select="format-date($pDate, '[Y0001]-[M01]-[D01] [FNn, *-3]','en',(),())"/><xsl:text>, </xsl:text> -->
        <xsl:if test="$pDate&lt;xs:date($pDateCheck)">
            <xsl:call-template name="templIssue">
                <xsl:with-param name="pDate" select="if((format-date($pDate, '[FNn, *-3]','en',(),()))='Fri') then($pDate+2*xs:dayTimeDuration('P1D')) else($pDate+1*xs:dayTimeDuration('P1D'))"/>
                <xsl:with-param name="pIssue" select="$pIssue+1"/>
                <xsl:with-param name="pDateCheck" select="$pDateCheck"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:element name="issue">
            <xsl:value-of select="$pIssue"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$pDate"/>
        </xsl:element>
        
    </xsl:template>

    <xsl:template name="templIssue1">
        <xsl:param name="pDateCheck"/>
        <xsl:param name="pDate" select="xs:date('1908-12-19')"/><!-- was a Thu -->
        <xsl:param name="pIssue" select="3"/>
        <!-- <xsl:text>No.</xsl:text><xsl:value-of select="$pIssue"/><xsl:text> </xsl:text><xsl:value-of select="format-date($pDate, '[Y0001]-[M01]-[D01] [FNn, *-3]','en',(),())"/><xsl:text>, </xsl:text> -->
            <xsl:if test="$pDate&lt;=xs:date($pDateCheck)">
            <xsl:call-template name="templIssue1">
                <xsl:with-param name="pDate" select="if((format-date($pDate, '[FNn, *-3]','en',(),()))='Fri') then($pDate+2*xs:dayTimeDuration('P1D')) else($pDate+1*xs:dayTimeDuration('P1D'))"/>
                <xsl:with-param name="pIssue" select="$pIssue+1"/>
                <xsl:with-param name="pDateCheck" select="$pDateCheck"/>
            </xsl:call-template>
            </xsl:if>
            <xsl:if test="$pDate=xs:date($pDateCheck)">
                <xsl:value-of select="$pIssue"/>
            </xsl:if>
    </xsl:template>
</xsl:stylesheet>