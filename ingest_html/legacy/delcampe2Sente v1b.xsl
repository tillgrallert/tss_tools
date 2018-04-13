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
    
    <!-- This stylesheet builds Sente XML and an applescript from the links to delcampe auctions -->
    <!-- the input is an html file containing a <div> with links to full detail pages on the Delcampe website. The file is usually produced dragging and dropping links into a folder on the desktop and then pasting all those links into the div -->
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
    <!-- v1a: original version -->
    <!-- v1b: the redundancy of four servers is not necessary and thus cut. AucID can be shorter than 9 digits; in this case zeros have to be added to the left -->
    <!--
    - mode m5 produces an applescript to download the image files to the hd 
    - mode m4 produces the Sente XML references with links to the downloaded images
    -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions.xsl"/> <!-- provides replacement functions -->
    
    
    <xsl:template match="html//body">
        <xsl:apply-templates mode="m4"/> <!--select m4 or m5 -->
    </xsl:template>
   
    
    <xsl:template match="html//div" mode="m4">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:call-template name="templReferencesM4"/><!-- this is the line to trigger m1, m3, m4 -->
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="html//div" mode="m5">
        <!-- this section creates the full applescript -->
        <xsl:call-template name="templReferencesM5"/>
        <![CDATA[

set vErrors to {}
set vFolder1 to "/BachUni/projekte/Damascus/sources damascus/postcards-delcampe"

tell application "URL Access Scripting"
	repeat with Y from 1 to (number of items) of vUrlDoc
		set vUrlDocSelected to item Y of vUrlDoc
		set vAucIDSelected to item Y of vAucID
		
		try
			download vUrlDocSelected to vFolder1 & "/" & vAucIDSelected & ".jpg" replacing yes
		on error
			set end of vErrors to vUrlDocSelected
		end try
		
	end repeat
	
	set the clipboard to (vErrors as string)
	
end tell

tell application "TextEdit"
	make new document
	set text of document 1 to (the clipboard as text)
	save document 1 in vFolder1 & "/postcard-errors.txt"
end tell]]>
    </xsl:template>
  

    
    <xsl:template name="templReferencesM5">
        <![CDATA[set vUrlDoc to {"]]>
        <xsl:for-each select="a">
            <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>
            <xsl:variable name="vAucID">
                <xsl:choose>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=7">
                        <xsl:value-of select="concat('00',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=8">
                        <xsl:value-of select="concat('0',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(substring-after(./@href,'id,'),',var')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="vUrl1" select="'http://images-'"/>
            <xsl:variable name="vUrl2" select="'.delcampe-static.net/img_large/auction/000/'"/>
            <xsl:variable name="vUrl3" select="concat(substring($vAucID,1,3),'/',substring($vAucID,4,3),'/',substring($vAucID,7,3),'_00')"/>
            
            <xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'1.jpg')"/><![CDATA[","]]><xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'2.jpg')"/><![CDATA[","]]><xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'3.jpg')"/><![CDATA[","]]>
        </xsl:for-each>
        <![CDATA["}]]>
        <![CDATA[set vAucID to {"]]>
        <xsl:for-each select="a">
            <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>
            <xsl:variable name="vAucID">
                <xsl:choose>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=7">
                        <xsl:value-of select="concat('00',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=8">
                        <xsl:value-of select="concat('0',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(substring-after(./@href,'id,'),',var')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="concat($vAucID,'_001')"/><![CDATA[","]]><xsl:value-of select="concat($vAucID,'_002')"/><![CDATA[","]]><xsl:value-of select="concat($vAucID,'_003')"/><![CDATA[","]]>
        </xsl:for-each>
        <![CDATA["}]]>
                   
    </xsl:template>
    
    <xsl:template name="templReferencesM4">
        <xsl:for-each select="a">
            <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>
            <xsl:variable name="vURL">
                <xsl:value-of select="./@href"/>
            </xsl:variable>
            <xsl:variable name="vUrlImgBase" select="'/BachUni/projekte/Damascus/sources damascus/postcards-delcampe/'"/>
            <xsl:variable name="vAucID">
                <xsl:choose>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=7">
                        <xsl:value-of select="concat('00',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:when test="string-length(substring-before(substring-after(./@href,'id,'),',var'))=8">
                        <xsl:value-of select="concat('0',substring-before(substring-after(./@href,'id,'),',var'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(substring-after(./@href,'id,'),',var')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="vPubTitle">
                <xsl:value-of select="substring-before(substring-after(./@href,'var,'),',language')"/>
            </xsl:variable>
            <xsl:variable name="vDate" select="current-date()"/>

            <xsl:element name="tss:reference">
                <xsl:element name="tss:publicationType">
                    <xsl:attribute name="name">Photograph</xsl:attribute>
                </xsl:element>
                <xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Retrieval</xsl:attribute>
                        <xsl:attribute name="day">
                            <xsl:value-of select="format-date($vDate,'[D01]')"/>
                        </xsl:attribute>
                        <xsl:attribute name="month">
                            <xsl:value-of select="format-date($vDate,'[M01]')"/>
                        </xsl:attribute>
                        <xsl:attribute name="year">
                            <xsl:value-of select="format-date($vDate,'[Y0001]')"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:characteristics">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationTitle</xsl:attribute>
                        <xsl:call-template name="funcReplacement">
                            <xsl:with-param name="pString" select="$vPubTitle"/>
                            <xsl:with-param name="pFind" select="'-'"/>
                            <xsl:with-param name="pReplace" select="' '"/>
                        </xsl:call-template>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationStatus</xsl:attribute>
                        <xsl:text>Published</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Medium consulted</xsl:attribute>
                        <xsl:text>Web</xsl:text>
                    </xsl:element>
                    
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">call-num</xsl:attribute>
                        <xsl:value-of select="$vAucID"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">URL</xsl:attribute>
                        <xsl:value-of select="$vURL"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Web data source</xsl:attribute>
                        <xsl:text>delcampe.net</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Medium</xsl:attribute>
                        <xsl:text>Postcard</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:keywords">
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Damascus</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Photograph</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Postcard</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Source</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachments">
                    <xsl:variable name="vNum" select="'1,2,3'"/>
                        <xsl:for-each select="tokenize($vNum,',')"> <!-- to account for some issues with more pages, the range is significantly longer then the standard number of pages per issue -->
                            <xsl:variable name="vImg" select="number(.)"/>
                            <xsl:element name="tss:attachmentReference">
                                <xsl:element name="URL">
                                    <xsl:value-of select="concat($vUrlImgBase,$vAucID,'_00',$vImg,'.jpg')"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
  
</xsl:stylesheet>