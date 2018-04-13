<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"
        name="xml"/>
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>

    <!-- This stylesheet tries to build either Sente XML or BibTex from the links to photo and photo albums provided by the EAP.
        The input is a html file.
        - PROBLEM: the html files produces by EAP are not well-formed and cannot be processed with xslt. Thus one has to manually harvest the html containig the links to all photos from the individual album pages (the catalogue only links to the album and not the images themselves.
    -->

    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>
    <xsl:include href="/BachUni/projekte/XML/Html2Sente/applescript v1.xsl"/>
    <xsl:variable name="vgDate" select="current-date()"/>
    <xsl:variable name="vUrlBase" select="'http://eap.bl.uk/database/'"/>

    <xsl:template match="html:html">
        <xsl:apply-templates mode="mSente2"/>
    </xsl:template>
    
    <xsl:template match="html:body" mode="mSente2">
        <xsl:variable name="vAlbumTitle" select=".//html:h4"/>
        <xsl:variable name="vEapNum" select="substring-before($vAlbumTitle,':')"/>
        <xsl:variable name="vEapTitle" select="normalize-space(substring-after($vAlbumTitle,':'))"/>
        <xsl:variable name="vAlbumDesc" select=".//html:td[starts-with(.,'&quot;Description')]"/>
        <xsl:message>
            <xsl:value-of select="$vAlbumDesc"/>
        </xsl:message>
        <xsl:result-document href="EapPhoto2Sente {replace($vEapNum,'/','-')} {format-date($vgDate,'[Y01][M01][D01]')}.xml" method="xml">
            <xsl:element name="tss:senteContainer">
                <xsl:attribute name="version">1.0</xsl:attribute>
                <xsl:element name="tss:library">
                    <xsl:element name="tss:references">
                        <!--<xsl:apply-templates select=".//html:h4" mode="mSente2">
                            <xsl:with-param name="pEapNum" select="$vEapNum"/>
                            <xsl:with-param name="pEapTitle" select="$vEapTitle"/>
                            <xsl:with-param name="pAlbumDesc" select="$vAlbumDesc"/>
                        </xsl:apply-templates>-->
                        <xsl:apply-templates select=".//html:div[@id='gallery']//html:li/html:a" mode="mSente2">
                            <xsl:with-param name="pEapNum" select="$vEapNum"/>
                            <xsl:with-param name="pEapTitle" select="$vEapTitle"/>
                            <xsl:with-param name="pAlbumDesc" select="$vAlbumDesc"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
        <!-- this downloads the album htmls -->
        <!--<xsl:result-document href="EapPhoto2Sente {format-date($vgDate,'[Y01][M01][D01]')}.scpt" method="text">
            <xsl:call-template name="tAppleScript">
                <xsl:with-param name="pTargetFolder"
                    select="'/BachUni/BachSources/EAP644 Bonfils Collection/Websites'"/>
                <xsl:with-param name="pUrlBase" select="$vUrlBase"/>
                <xsl:with-param name="pUrlDoc">
                    <xsl:for-each select=".//html:td/html:a[not(.='')]">
                        <xsl:value-of select="concat('&quot;',@href,'&quot;')"/>
                        <xsl:if test="position()!= last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:with-param>
                <xsl:with-param name="pID">
                    <xsl:for-each select=".//html:td/html:a[not(.='')]">
                        <xsl:value-of select="concat('&quot;',replace(substring-before(.,':'),'/','-'),'&quot;')"/>
                        <xsl:if test="position()!= last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>-->
        <xsl:result-document href="EapPhoto2Sente {replace($vEapNum,'/','-')} {format-date($vgDate,'[Y01][M01][D01]')}.scpt" method="text">
            <xsl:call-template name="tAppleScript">
                <xsl:with-param name="pTargetFolder"
                    select="'/BachUni/BachSources/EAP644 Bonfils Collection/Photos'"/>
                <xsl:with-param name="pUrlBase" select="''"/>
                <xsl:with-param name="pUrlDoc">
                    <xsl:for-each select=".//html:div[@id='gallery']//html:li/html:a">
                        <xsl:value-of select="concat('&quot;',@href,'&quot;')"/>
                        <xsl:if test="position()!= last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:with-param>
                <xsl:with-param name="pID">
                    <xsl:for-each select=".//html:div[@id='gallery']//html:li/html:a">
                        <xsl:variable name="vFileName">
                            <xsl:analyze-string select="@href" regex="(TFDC.+)(.jpg)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:value-of select="concat('&quot;',$vFileName,'&quot;')"/>
                        <xsl:if test="position()!= last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    
    <!-- generate the album tss:reference -->
    <!--<xsl:template match="html:h4" mode="mSente2">
        <!-\- as some items have their front and back scanned, I limit new tss:reference entries to the first scan and attach links to more than one image -\->
        <xsl:param name="pEapNum"/>
        <xsl:param name="pEapTitle"/>
        <xsl:param name="pAlbumDesc"/>
        <xsl:element name="tss:reference">
            <xsl:element name="tss:publicationType">
                <xsl:attribute name="name">Archival File</xsl:attribute>
            </xsl:element>
            <xsl:element name="tss:authors">
                <xsl:element name="tss:author">
                    <xsl:attribute name="role">Photographer</xsl:attribute>
                    <xsl:element name="tss:surname">Bonfils</xsl:element>
                </xsl:element>
            </xsl:element>
            <!-\-<xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Publication</xsl:attribute>
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
                </xsl:element>-\->
            <xsl:element name="tss:characteristics">
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">articleTitle</xsl:attribute>
                    <xsl:value-of select="$pEapTitle"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">publicationTitle</xsl:attribute>
                    <xsl:value-of select="$pEapTitle"/>
                </xsl:element>
                <!-\-<!-\\- this element is to be omitted for all but muqtabas and qabas -\\->
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">volume</xsl:attribute>
                        <!-\\- this should actually be issue, but for the sake of file organisation i made this decision some years ago -\\->
                        <xsl:if test="$pSearch=('19','20')">
                            <xsl:for-each select="$vIssue/issue">
                                <xsl:if
                                    test="substring-after(.,',')=format-date($vPubDate,'[Y0001]-[M01]-[D01]')">
                                    <xsl:value-of select="substring-before(.,',')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="$pSearch='7'">
                            <xsl:value-of select="100+$vCount"/>
                        </xsl:if>
                    </xsl:element>-\->
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Publisher</xsl:attribute>
                    <xsl:value-of select="'Maison Bonfils'"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Repository</xsl:attribute>
                    <xsl:value-of select="'EAP'"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">call-num</xsl:attribute>
                    <xsl:value-of select="$pEapNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    <xsl:value-of select="$pEapNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">URL</xsl:attribute>
                    <xsl:value-of select="$vUrl"/>
                </xsl:element>
                <!-\-<xsl:if test="$vgCal='J'">
                        <xsl:element name="tss:characteristic">
                            <xsl:attribute name="name">Date Rumi</xsl:attribute>
                            <xsl:value-of select="concat($vDay,' ', $vMonthJulian,' ', $vYear)"/>
                        </xsl:element>
                    </xsl:if>-\->
            </xsl:element>
            <xsl:element name="tss:attachments">
                <xsl:element name="tss:attachmentReference">
                    <!-\-<xsl:attribute name="type">HTML document</xsl:attribute>-\->
                    <xsl:element name="name">
                        <xsl:text>Archived Website </xsl:text>
                        <xsl:value-of select="$vgDate"/>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="concat('file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Websites/',replace($vEapNum,'/','-'),'.html')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <!-\-<xsl:attribute name="type">Website</xsl:attribute>-\->
                    <xsl:element name="name">
                        <xsl:text>URL</xsl:text>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrl"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    -->
    <xsl:template match="html:li/html:a" mode="mSente2">
        <!-- as some items have their front and back scanned, I limit new tss:reference entries to the first scan and attach links to more than one image -->
        <xsl:param name="pEapNum"/>
        <xsl:param name="pEapTitle"/>
        <xsl:param name="pAlbumDesc"/>
        <xsl:variable name="vImgCount">
            <xsl:value-of select="count(preceding::html:a[ancestor::html:div[@id='gallery']]) +1"/>
        </xsl:variable>
        <xsl:variable name="vImgDesc">
            <xsl:value-of select="tokenize($pAlbumDesc,'(Image\s\d+:\s+)')[$vImgCount +1]"/>
        </xsl:variable>
        <xsl:variable name="vUrl" select="@href"/>
        <xsl:variable name="vCallNum">
            <xsl:analyze-string select="$vUrl" regex="(TFDC.+)_(\d+_L\.jpg)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:element name="tss:reference">
            <xsl:element name="tss:publicationType">
                <xsl:attribute name="name">Photograph</xsl:attribute>
            </xsl:element>
            <xsl:element name="tss:authors">
                <xsl:element name="tss:author">
                    <xsl:attribute name="role">Photographer</xsl:attribute>
                    <xsl:element name="tss:surname">Bonfils</xsl:element>
                </xsl:element>
            </xsl:element>
            <!--<xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Publication</xsl:attribute>
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
                </xsl:element>-->
            <xsl:element name="tss:characteristics">
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">articleTitle</xsl:attribute>
                    <xsl:value-of select="concat('Image ',$vImgCount,': ',$vImgDesc)"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">publicationTitle</xsl:attribute>
                    <xsl:value-of select="$pEapTitle"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">abstractText</xsl:attribute>
                    <xsl:value-of select="concat('Image ',$vImgCount,': ',$vImgDesc)"/>
                </xsl:element>
                <!--<!-\- this element is to be omitted for all but muqtabas and qabas -\->
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">volume</xsl:attribute>
                        <!-\- this should actually be issue, but for the sake of file organisation i made this decision some years ago -\->
                        <xsl:if test="$pSearch=('19','20')">
                            <xsl:for-each select="$vIssue/issue">
                                <xsl:if
                                    test="substring-after(.,',')=format-date($vPubDate,'[Y0001]-[M01]-[D01]')">
                                    <xsl:value-of select="substring-before(.,',')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="$pSearch='7'">
                            <xsl:value-of select="100+$vCount"/>
                        </xsl:if>
                    </xsl:element>-->
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">publicationCountry</xsl:attribute>
                    <xsl:value-of select="'Beyrouth'"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Publisher</xsl:attribute>
                    <xsl:value-of select="'Maison Bonfils'"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Repository</xsl:attribute>
                    <xsl:value-of select="'EAP'"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">call-num</xsl:attribute>
                    <xsl:value-of select="concat($pEapNum,' ',$vCallNum)"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Signatur</xsl:attribute>
                    <xsl:value-of select="concat($pEapNum,' ',$vCallNum)"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Citation identifier</xsl:attribute>
                    <xsl:value-of select="$vCallNum"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">URL</xsl:attribute>
                    <xsl:value-of select="$vUrl"/>
                </xsl:element>
                <!--<xsl:if test="$vgCal='J'">
                        <xsl:element name="tss:characteristic">
                            <xsl:attribute name="name">Date Rumi</xsl:attribute>
                            <xsl:value-of select="concat($vDay,' ', $vMonthJulian,' ', $vYear)"/>
                        </xsl:element>
                    </xsl:if>-->
            </xsl:element>
            <xsl:element name="tss:attachments">
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="name">
                        <xsl:text>Scan 1</xsl:text>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="concat('file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Photos/',$vCallNum,'_01_L.jpg')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <xsl:element name="name">
                        <xsl:text>Scan 2</xsl:text>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="concat('file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Photos/',$vCallNum,'_02_L.jpg')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <!--<xsl:attribute name="type">Website</xsl:attribute>-->
                    <xsl:element name="name">
                        <xsl:text>URL Scan 1</xsl:text>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="$vUrl"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="tss:attachmentReference">
                    <!--<xsl:attribute name="type">Website</xsl:attribute>-->
                    <xsl:element name="name">
                        <xsl:text>URL Scan 2</xsl:text>
                    </xsl:element>
                    <xsl:element name="URL">
                        <xsl:value-of select="replace($vUrl,'_01_L','_02_L')"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        
    </xsl:template>
   <xsl:template match="html:body" mode="mSente1">
       <xsl:result-document href="EapPhoto2Sente {format-date($vgDate,'[Y01][M01][D01]')}.xml" method="xml">
           <xsl:element name="tss:senteContainer">
               <xsl:attribute name="version">1.0</xsl:attribute>
               <xsl:element name="tss:library">
                   <xsl:element name="tss:references">
                       <xsl:apply-templates select=".//html:td/html:a" mode="mSente1"/>
                   </xsl:element>
               </xsl:element>
           </xsl:element>
       </xsl:result-document>
       <!-- this downloads the album htmls -->
       <xsl:result-document href="EapPhoto2Sente {format-date($vgDate,'[Y01][M01][D01]')}.scpt" method="text">
           <xsl:call-template name="tAppleScript">
               <xsl:with-param name="pTargetFolder"
                   select="'/BachUni/BachSources/EAP644 Bonfils Collection/Websites'"/>
               <xsl:with-param name="pUrlBase" select="$vUrlBase"/>
               <xsl:with-param name="pUrlDoc">
                   <xsl:for-each select=".//html:td/html:a[not(.='')]">
                       <xsl:value-of select="concat('&quot;',@href,'&quot;')"/>
                       <xsl:if test="position()!= last()">
                           <xsl:text>,</xsl:text>
                       </xsl:if>
                   </xsl:for-each>
               </xsl:with-param>
               <xsl:with-param name="pID">
                   <xsl:for-each select=".//html:td/html:a[not(.='')]">
                       <xsl:value-of select="concat('&quot;',replace(substring-before(.,':'),'/','-'),'&quot;')"/>
                       <xsl:if test="position()!= last()">
                           <xsl:text>,</xsl:text>
                       </xsl:if>
                   </xsl:for-each>
               </xsl:with-param>
           </xsl:call-template>
       </xsl:result-document>
   </xsl:template>

   
   <!-- mSente produces individual tss:reference nodes -->
   <xsl:template match="html:a[not(.='')]" mode="mSente1">
       <xsl:variable name="vUrl" select="concat($vUrlBase,@href)"/>
       <xsl:variable name="vLinkText" select="."/>
       <xsl:variable name="vEapNum" select="substring-before($vLinkText,':')"/>
       <xsl:variable name="vEapTitle" select="normalize-space(substring-after($vLinkText,':'))"/>
       <xsl:element name="tss:reference">
           <xsl:element name="tss:publicationType">
               <xsl:attribute name="name">Archival File</xsl:attribute>
           </xsl:element>
           <xsl:element name="tss:authors">
               <xsl:element name="tss:author">
                   <xsl:attribute name="role">Photographer</xsl:attribute>
                   <xsl:element name="tss:surname">Bonfils</xsl:element>
               </xsl:element>
           </xsl:element>
           <!--<xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Publication</xsl:attribute>
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
                </xsl:element>-->
           <xsl:element name="tss:characteristics">
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">articleTitle</xsl:attribute>
                   <xsl:value-of select="$vEapTitle"/>
               </xsl:element>
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">publicationTitle</xsl:attribute>
                   <xsl:value-of select="$vEapTitle"/>
               </xsl:element>
               <!--<!-\- this element is to be omitted for all but muqtabas and qabas -\->
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">volume</xsl:attribute>
                        <!-\- this should actually be issue, but for the sake of file organisation i made this decision some years ago -\->
                        <xsl:if test="$pSearch=('19','20')">
                            <xsl:for-each select="$vIssue/issue">
                                <xsl:if
                                    test="substring-after(.,',')=format-date($vPubDate,'[Y0001]-[M01]-[D01]')">
                                    <xsl:value-of select="substring-before(.,',')"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="$pSearch='7'">
                            <xsl:value-of select="100+$vCount"/>
                        </xsl:if>
                    </xsl:element>-->
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">Publisher</xsl:attribute>
                   <xsl:value-of select="'Maison Bonfils'"/>
               </xsl:element>
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">Repository</xsl:attribute>
                   <xsl:value-of select="'EAP'"/>
               </xsl:element>
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">call-num</xsl:attribute>
                   <xsl:value-of select="$vEapNum"/>
               </xsl:element>
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">Citation identifier</xsl:attribute>
                   <xsl:value-of select="$vEapNum"/>
               </xsl:element>
               <xsl:element name="tss:characteristic">
                   <xsl:attribute name="name">URL</xsl:attribute>
                   <xsl:value-of select="$vUrl"/>
               </xsl:element>
               <!--<xsl:if test="$vgCal='J'">
                        <xsl:element name="tss:characteristic">
                            <xsl:attribute name="name">Date Rumi</xsl:attribute>
                            <xsl:value-of select="concat($vDay,' ', $vMonthJulian,' ', $vYear)"/>
                        </xsl:element>
                    </xsl:if>-->
           </xsl:element>
           <xsl:element name="tss:attachments">
               <xsl:element name="tss:attachmentReference">
                   <!--<xsl:attribute name="type">HTML document</xsl:attribute>-->
                   <xsl:element name="name">
                       <xsl:text>Archived Website </xsl:text>
                       <xsl:value-of select="$vgDate"/>
                   </xsl:element>
                   <xsl:element name="URL">
                       <xsl:value-of select="concat('file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Websites/',replace($vEapNum,'/','-'),'.html')"/>
                   </xsl:element>
               </xsl:element>
               <xsl:element name="tss:attachmentReference">
                   <!--<xsl:attribute name="type">Website</xsl:attribute>-->
                   <xsl:element name="name">
                       <xsl:text>URL</xsl:text>
                   </xsl:element>
                   <xsl:element name="URL">
                       <xsl:value-of select="$vUrl"/>
                   </xsl:element>
               </xsl:element>
           </xsl:element>
       </xsl:element>
       
   </xsl:template>
</xsl:stylesheet>
