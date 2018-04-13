<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    >
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- This stylesheet builds Sente XML and an applescript from the links to delcampe auctions -->
    <!-- the input is an html file containing a <div> with links to full detail pages on the Delcampe website. The file is usually produced dragging and dropping links into a folder on the desktop and then pasting all those links into the div -->
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
    <!-- v1d: relocated the generation of the applescript to an external stylesheet to be used by all XSLT for downloading images from the web. The template tAppleScript needs to be supplied with a target folder, and lists of files to be downloaded and their corresponding file names on the local computer
    pTargetFolder must be wrapped in single quotes to make it a literal string
    pUrlDoc and pID are comma-separated lists of values in double quotes
    - changed the URL to link to the new location at BachSources on my main HD -->
    <!-- v1c: replaced the call of the replace template with the replace() function. save the results as files -->
    <!-- v1a: original version -->
    <!-- v1b: the redundancy of four servers is not necessary and thus cut. AucID can be shorter than 9 digits; in this case zeros have to be added to the left -->
    <!--
    - mode m5 produces an applescript to download the image files to the hd 
    - mode m4 produces the Sente XML references with links to the downloaded images
    -->
    


    <xsl:variable name="vgDate" select="current-date()"/>
    
    
    <xsl:template match="html:html">
        <xsl:apply-templates mode="m4"/>
    </xsl:template>
   
    
    <xsl:template match="html:div" mode="m4">
        <xsl:result-document href="ebay2Sente {format-date($vgDate,'[Y01][M01][D01]')}.Sente.xml" method="xml">
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
    
    
    
    <xsl:template name="templReferencesM4">
        <xsl:variable name="v_url-base" select="'http://www.ebay.com/itm/'"/>
        <!-- links follow this pattern: http://www.ebay.com/itm/syria-DAMAS-DAMASCUS-Gouvernment-House-1910s-RPPC-/360952344727?hash=item540a6fb097:g:lNgAAOxy3cJTjecD -->
        <xsl:for-each select="html:a">
            <xsl:variable name="v_url">
                <xsl:value-of select="@href"/>
            </xsl:variable>
            <xsl:variable name="v_id">
                <xsl:analyze-string select="$v_url" regex="/(\d+)\?">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:variable name="v_title">
                <xsl:analyze-string select="$v_url" regex="{$v_url-base}(.+)/(\d+)\?">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
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
                        <xsl:value-of select="replace($v_title,'-',' ')"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">abstractText</xsl:attribute>
                        <xsl:value-of select="replace($v_title,'-',' ')"/>
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
                        <xsl:value-of select="$v_id"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">URL</xsl:attribute>
                        <xsl:value-of select="concat($v_url-base,$v_id)"/>
                        <!--<xsl:value-of select="$vURL"/>-->
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Web data source</xsl:attribute>
                        <xsl:text>ebay</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Medium</xsl:attribute>
                        <xsl:text>Postcard</xsl:text>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:keywords">
                    <!--<xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Damascus</xsl:text>
                    </xsl:element>-->
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
                <!--<xsl:element name="tss:attachments">
                    <xsl:variable name="vNum" select="'1,2,3'"/>
                        <xsl:for-each select="tokenize($vNum,',')"> <!-\- to account for some issues with more pages, the range is significantly longer then the standard number of pages per issue -\->
                            <xsl:variable name="vImg" select="number(.)"/>
                            <xsl:element name="tss:attachmentReference">
                                <xsl:element name="URL">
                                    <xsl:value-of select="concat($vUrlImgBase,$vAucID,'_00',$vImg,'.jpg')"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                </xsl:element>-->
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
  
</xsl:stylesheet>