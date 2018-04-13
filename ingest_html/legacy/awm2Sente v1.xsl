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
    
    <!-- This stylesheet builds Sente XML and an applescript from the links to the "Austrial War Memorial" detail pages -->
    <!-- the input is an html file containing a <div> with links to full detail pages on the Delcampe website. The file is usually produced dragging and dropping links into a folder on the desktop and then pasting all those links into the div -->
    <!-- the script then downloads all each html file and treats it as an escaped string in order to avoid not well-formed html -->
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
   
    <!--
    - mode m5 produces an applescript to download the image files to the hd 
    - mode m4 produces the Sente XML references with links to the downloaded images
    -->
    
    <xsl:param name="pgBaseUrl" select="'http://www.awm.gov.au/collection/'"/>
    <xsl:param name="pgUrlImgBase" select="'/BachUni/projekte/Damascus/sources damascus/australian war memorial/'"/>
    <!-- choose the Sente version the XML is meant to be imported to -->
    <xsl:param name="pgSenteVersion" select="'65'"/>
    
    
    <xsl:template match="html//body">
        <xsl:apply-templates mode="m4"/>
        <!-- <xsl:apply-templates mode="m5"/> -->
    </xsl:template>
   
    
    <xsl:template match="html//div" mode="m4">
        <xsl:result-document href="awm2Sente.xml" method="xml">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:call-template name="templReferencesM4"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html//div" mode="m5">
        <xsl:result-document href="awm2Sente.scpt" method="text">
        <!-- this section creates the full applescript -->
        <xsl:call-template name="templReferencesM5"/>
        <![CDATA[

set vErrors to {}
set vFolder1 to "]]><xsl:value-of select="$pgUrlImgBase"/><![CDATA["

tell application "URL Access Scripting"
	repeat with Y from 1 to (number of items) of vUrlDoc
		set vUrlDocSelected to item Y of vUrlDoc
		set vAwmIDSelected to item Y of vAwmID
		
		try
			download vUrlDocSelected to vFolder1 & vAwmIDSelected & ".jpg" replacing yes
		on error
			set end of vErrors to vUrlDocSelected
		end try
		
	end repeat
	
	set the clipboard to (vErrors as string)
	
end tell

tell application "TextEdit"
	make new document
	set text of document 1 to (the clipboard as text)
	save document 1 in vFolder1 & "photograph-errors.txt"
end tell]]>
<![CDATA[]]>
        </xsl:result-document>
    </xsl:template>
  

    
    <xsl:template name="templReferencesM5">
        <![CDATA[set vUrlDoc to {"]]><xsl:for-each select="a">
            <xsl:sort select="substring-after(./@href,$pgBaseUrl)"/>
            <xsl:variable name="vDate" select="current-date()"/>
            <xsl:variable name="vAwmID" select="substring-before(substring-after(./@href,$pgBaseUrl),'/')"/>
            <xsl:variable name="vUrl" select="concat($pgBaseUrl,'images/screen/',$vAwmID,'.jpg')"/>
            <xsl:value-of select="$vUrl"/>
            <xsl:if test="position()!=last()"><![CDATA[","]]></xsl:if>
        </xsl:for-each><![CDATA["}]]>
        <![CDATA[set vAwmID to {"]]><xsl:for-each select="a">
            <xsl:sort select="substring-after(./@href,$pgBaseUrl)"/>
            <xsl:variable name="vAwmID" select="substring-before(substring-after(./@href,$pgBaseUrl),'/')"/>
            <xsl:value-of select="$vAwmID"/>
            <xsl:if test="position()!=last()"><![CDATA[","]]></xsl:if>
        </xsl:for-each><![CDATA["}]]>
                   
    </xsl:template>
    
    <xsl:template name="templReferencesM4">
        <xsl:for-each select="a">
            <xsl:sort select="substring-after(./@href,$pgBaseUrl)"/>
            <xsl:variable name="vDate" select="current-date()"/>
            <xsl:variable name="vURL">
                <xsl:value-of select="./@href"/>
            </xsl:variable>
            <xsl:variable name="vAwmID" select="substring-before(substring-after(./@href,$pgBaseUrl),'/')"/>
            
            <xsl:variable name="vItemPage" select="document($vURL)"/>
            <!-- <xsl:variable name="vDesc1" select="$vItemPage//dd[@class='collection_desc']"/> -->
            <xsl:variable name="vItemStream" select="unparsed-text($vURL)"/>
            <xsl:variable name="vItemDetails">
                <xsl:value-of select="substring-before(substring-after($vItemStream,'&lt;div id=&quot;collection_detail&quot;&gt;&#xD;'),'&lt;p class=&quot;description&quot;&gt;')" disable-output-escaping="no"/>
            </xsl:variable>
            <!-- somehow the item date is not correctly retrieved -->
            <xsl:variable name="vItemDate" select="substring-before(substring-after($vItemDetails,'&lt;dt&gt;Date made&lt;/dt&gt;&#xD;'),'&lt;/dd&gt;')"/>
            
            <!-- can be unknown -->
            <xsl:variable name="vItemPhotographer" select="substring-before(substring-after(substring-after($vItemDetails,'&lt;dt&gt;Photographer&lt;/dt&gt;&#xD;'),'&lt;dd&gt;'),'&lt;/dd&gt;&#xD;')"/>
            <xsl:variable name="vItemDesc" select="substring-before(substring-after(substring-after($vItemDetails,'&lt;dt class=&quot;collection_desc&quot;&gt;Description&lt;/dt&gt;'),'&quot;&gt;'),'&lt;/dd&gt;&#xD;')"/>
            <xsl:variable name="vItemSum" select="substring-before(substring-after(substring-after($vItemDetails,'&lt;dt class=&quot;collection_desc&quot;&gt;Summary&lt;/dt&gt;'),'&quot;&gt;'),'&lt;/dd&gt;&#xD;')"/>
            <xsl:variable name="vItemTitle" select="substring-before(substring-after(substring-after($vItemDetails,'&lt;dt&gt;Title&lt;/dt&gt;'),'&quot;&gt;'),'&lt;/dd&gt;&#xD;')"/>
            <xsl:variable name="vPubD">
                <xsl:analyze-string select="$vItemDate" regex="(\d{{1}}(\d{{1}})?\s+)">
                    <xsl:matching-substring>
                        <xsl:value-of select="substring-before(.,' ')"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="vPubM">
                <xsl:analyze-string select="$vItemDate" regex="[A-Z]{{1}}[a-z]*">
                    <xsl:matching-substring>
                        <xsl:variable name="vM" select="."/>
                        <xsl:if test="starts-with($vM,'Jan')">
                            <xsl:value-of select="'01'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Feb')">
                            <xsl:value-of select="'02'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Mar')">
                            <xsl:value-of select="'03'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Apr')">
                            <xsl:value-of select="'04'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'May')">
                            <xsl:value-of select="'05'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Jun')">
                            <xsl:value-of select="'06'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Jul')">
                            <xsl:value-of select="'07'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Aug')">
                            <xsl:value-of select="'08'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Sep')">
                            <xsl:value-of select="'09'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Oct')">
                            <xsl:value-of select="'10'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Nov')">
                            <xsl:value-of select="'11'"/>
                        </xsl:if>
                        <xsl:if test="starts-with($vM,'Dec')">
                            <xsl:value-of select="'12'"/>
                        </xsl:if>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="vPubY">
                <xsl:analyze-string select="$vItemDate" regex="\d{{4}}">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            

            

            <xsl:element name="tss:reference">
                <xsl:element name="tss:publicationType">
                    <xsl:attribute name="name">Photograph</xsl:attribute>
                </xsl:element>
                <xsl:element name="tss:authors">
                    <xsl:element name="tss:author">
                        <xsl:if test="$vItemPhotographer!='Unknown'">
                            <xsl:attribute name="role">Photographer</xsl:attribute>
                            <xsl:element name="tss:surname">
                                <xsl:choose>
                                    <xsl:when test="contains($vItemPhotographer,',')">
                                    <xsl:value-of select="tokenize($vItemPhotographer,', ')[1]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$vItemPhotographer"/>
                                </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="tss:forenames">
                                <xsl:if test="contains($vItemPhotographer,',')">
                                    <xsl:value-of select="tokenize($vItemPhotographer,', ')[position()!=1]"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:if>
                    </xsl:element>
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
                    <xsl:if test="contains($vItemDetails,'Date made')">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Publication</xsl:attribute>
                        <xsl:attribute name="day">
                            <xsl:value-of select="$vPubD"/>
                        </xsl:attribute>
                        <xsl:attribute name="month">
                            <xsl:value-of select="$vPubM"/>
                        </xsl:attribute>
                        <xsl:attribute name="year">
                            <xsl:value-of select="$vPubY"/>
                        </xsl:attribute>
                    </xsl:element>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="tss:characteristics">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationTitle</xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$vItemTitle!=''">
                                <xsl:value-of select="$vItemTitle"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="tokenize($vItemDesc,'\s+')[position()&lt;12]">
                                    <xsl:if test="position()&lt;11">
                                        <xsl:value-of select="."/>
                                        <xsl:value-of select="' '"/>
                                    </xsl:if>
                                    <xsl:if test="position()=11">
                                        <xsl:value-of select="'...'"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
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
                        <xsl:attribute name="name">abstractText</xsl:attribute>
                        <xsl:value-of select="$vItemDesc"/>
                        <xsl:if test="$vItemSum!=''">
                            <xsl:if test="$pgSenteVersion='65'">
                                <![CDATA[
                            -  ]]>
                            </xsl:if>
                            <xsl:if test="$pgSenteVersion='66'">
                                <![CDATA[<br>]]>
                            </xsl:if>
                            <xsl:value-of select="$vItemSum"/>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">call-num</xsl:attribute>
                        <xsl:value-of select="$vAwmID"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Repository</xsl:attribute>
                        <xsl:value-of select="'AWM'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Standort</xsl:attribute>
                        <xsl:value-of select="'Australian War Memorial'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Signatur</xsl:attribute>
                        <xsl:value-of select="$vAwmID"/>
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
                        <xsl:text>www.awm.gov.au</xsl:text>
                    </xsl:element>
                    <!-- <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Medium</xsl:attribute>
                        <xsl:text>Postcard</xsl:text>
                    </xsl:element> -->
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
                        <xsl:text>World War, 1914-1918</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Source</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachments">
                    <xsl:element name="tss:attachmentReference">
                        <xsl:element name="URL">
                            <xsl:value-of select="concat($pgUrlImgBase,$vAwmID,'.jpg')"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
  
</xsl:stylesheet>