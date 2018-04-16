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
    <xsl:output method="xml"  version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"  name="xml"/>
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"  name="text"/>
    
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
    - mode m_applescript produces an applescript to download the image files to the hd 
    - mode m_tss produces the Sente XML references with links to the downloaded images
    -->
    
 
    <xsl:include href="build-applescript_download-images.xsl"/>
    <xsl:variable name="v_today" select="format-date( current-date(),'[Y0001]-[M01]-[D01]')"/>
    
    
    <xsl:template match="html:html">
        <xsl:apply-templates mode="m_tss"/>
        <xsl:apply-templates mode="m_applescript"/>
    </xsl:template>
   
    
    <xsl:template match="html:div" mode="m_tss">
        <xsl:result-document href="_output/delcampe-to-tss_{$v_today}.TSS.xml" method="xml">
        <xsl:element name="tss:senteContainer">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:element name="tss:library">
                <xsl:element name="tss:references">
                    <xsl:call-template name="t_generate-references"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:div" mode="m_applescript">
        <xsl:result-document href="_output/delcampe-to-tss_{$v_today}.scpt" method="text">
            <!-- generate the URL to images for download -->
            <xsl:variable name="vUrlDoc">
                <![CDATA["]]>
                <xsl:for-each select="descendant::html:a[contains(@href,'delcampe')]">
<!--                    <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>-->
                    <!-- find the auction ID -->
                    <xsl:variable name="v_id-auction">
                        <xsl:apply-templates select="." mode="m_id-auction"/>
                    </xsl:variable>
                    <xsl:variable name="vUrl1" select="'http://images-'"/>
                    <xsl:variable name="vUrl2" select="'.delcampe-static.net/img_large/auction/000/'"/>
                    <xsl:variable name="vUrl3" select="concat(substring($v_id-auction,1,3),'/',substring($v_id-auction,4,3),'/',substring($v_id-auction,7,3),'_00')"/>
                    
                    <xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'1.jpg')"/><![CDATA[","]]><xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'2.jpg')"/><![CDATA[","]]><xsl:value-of select="concat($vUrl1,'00',$vUrl2,$vUrl3,'3.jpg')"/>
                    <xsl:if test="not(position()=last())">
                        <![CDATA[","]]>
                    </xsl:if>
                </xsl:for-each>
                <![CDATA["]]>
            </xsl:variable>
            <xsl:variable name="vID">
                <![CDATA["]]>
                <xsl:for-each select="descendant::html:a[contains(@href,'delcampe')]">
<!--                    <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>-->
                    <xsl:variable name="v_id-auction">
                        <xsl:apply-templates select="." mode="m_id-auction"/>
                    </xsl:variable>
                    <xsl:value-of select="concat($v_id-auction,'_001')"/><![CDATA[","]]><xsl:value-of select="concat($v_id-auction,'_002')"/><![CDATA[","]]><xsl:value-of select="concat($v_id-auction,'_003')"/>
                    <xsl:if test="not(position()=last())">
                        <![CDATA[","]]>
                    </xsl:if>
                </xsl:for-each>
                <![CDATA["]]>
            </xsl:variable>
            
        <!-- this section creates the full applescript -->
        
            <xsl:call-template name="t_applescript">
                <xsl:with-param name="p_target-folder" select="'/BachUni/BachSources/postcards-delcampe'"/>
                <xsl:with-param name="p_url-doc" select="$vUrlDoc"/>
                <xsl:with-param name="p_id" select="$vID"/>
            </xsl:call-template>
        
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:a" mode="m_id-auction">
        <xsl:analyze-string select="@href" regex="-(\d+)\.html$|id,(\d+),var,">
            <xsl:matching-substring>
                <!-- the ID should have nine digits-->
                <xsl:value-of select="concat(regex-group(1),regex-group(2))"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template name="t_generate-references">
        <xsl:for-each select="descendant::html:a[contains(@href,'delcampe')]">
<!--            <xsl:sort select="substring-before(substring-after(./@href,'id,'),',var')"/>-->
            <xsl:variable name="vURL">
                <xsl:value-of select="./@href"/>
            </xsl:variable>
            <xsl:variable name="vUrlImgBase" select="'/BachUni/BachSources/postcards-delcampe/'"/>
            <xsl:variable name="v_id-auction">
                <xsl:apply-templates select="." mode="m_id-auction"/>
            </xsl:variable>
            <xsl:variable name="vPubTitle">
                <xsl:choose>
                    <xsl:when test="contains(@href,'var,')">
                        <xsl:value-of select="substring-before(substring-after(@href,'var,'),',language')"/>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:analyze-string select="@href" regex="/(.[^/]+)-\d+.html$">
                           <xsl:matching-substring>
                               <xsl:value-of select="replace(regex-group(1),'-',' ')"/>
                           </xsl:matching-substring>
                       </xsl:analyze-string>
                    </xsl:otherwise>
                </xsl:choose>
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
                        <!-- <xsl:call-template name="funcReplacement">
                            <xsl:with-param name="pString" select="$vPubTitle"/>
                            <xsl:with-param name="pFind" select="'-'"/>
                            <xsl:with-param name="pReplace" select="' '"/>
                        </xsl:call-template> -->
                        <xsl:value-of select="replace($vPubTitle,'-',' ')"/>
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
                        <xsl:value-of select="$v_id-auction"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">URL</xsl:attribute>
                        <xsl:value-of select="concat('http://www.delcampe.net/page/item/id,',$v_id-auction,'.html')"/>
                        <!--<xsl:value-of select="$vURL"/>-->
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
                                    <xsl:value-of select="concat($vUrlImgBase,$v_id-auction,'_00',$vImg,'.jpg')"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
  
</xsl:stylesheet>