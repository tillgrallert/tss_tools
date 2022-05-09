<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs kml oape tei html" version="3.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no" version="1.0"/>
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
    <xsl:param name="p_url-base-ebay" select="'https://www.ebay.de/itm/'"/>
    <xsl:param name="p_url-base-image-ebay" select="'https://i.ebayimg.com/images/g/'"/>
    <xsl:param name="p_image-resolution" select="2000"/>
    <xsl:template match="html:html">
        <xsl:result-document href="ebay2Sente {format-date($vgDate,'[Y01][M01][D01]')}.Sente.xml" method="xml">
            <xsl:element name="tss:senteContainer">
                <xsl:attribute name="version">1.0</xsl:attribute>
                <xsl:element name="tss:library">
                    <xsl:element name="tss:references">
                        <xsl:apply-templates select="html:body//html:a"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    <xsl:template match="html:a" mode="m_test">
        <ab>
            <span>
                <xsl:copy-of select="oape:ebay-get-image(@href)"/>
            </span>
            <span>
                <xsl:copy-of select="oape:ebay-get-title(@href)"/>
            </span>
            <span>
                <xsl:copy-of select="oape:ebay-get-images(@href)"/>
            </span>
        </ab>
        <ab>
            <xsl:copy-of select="oape:ebay-get-meta(@href)"/>
        </ab>
    </xsl:template>
    <xsl:function name="oape:ebay-get-data">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:param as="xs:string" name="p_output"/>
        <xsl:choose>
            <xsl:when test="$p_output = 'id'">
                <xsl:choose>
                    <xsl:when test="matches($p_url, 'ebay\.')">
                        <xsl:value-of select="replace($p_url, '^.+/(\d+).*$', '$1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>It seems the input (</xsl:text>
                            <xsl:value-of select="$p_url"/>
                            <xsl:text>) is not an Ebay URL.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="oape:ebay-get-id">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:choose>
            <xsl:when test="matches($p_url, 'ebay\.')">
                <xsl:value-of select="replace($p_url, '^.+/(\d+).*$', '$1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>It seems the input (</xsl:text>
                    <xsl:value-of select="$p_url"/>
                    <xsl:text>) is not an Ebay URL.</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="oape:ebay-get-meta">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:variable name="v_item" select="oape:ebay-get-id($p_url)"/>
        <xsl:variable as="xs:string" name="v_url-item" select="concat($p_url-base-ebay, $v_item)"/>
        <xsl:variable name="v_raw-html" select="unparsed-text($v_url-item)"/>
        <!-- select bits and pieces of the raw HTML with regex -->
        <xsl:analyze-string flags="i" regex="meta\s+(name|property)=&quot;(.+?)&quot;\s+(content)=&quot;(.+?)&quot;" select="$v_raw-html">
            <xsl:matching-substring>
                <meta>
                    <xsl:attribute name="{lower-case(regex-group(1))}">
                        <xsl:value-of disable-output-escaping="true" select="normalize-space(regex-group(2))"/>
                    </xsl:attribute>
                    <xsl:attribute name="{lower-case(regex-group(3))}">
                        <xsl:value-of disable-output-escaping="true" select="normalize-space(regex-group(4))"/>
                    </xsl:attribute>
                </meta>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <xsl:function name="oape:ebay-get-image">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:variable name="v_meta" select="oape:ebay-get-meta($p_url)"/>
        <xsl:apply-templates mode="m_meta" select="$v_meta/self::html:meta[@property = 'og:image']"/>
    </xsl:function>
    <xsl:function name="oape:ebay-get-title">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:variable name="v_meta" select="oape:ebay-get-meta($p_url)"/>
        <xsl:apply-templates mode="m_meta" select="$v_meta/self::html:meta[@property = 'og:title']"/>
    </xsl:function>
    <xsl:template match="html:meta[@property = 'og:image']" mode="m_meta">
        <xsl:variable name="v_id-image" select="replace(@content, concat($p_url-base-image-ebay, '(.+?)/.+$'), '$1')"/>
        <xsl:variable name="v_url-image" select="concat($p_url-base-image-ebay, $v_id-image, '/s-l', $p_image-resolution, '.jpg')"/>
        <xsl:value-of select="$v_url-image"/>
    </xsl:template>
    <xsl:template match="html:meta[@property = 'og:title']" mode="m_meta">
        <xsl:value-of select="replace(@content, '\s+\|\s+eBay', '')"/>
    </xsl:template>
    <xsl:function name="oape:ebay-get-images">
        <xsl:param as="xs:string" name="p_url"/>
        <xsl:variable name="v_item" select="oape:ebay-get-id($p_url)"/>
        <xsl:variable as="xs:string" name="v_url-item" select="concat($p_url-base-ebay, $v_item)"/>
        <xsl:variable name="v_raw-html" select="unparsed-text($v_url-item)"/>
        <!-- select bits and pieces of the raw HTML with regex -->
        <xsl:analyze-string flags="i" regex="'(&lt;ul\s+id=&quot;vertical-align-items-viewport&quot;.+?&lt;/ul&gt;)'" select="$v_raw-html">
            <xsl:matching-substring>
                <xsl:value-of disable-output-escaping="true" select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message>
                    <xsl:text>Did not find the image block</xsl:text>
                </xsl:message>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <xsl:template match="html:a">
        <xsl:variable name="v_url-base" select="$p_url-base-ebay"/>
        <!-- links follow this pattern: http://www.ebay.com/itm/syria-DAMAS-DAMASCUS-Gouvernment-House-1910s-RPPC-/360952344727?hash=item540a6fb097:g:lNgAAOxy3cJTjecD -->
        <xsl:variable name="v_url" select="@href"/>
        <xsl:variable name="v_id" select="oape:ebay-get-id($v_url)"/>
        <xsl:variable name="v_title" select="oape:ebay-get-title($v_url)"/>
        <xsl:variable name="vDate" select="current-date()"/>
        <xsl:element name="tss:reference">
            <xsl:element name="tss:publicationType">
                <xsl:attribute name="name">Photograph</xsl:attribute>
            </xsl:element>
            <xsl:element name="tss:dates">
                <xsl:element name="tss:date">
                    <xsl:attribute name="type">Retrieval</xsl:attribute>
                    <xsl:attribute name="day">
                        <xsl:value-of select="format-date($vDate, '[D01]')"/>
                    </xsl:attribute>
                    <xsl:attribute name="month">
                        <xsl:value-of select="format-date($vDate, '[M01]')"/>
                    </xsl:attribute>
                    <xsl:attribute name="year">
                        <xsl:value-of select="format-date($vDate, '[Y0001]')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tss:characteristics">
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">publicationTitle</xsl:attribute>
                    <xsl:value-of select="$v_title"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">abstractText</xsl:attribute>
                    <xsl:value-of select="$v_title"/>
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
                    <xsl:value-of select="concat('Ebay', $v_id)"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">URL</xsl:attribute>
                    <xsl:value-of select="concat($p_url-base-ebay, $v_id)"/>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Web data source</xsl:attribute>
                    <xsl:text>eBay</xsl:text>
                </xsl:element>
                <xsl:element name="tss:characteristic">
                    <xsl:attribute name="name">Medium</xsl:attribute>
                    <xsl:text>Postcard</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:element name="tss:keywords">
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
                <xsl:call-template name="t_create-attachment">
                    <xsl:with-param name="p_url" select="oape:ebay-get-image($v_url)"/>
                </xsl:call-template>
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
    </xsl:template>
    <xsl:template name="t_create-attachment">
        <xsl:param name="p_url"/>
        <xsl:element name="tss:attachmentReference">
            <xsl:element name="URL">
                <xsl:value-of select="$p_url"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
