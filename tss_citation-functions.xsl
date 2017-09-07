<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:till="http://www.sitzextase.de"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="till functx xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">

    <xsl:output name="html" method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
    <xsl:output name="xml" method="xml" version="1.0" encoding="UTF-8" indent="yes"
        omit-xml-declaration="no"/>

    <!-- this stylesheet provides various functions for formatting references to other stylesheets. The data is provided by a Sente XML library-->
    <!-- v2a/b: the capitalisation rules are now partially aware of the language of a reference. According to Chicago Manual of Styles, non-English titles should be mostly left alone. This still needs more work. -->
    <!-- v2: various improvements -->
    <!-- To do: $vC15-Series-Volume has been built but not yet implemented for any reference type. It is meant to display information on multi-volume works, such as "collected works" which have a series title and volume numbers within the series -->
    <!-- some formatting, particularly capitalization, should / could be based on language information provided in $vLang -->
    <!-- v1: split from BachFunctions
        - funcCitation: fully formatted bibliographic references 
        - funcCitationLink: funcCitation within clickable HTML links back to the Sente library
        - funcCitID: provides the Citation ID for a given reference
        - funcCitUUID: provides the UUID for a given citation id
        - PROBLEM: vPubDate might produce 29 Feb not considered correct by the parser. Thus I discontinued the xml date functions and use numbers instead.
    -->
    <!-- v1b, v1c: updated some minor components -->


    <!-- this template provides a click-able link to a Sente reference -->
    <xsl:template name="funcCitationLink">
        <xsl:param name="pRef" select="ancestor-or-self::tss:reference"/>
        <xsl:param name="pCitID"/>
        <xsl:param name="pLibName" select="'BachBibliographie'"/>
        <xsl:variable name="vCitID">
            <xsl:choose>
                <xsl:when
                    test="$pRef/tss:characteristics/tss:characteristic[@name='Citation identifier']!=''">
                    <xsl:value-of
                        select="replace($pRef/tss:characteristics/tss:characteristic[@name='Citation identifier'],' ','+')"
                    />
                </xsl:when>
                <xsl:when test="$pCitID!=''">
                    <xsl:value-of
                        select="if(contains($pCitID,'@')) then(substring-before($pCitID,'@')) else($pCitID)"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>No+CitationID</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vSenteURL">
            <xsl:value-of select="concat('sente://',$pLibName,'/',$vCitID)"/>
            <!-- <xsl:call-template name="funcCitID"/> -->
        </xsl:variable>

        <a href="{$vSenteURL}">
            <xsl:choose>
                <xsl:when test="$pRef!=''">
                    <xsl:call-template name="funcCitation">
                        <xsl:with-param name="pRef" select="$pRef"/>
                        <xsl:with-param name="pMode" select="'fn'"/>
                        <xsl:with-param name="pOutputFormat" select="'html'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="funcCitation">
                        <xsl:with-param name="pCitID" select="$pCitID"/>
                        <xsl:with-param name="pMode" select="'fn'"/>
                        <xsl:with-param name="pOutputFormat" select="'html'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>

    <xsl:template name="funcCitation">
        <!-- v2d: the template can handle either tss:references or citation identifier  -->
        <!-- plan:
            - the pBibStyle must become functional
            - the template must handle modifier keys in the Sente Citation ID, such as text wrapped in "\ abc \"-->
        <!-- the first set of parameters are input parameters -->
        <xsl:param name="pCitID"/>
        <xsl:param name="pUUID"/>
        <xsl:param name="pRef"/>
        <xsl:param name="pCitedPages"/>
        <xsl:param name="pLibrary"/>
        <!-- the second set of parameters controls the output -->
        <!-- values 'fn', 'fn2' (for successive occurrences in formats such as C15 NB), and 'bibl' -->
        <xsl:param name="pMode"/>
        <xsl:param name="pBibStyle" select="'C15TillArchBib'"/>
        <xsl:param name="pCaps" select="'y'"/>
        <!-- pOutputFormat can have the values 'mmd' for Multimarkdown, 'tei', 'html', or 'docx'  -->
        <xsl:param name="pOutputFormat" select="'docx'"/>

        <!-- provides separating strings between references -->
        <xsl:variable name="vSeparatorPages">
            <xsl:if test="$pBibStyle='C15TillArchBib'">
                <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:if test="$pBibStyle='C15NB'">
                <xsl:choose>
                    <xsl:when test="$pMode='fn2'"/>
                    <xsl:otherwise>
                        <xsl:text>, </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="vSeparatorRefs">
            <xsl:choose>
                <xsl:when test="$pMode='fn' or $pMode='fn2'">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:when test="$pMode='bibl'">
                    <xsl:choose>
                        <xsl:when test="$pOutputFormat='html'">
                            <xsl:text disable-output-escaping="no">.&lt;br /&gt;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- this produces the line-break in bibliographies -->
                            <xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vSeparatorInfo">
            <xsl:choose>
                <xsl:when test="$pMode='fn' or $pMode='fn2'">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:when test="$pMode='bibl'">
                    <xsl:value-of select="'. '"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- separating the two numbers of a page range: in most cases this should be an en-dash and NO HYPHEN -->
        <xsl:variable name="vSeparatorNumericRange" select="$pgEnDash"/>
        <!-- v2d -->
        <!-- vCitID splits the input string into nodes containing individual citation IDs -->
        <xsl:variable name="vCitID">
            <xsl:variable name="vCitIDs" select="translate($pCitID,'\{\}',' ')"/>
            <!-- v1c -->
            <xsl:for-each-group select="tokenize($vCitIDs,';\s*')" group-by=".">
                <xsl:element name="till:citId">
                    <!-- v1b -->
                    <xsl:variable name="vCitId">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[1])"/>
                    </xsl:variable>
                    <xsl:variable name="vProtectedString">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[2])"/>
                    </xsl:variable>

                    <xsl:if test="contains($vCitId,'@')">
                        <xsl:attribute name="citPages">
                            <xsl:value-of
                                select="normalize-space(if(contains($vCitId,'@')) then(substring-after($vCitId,'@')) else())"
                            />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$vProtectedString!=''">
                        <xsl:attribute name="strProt" select="$vProtectedString"/>
                    </xsl:if>
                    <xsl:value-of
                        select="normalize-space(if(contains($vCitId,'@')) then(substring-before($vCitId,'@')) else($vCitId))"
                    />
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>

        <!-- vRefs pulls the references corresponding to the citation IDs in vCitID from the Sente XML library specified in pLibrary -->
        <xsl:variable name="vRefs">
            <xsl:choose>
                <xsl:when test="$pCitID!=''">
                    <!-- this should take into account that some references might not be found in the library -->
                    <xsl:for-each select="$vCitID/till:citId">
                        <xsl:variable name="vCitID1" select="."/>
                        <xsl:element name="tss:reference">
                            <xsl:attribute name="citPages" select="./@citPages"/>
                            <xsl:attribute name="strProt" select="./@strProt"/>
                            <xsl:choose>
                                <!-- check whether the library contains a match -->
                                <xsl:when
                                    test="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=$vCitID1]">
                                    <xsl:variable name="vRef"
                                        select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=$vCitID1]"/>
                                    <xsl:choose>
                                        <!-- check whether the CitationID is unique! -->
                                        <xsl:when test="count($vRef/tss:dates)=1">
                                            <!-- to ease sorting a new attribute is built -->
                                            <xsl:variable name="vPubDate">
                                                <xsl:variable name="vDPubY"
                                                  select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                                                <xsl:variable name="vDPubM"
                                                  select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>
                                                <xsl:variable name="vDPubD"
                                                  select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                                                <xsl:value-of
                                                  select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                                            </xsl:variable>
                                            <xsl:attribute name="datePubl" select="$vPubDate"/>
                                            <xsl:for-each select="$vRef/node()">
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="error">duplicate</xsl:attribute>
                                            <xsl:copy-of select="$vCitID1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="error">not found</xsl:attribute>
                                    <xsl:copy-of select="$vCitID1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$pUUID!=''">
                    <xsl:variable name="vRef"
                        select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='UUID']=$pUUID]"/>
                    <xsl:element name="tss:reference">
                        <!-- to ease sorting a new attribute is built -->
                        <xsl:variable name="vPubDate">
                            <xsl:variable name="vDPubY"
                                select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                            <xsl:variable name="vDPubM"
                                select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>
                            <xsl:variable name="vDPubD"
                                select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                            <xsl:value-of select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                        </xsl:variable>
                        <xsl:attribute name="datePubl" select="$vPubDate"/>
                        <xsl:for-each select="$vRef/node()">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$pRef"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vRefsSorted">
            <xsl:for-each select="$vRefs/tss:reference">
                <!-- sort in bibliography: by reference type -->
                <xsl:sort
                    select="if($pMode='bibl') then(if(contains(./tss:publicationType/@name,'Archival') or contains(./tss:publicationType/@name,'Newspaper') or contains(./tss:publicationType/@name,'Maps') or contains(./tss:publicationType/@name,'Photo') or contains(./tss:publicationType/@name,'Bill')) then(./tss:publicationType/@name) else()) else()"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <!-- sort in bibliography: by reference signature if reference is archival material -->
                <xsl:sort
                    select="if($pMode='bibl') then(if(contains(./tss:publicationType/@name,'Archival')) then(./tss:characteristics/tss:characteristic[@name='Signatur']) else()) else()"/>
                <!-- sort in bibliography: by surname -->
                <xsl:sort
                    select="if($pMode='bibl') then(if(substring(./tss:authors/tss:author[1]/tss:surname,1,3)='al-') then(substring(./tss:authors/tss:author[1]/tss:surname,4)) else(./tss:authors/tss:author[1]/tss:surname)) else()"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <!-- sort in bibliography: by forename -->
                <xsl:sort
                    select="if($pMode='bibl') then(./tss:authors/tss:author[1]/tss:forenames) else()"
                    collation="http://saxon.sf.net/collation?rules={encode-for-uri($sortIjmes)}"/>
                <!-- sort in footnotes and bibliographies: by publication date -->
                <xsl:sort
                    select="if(@datePubl) then(@datePubl) else(./tss:dates/tss:date[@type='Publication']/@year)"
                    order="ascending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>

        </xsl:variable>


        <xsl:for-each select="$vRefsSorted/tss:reference">
            <xsl:variable name="vRef" select="."/>
            <xsl:choose>
                <!-- returns the original Citation IDs, when nothing is found in the library-->
                <!-- the test for @error works -->
                <xsl:when test="$vRef/@error">
                    <!-- till:citId is correctly produced -->
                    <xsl:value-of select="concat('{',$vRef//till:citId)"/>
                    <!-- cited pages can be passed on through the @citPages or pCitedPages -->
                    <xsl:choose>
                        <xsl:when test="$pCitedPages!=''">
                            <xsl:value-of select="concat('@',$pCitedPages)"/>
                        </xsl:when>
                        <xsl:when test="$vRef/@citPages!=''">
                            <xsl:value-of select="concat('@',$vRef/@citPages)"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- provide the error code for duplicates -->
                    <xsl:if test="$vRef/@error!=''">
                        <xsl:value-of select="concat(' **',$vRef/@error,'** ')"/>
                    </xsl:if>

                    <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- v2b: capitalisations depends on vLand -->
                    <xsl:variable name="vLang">
                        <xsl:choose>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'arabic')">
                                <xsl:value-of select="'ar'"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'ottoman')">
                                <xsl:value-of select="'ota'"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'turkish')">
                                <xsl:value-of select="'tr'"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'german')">
                                <xsl:value-of select="'de'"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'french')">
                                <xsl:value-of select="'fr'"/>
                            </xsl:when>
                            <xsl:when test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'english')">
                                <xsl:value-of select="'en'"/>
                            </xsl:when>
                            <!-- assuming that the norm would be english -->
                            <xsl:otherwise>
                                <xsl:variable name="vTitle">
                                    <xsl:choose>
                                        <xsl:when test="contains(lower-case($vRef/tss:publicationType/@name),'article')">
                                            <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='articleTitle']"/>
                                        </xsl:when>
                                        <xsl:when test="contains(lower-case($vRef/tss:publicationType/@name),'chapter')">
                                            <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='articleTitle']"/>
                                        </xsl:when>
                                        <xsl:when test="not(./tss:characteristics/tss:characteristic[@name='publicationTitle'])">
                                            <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='articleTitle']"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='publicationTitle']"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <!-- try to gues the language -->
                                
                                    <xsl:call-template name="funcStringLanguageTest">
                                        <xsl:with-param name="pInput" select="$vTitle"/>
                                        <xsl:with-param name="pOutputFormat" select="'short'"/>
                                    </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="vDatePubl">
                        <!-- Sente allows to produce dates, which are considered incorrect by the built-in date functions. this is mainly the case for some 29 Feb. This can either be solved through a local formatting option to circumvent the "format-date" calls or through replacing every 29 Feb with 28 Feb -->
                        <xsl:variable name="vDPubY"
                            select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                        <!--<xsl:variable name="vDPubM" select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>-->
                        <xsl:variable name="vDPubD"
                            select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                        <!--<xsl:variable name="vDate">
                            <xsl:value-of select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                        </xsl:variable>-->

                        <!--<!-\- in case the reference is tagged with "approximate date", the date should be prepended by "c. " -\->
                        <xsl:if test="$vRef/tss:keywords/tss:keyword='approximate date'">
                            <xsl:text>c. </xsl:text>
                        </xsl:if>-->
                        <xsl:choose>
                            <xsl:when test="contains($vRef/tss:publicationType/@name,'Book')">
                                <xsl:value-of select="$vDPubY"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$vRef/tss:dates/tss:date[@type='Publication']/@day">
                                    <xsl:value-of
                                        select="concat(format-number(number($vDPubD),'0'),' ')"/>
                                </xsl:if>
                                <xsl:if test="$vRef/tss:dates/tss:date[@type='Publication']/@month">
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pMonth"
                                            select="$vRef/tss:dates/tss:date[@type='Publication']/@month"/>
                                        <xsl:with-param name="pLang" select="'GEn'"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="$vDPubY"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vDatePublWeekday">
                        <xsl:variable name="vDPubY"
                            select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:variable name="vDPubM"
                            select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>
                        <xsl:variable name="vDPubD"
                            select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                        <xsl:variable name="vDate">
                            <xsl:value-of select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                        </xsl:variable>
                        <xsl:if test="$vDate castable as xs:date">
                            <xsl:value-of select="format-date($vDate,' ([FNn, *-3])')"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vDateOrig">
                        <xsl:value-of
                            select="if($vRef/tss:dates/tss:date[@type='Original']/@day) then(concat($vRef/tss:dates/tss:date[@type='Original']/@day,' ')) else()"/>
                        <xsl:if test="$vRef/tss:dates/tss:date[@type='Original']/@month">
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pMonth"
                                    select="$vRef/tss:dates/tss:date[@type='Original']/@month"/>
                                <xsl:with-param name="pLang" select="'GEn'"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$vRef/tss:dates/tss:date[@type='Original']/@year"/>
                    </xsl:variable>
                    <!-- needs to be implemented -->
                    <xsl:variable name="vDateH">
                        <xsl:value-of
                            select="if($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri']!='') then(concat($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],' aH')) else()"
                        />
                    </xsl:variable>
                    <xsl:variable name="vDateH2G">
                        <xsl:variable name="vDateHNorm">
                            <xsl:call-template name="funcDateNormaliseInput">
                                <!-- somehow this suddenly started to through an error, as if Saxon tried to precompute variables even in cases when they are not called further down the line -->
                                <xsl:with-param name="pDateString"
                                    select="if($vDateH!='') then($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri']) else('1000')"/>
                                <xsl:with-param name="pLang" select="'HIjmes'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateG">
                            <xsl:call-template name="funcDateH2G">
                                <xsl:with-param name="pDateH" select="$vDateHNorm"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="format-number(number(tokenize($vDateG,'-')[1]),'0')"/>
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="funcDateMonthNameNumber">
                            <xsl:with-param name="pMonth" select="number(tokenize($vDateG,'-')[2])"/>
                            <xsl:with-param name="pLang" select="'GEn'"/>
                            <xsl:with-param name="pMode" select="'name'"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($vDateG,'-')[3]"/>
                    </xsl:variable>
                    <xsl:variable name="vDateHY2G">
                        <xsl:call-template name="funcDateHY2G">
                            <xsl:with-param name="pYearH"
                                select="$vRef/tss:characteristics/tss:characteristic[@name='Date Hijri']"
                            />
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vDateMY2G">
                        <xsl:call-template name="funcDateMY2G">
                            <xsl:with-param name="pYearM"
                                select="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']"
                            />
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vDateRorM">
                        <!-- based on the year range, I decide whether a date is Rūmī or Mālī. Everything below 1400 will be considered Mālī -->
                        <xsl:value-of
                            select="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']"/>
                        <xsl:if
                            test="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']!=''">
                            <xsl:analyze-string
                                select="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']"
                                regex="(\d{{4}})">
                                <xsl:matching-substring>
                                    <xsl:choose>
                                        <xsl:when test="number(regex-group(1)) &lt; 1400">
                                            <xsl:text> M</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text> R</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vDateHR">
                        <!-- this needs updating for all the cases that have either or -->
                        <!--<xsl:if
                            test="$vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'] or $vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']">
                            <xsl:value-of select="concat(' [',$vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'aH / ',$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi'],'R',']')"/>
                        </xsl:if>-->
                        <xsl:choose>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'] and $vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']">
                                <xsl:value-of select="concat(' [',$vDateH, ' / ',$vDateRorM,']')"/>
                            </xsl:when>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Date Hijri']">
                                <xsl:value-of select="concat(' [',$vDateH,']')"/>
                            </xsl:when>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']">
                                <xsl:value-of select="concat(' [',$vDateRorM,']')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vDateRetrieval">
                        <xsl:value-of
                            select="format-number(number($vRef/tss:dates/tss:date[@type='Retrieval']/@day),'0')"/>
                        <xsl:text> </xsl:text>
                        <xsl:if test="$vRef/tss:dates/tss:date[@type='Retrieval']/@month">
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pMonth"
                                    select="$vRef/tss:dates/tss:date[@type='Retrieval']/@month"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                                <xsl:with-param name="pLang" select="'GEn'"/>


                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$vRef/tss:dates/tss:date[@type='Retrieval']/@year"/>
                    </xsl:variable>
                    <xsl:variable name="vArchClassMarkShort">
                        <xsl:value-of
                            select="if($vRef/tss:characteristics/tss:characteristic[@name='Signatur']) then(concat($vRef/tss:characteristics/tss:characteristic[@name='Repository'],' ',$vRef/tss:characteristics/tss:characteristic[@name='Signatur'])) else()"
                        />
                    </xsl:variable>
                    <xsl:variable name="vArchClassMarkLong">
                        <xsl:if
                            test="$vRef/tss:characteristics/tss:characteristic[@name='Signatur']">
                            <xsl:value-of select="$vArchClassMarkShort"/>
                            <xsl:value-of
                                select="if($vRef/tss:characteristics/tss:characteristic[@name='publicationCountry']) then(concat(' ',$vRef/tss:characteristics/tss:characteristic[@name='publicationCountry'])) else()"/>
                            <xsl:value-of
                                select="if($vRef/tss:characteristics/tss:characteristic[@name='issue']) then(concat(' ',$vRef/tss:characteristics/tss:characteristic[@name='issue'])) else()"
                            />
                        </xsl:if>
                    </xsl:variable>

                    <xsl:variable name="vArchDate">
                        <xsl:value-of select="$vDateH"/>
                        <!-- introduces a separator if both Hijrī and Rūmī dates are present -->
                        <xsl:if test="$vDateH!='' and $vDateRorM!=''">
                            <xsl:text> / </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$vDateRorM"/>

                        <xsl:if test="$vDateH!='' or $vDateRorM!=''">
                            <xsl:text> [</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$vRef/tss:publicationType[@name='Bill']">
                                <xsl:choose>
                                    <xsl:when test="$vDateOrig!=''">
                                        <xsl:value-of select="$vDateOrig"/>
                                    </xsl:when>
                                    <xsl:when test="$vDateH!=''">
                                        <xsl:value-of select="$vDateH2G"/>
                                    </xsl:when>
                                    <!--<xsl:otherwise>
                                        <xsl:value-of select="$vDateH2G"/>
                                    </xsl:otherwise>-->
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test=" $vRef/tss:publicationType[@name='Photograph']">
                                <xsl:choose>
                                    <xsl:when test="$vDateOrig!=''">
                                        <xsl:value-of select="$vDateOrig"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vDatePubl"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when
                                test="string-length($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'])=4">
                                <xsl:value-of select="$vDateHY2G"/>
                            </xsl:when>
                            <xsl:when
                                test="string-length($vRef/tss:characteristics/tss:characteristic[@name='Date Rumi'])=4">
                                <xsl:value-of select="$vDateMY2G"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vDatePubl"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$vDateH!='' or $vDateRorM!=''">
                            <xsl:text>]</xsl:text>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:variable name="vAuthorPrimaryRole">
                        <xsl:value-of select="$vRef/tss:authors/tss:author[1]/@role"/>
                    </xsl:variable>
                    <xsl:variable name="vAuthors">
                        <!-- would be great to implement an idem loop -->
                        <!-- only used for published works -->
                        <xsl:if test="$pMode='fn'">
                            <!-- debug: I have no idea, why the @test="$pMode='fn' or 'fn2'" is not working in this case. -->
                            <!--<xsl:choose>
                                <xsl:when test="$vRef/tss:authors/tss:author">
                                    <xsl:value-of select="$vRef/tss:authors/tss:author[1]/tss:forenames"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$vRef/tss:authors/tss:author[1]/tss:surname"/>
                                    <xsl:if test="$vRef/tss:authors/tss:author[2][@role=$vAuthorPrimaryRole]">
                                        <xsl:text> et al.</xsl:text>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$vRef/tss:authors/tss:author[2][@role=$vAuthorPrimaryRole][@role='Editor']">
                                            <xsl:text>, eds.</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="$vAuthorPrimaryRole='Editor'">
                                            <xsl:text>, ed.</xsl:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>N.N.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>-->
                            <xsl:choose>
                                <xsl:when test="$vRef/tss:publicationType[@name='Edited Book']">
                                    <xsl:variable name="vNames">
                                        <xsl:for-each
                                            select="$vRef/tss:authors/tss:author[@role='Editor']">
                                            <xsl:element name="till:li">
                                                <xsl:value-of
                                                  select="concat(./tss:forenames,' ',./tss:surname)"
                                                />
                                            </xsl:element>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:call-template name="funcStringOxfordComma">
                                        <xsl:with-param name="pLiInput" select="$vNames"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when
                                            test="count($vRef/tss:authors/tss:author[@role='Editor'])&gt;1">
                                            <xsl:text>, eds.</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>, ed.</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="not($vRef/tss:authors/tss:author)">
                                        <xsl:text>N.N., ed.</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="vNames">
                                        <xsl:for-each
                                            select="$vRef/tss:authors/tss:author[@role='Author']">
                                            <xsl:element name="till:li">
                                                <!--<xsl:choose>
                                                    <xsl:when test="position()=1">
                                                        <xsl:value-of select="concat(./tss:surname,', ',./tss:forenames)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="concat(./tss:forenames,' ',./tss:surname)"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>-->
                                                <xsl:value-of
                                                  select="concat(./tss:forenames,' ',./tss:surname)"
                                                />
                                            </xsl:element>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:call-template name="funcStringOxfordComma">
                                        <xsl:with-param name="pLiInput" select="$vNames"/>
                                    </xsl:call-template>
                                    <xsl:if test="not($vRef/tss:authors/tss:author)">
                                        <xsl:text>N.N.</xsl:text>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="$pMode='fn2'">
                            <xsl:choose>
                                <xsl:when test="$vRef/tss:authors/tss:author">
                                    <xsl:value-of
                                        select="$vRef/tss:authors/tss:author[1]/tss:surname"/>
                                    <xsl:if
                                        test="$vRef/tss:authors/tss:author[2][@role=$vAuthorPrimaryRole]">
                                        <xsl:text> et al.</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>N.N.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="$pMode='bibl'">
                            <xsl:choose>
                                <xsl:when test="$vRef/tss:publicationType[@name='Edited Book']">
                                    <xsl:variable name="vNames">
                                        <xsl:for-each
                                            select="$vRef/tss:authors/tss:author[@role='Editor']">
                                            <xsl:element name="till:li">
                                                <xsl:choose>
                                                  <xsl:when test="position()=1">
                                                  <xsl:value-of select="./tss:surname"/>
                                                  <xsl:if test="./tss:forenames!=''">
                                                  <xsl:value-of
                                                  select="concat(', ',./tss:forenames)"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat(./tss:forenames,' ',./tss:surname)"
                                                  />
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:element>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:call-template name="funcStringOxfordComma">
                                        <xsl:with-param name="pLiInput" select="$vNames"/>
                                    </xsl:call-template>
                                    <xsl:choose>
                                        <xsl:when
                                            test="count($vRef/tss:authors/tss:author[@role='Editor'])&gt;1">
                                            <xsl:text>, eds.</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>, ed.</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="not($vRef/tss:authors/tss:author)">
                                        <xsl:text>N.N., ed.</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="vNames">
                                        <xsl:for-each
                                            select="$vRef/tss:authors/tss:author[@role='Author']">
                                            <xsl:element name="till:li">
                                                <xsl:choose>
                                                  <xsl:when test="position()=1">
                                                  <xsl:value-of select="./tss:surname"/>
                                                  <xsl:if test="./tss:forenames!=''">
                                                  <xsl:value-of
                                                  select="concat(', ',./tss:forenames)"/>
                                                  </xsl:if>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat(./tss:forenames,' ',./tss:surname)"
                                                  />
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:element>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:call-template name="funcStringOxfordComma">
                                        <xsl:with-param name="pLiInput" select="$vNames"/>
                                    </xsl:call-template>
                                    <xsl:if test="not($vRef/tss:authors/tss:author)">
                                        <xsl:text>N.N.</xsl:text>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vAuthorFirst">
                        <xsl:choose>
                            <xsl:when test="$vRef/tss:authors/tss:author[@role='Author']">
                                <xsl:value-of
                                    select="concat($vRef/tss:authors/tss:author[1]/tss:forenames,' ', $vRef/tss:authors/tss:author[1]/tss:surname)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>N.N.</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vEditors">
                        <xsl:if test="$pMode='fn' or $pMode='fn2'">
                            <xsl:text>ed. </xsl:text>
                        </xsl:if>
                        <!--<xsl:if test="$pMode='fn2'">
                            <xsl:text>ed. </xsl:text>
                        </xsl:if>-->
                        <xsl:if test="$pMode='bibl'">
                            <xsl:text>Edited by </xsl:text>
                        </xsl:if>
                        <xsl:variable name="vNames">
                            <xsl:for-each select="$vRef/tss:authors/tss:author[@role='Editor']">
                                <xsl:element name="till:li">
                                    <xsl:value-of select="concat(./tss:forenames,' ',./tss:surname)"
                                    />
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:call-template name="funcStringOxfordComma">
                            <xsl:with-param name="pLiInput" select="$vNames"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vPhotographers">
                        <xsl:text>Photographed by </xsl:text>
                        <xsl:variable name="vNames">
                            <xsl:for-each
                                select="$vRef/tss:authors/tss:author[@role='Photographer']">
                                <xsl:element name="till:li">
                                    <xsl:value-of select="concat(./tss:forenames,' ',./tss:surname)"
                                    />
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:call-template name="funcStringOxfordComma">
                            <xsl:with-param name="pLiInput" select="$vNames"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vTranslators">
                        <xsl:if test="$pMode='fn' or $pMode='fn2'">
                            <xsl:text>trans. </xsl:text>
                        </xsl:if>
                        <xsl:if test="$pMode='bibl'">
                            <xsl:text>Translated by </xsl:text>
                        </xsl:if>
                        <xsl:variable name="vNames">
                            <xsl:for-each select="$vRef/tss:authors/tss:author[@role='Translator']">
                                <xsl:element name="till:li">
                                    <xsl:value-of select="concat(./tss:forenames,' ',./tss:surname)"
                                    />
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:call-template name="funcStringOxfordComma">
                            <xsl:with-param name="pLiInput" select="$vNames"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vCitedPages">
                        <xsl:variable name="vCitPagesOrig">
                            <xsl:choose>
                                <xsl:when test="$pCitedPages!=''">
                                    <xsl:value-of select="$pCitedPages"/>
                                </xsl:when>
                                <xsl:when test="$vRef//@citPages!=''">
                                    <xsl:value-of select="$vRef//@citPages"/>
                                </xsl:when>
                                <xsl:when
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='pages']">
                                    <xsl:if test="$pMode='fn' or 'fn2'">
                                        <xsl:if
                                            test="$vRef/tss:publicationType/@name='Archival Periodical Article'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                        <xsl:if
                                            test="$vRef/tss:publicationType/@name='Archival Book Chapter'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                        <xsl:if
                                            test="$vRef/tss:publicationType/@name='Book Chapter'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                        <xsl:if test="$vRef/tss:publicationType/@name='Bill'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                        <xsl:if test="$vRef/tss:publicationType/@name='Maps'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="$pMode='bibl'">
                                        <xsl:if test="$vRef/tss:publicationType/@name!='Book'">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='pages']"
                                            />
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="vCitPagesFormatted">
                            <xsl:analyze-string select="$vCitPagesOrig" regex="(\d+)\-(\d+)">
                                <xsl:matching-substring>
                                    <xsl:choose>
                                        <xsl:when
                                            test="substring(regex-group(1),1,3)=substring(regex-group(2),1,3)">
                                            <xsl:value-of
                                                select="concat(regex-group(1),$vSeparatorNumericRange,substring(regex-group(2),3))"
                                            />
                                        </xsl:when>
                                        <xsl:when
                                            test="substring(regex-group(1),1,2)=substring(regex-group(2),1,2)">
                                            <xsl:value-of
                                                select="concat(regex-group(1),$vSeparatorNumericRange,substring(regex-group(2),2))"
                                            />
                                        </xsl:when>
                                        <xsl:when
                                            test="substring(regex-group(1),1,1)=substring(regex-group(2),1,1)">
                                            <xsl:value-of
                                                select="concat(regex-group(1),$vSeparatorNumericRange,substring(regex-group(2),2))"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat(regex-group(1),$vSeparatorNumericRange,regex-group(2))"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:if test="$vCitPagesFormatted!=''">
                            <xsl:choose>
                                <!-- electronic citations should be referenced by paragraph -->
                                <xsl:when
                                    test="$vRef/tss:publicationType/@name='Electronic citation'">
                                    <xsl:value-of select="concat($vSeparatorPages,'§', $vCitPagesFormatted)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($vSeparatorPages, $vCitPagesFormatted)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <!--<xsl:value-of
                            select="if($vCitPagesFormatted!='') then(concat($vSeparatorPages, $vCitPagesFormatted)) else()"
                        />-->
                    </xsl:variable>

                    <xsl:variable name="vPlacePubl">
                        <xsl:variable name="vPlacePubl1">
                        <xsl:value-of
                            select="if($vRef/tss:characteristics/tss:characteristic[@name='publicationCountry']) then($vRef/tss:characteristics/tss:characteristic[@name='publicationCountry']) else('N.Pl.')"/></xsl:variable>
                        <!-- new in v2a -->
                        <xsl:choose>  
                            <xsl:when test="$pCaps='y' and $vLang='en'">
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString" select="$vPlacePubl1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$pCaps='y' and $vLang='ar'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vPlacePubl1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <!--<xsl:when test="$pCaps='y'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vPlacePubl1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>-->
                            <xsl:otherwise>
                                <xsl:value-of select="$vPlacePubl1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitlePublication">
                        <xsl:variable name="vTitleClean1">
                            <xsl:call-template name="funcStringRemoveTrailing">
                                <xsl:with-param name="pString"
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='publicationTitle']"
                                />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vTitleClean2">
                            <xsl:choose>
                                <xsl:when
                                    test="$vLang='ar'">
                                    <xsl:call-template name="funcStringCleanTranscription">
                                        <xsl:with-param name="pString" select="$vTitleClean1"/>
                                        <xsl:with-param name="pLang" select="'ar-Latn-x-ijmes'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="funcStringCleanTranscription">
                                        <xsl:with-param name="pString" select="$vTitleClean1"/>
                                        <xsl:with-param name="pLang" select="'en'"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <!-- new in v2a -->
                            <xsl:when test="$pCaps='y' and $vLang='en'">
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString" select="$vTitleClean2"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$pCaps='y' and $vLang='ar'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vTitleClean2"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vTitleClean2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitleArticle">
                        <xsl:variable name="vTitleClean1">
                            <xsl:call-template name="funcStringRemoveTrailing">
                                <xsl:with-param name="pString"
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='articleTitle']"
                                />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vTitleClean2">
                            <xsl:choose>
                                <xsl:when
                                    test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='language']),'arabic')">
                                    <xsl:call-template name="funcStringCleanTranscription">
                                        <xsl:with-param name="pString" select="$vTitleClean1"/>
                                        <xsl:with-param name="pLang" select="'ar-Latn-x-ijmes'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="funcStringCleanTranscription">
                                        <xsl:with-param name="pString" select="$vTitleClean1"/>
                                        <xsl:with-param name="pLang" select="'en'"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <!-- new in v2a -->
                            <xsl:when test="$pCaps='y' and $vLang='en'">
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString" select="$vTitleClean2"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$pCaps='y' and $vLang='ar'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vTitleClean2"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vTitleClean2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitleOrig">
                        <xsl:choose>
                            <xsl:when test="$pCaps='y'">
                                <!-- as the original title is usually in another language than the publication title and as Sente XML cannot provide information on the language of the original title, I should not pass on $vLang -->
                                <!--<xsl:value-of select="upper-case(substring($vRef/tss:characteristics/tss:characteristic[@name='Orig.Title'],1,1))"/>-->
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString"
                                        select="substring($vRef/tss:characteristics/tss:characteristic[@name='Orig.Title'],1)"
                                    />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='Orig.Title']"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitleTranslated">
                        <xsl:choose>
                            <xsl:when test="$pCaps='y'">
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString"
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Translated title']"
                                    />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='Translated title']"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitleShortArchival">
                        <xsl:choose>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                <!-- any mark-up inside citations causes trouble in Word -->
                                <xsl:variable name="vStringCaps">
                                    <xsl:choose>
                                        <!-- new in v2a -->
                                        <xsl:when test="$pCaps='y' and $vLang='en'">
                                            <xsl:call-template name="funcStringCaps">
                                                <xsl:with-param name="pString" select="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']"/>
                                                <xsl:with-param name="pLang" select="$vLang"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="$pCaps='y' and $vLang='ar'">
                                            <xsl:call-template name="funcStringCapsFirst">
                                                <xsl:with-param name="pString" select="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']"/>
                                                <xsl:with-param name="pLang" select="$vLang"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:text> </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vStringCaps"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='articleTitle']">
                                <xsl:value-of
                                    select="concat('&quot;',$vRef/tss:characteristics/tss:characteristic[@name='articleTitle'],'&quot;')"/>
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vTitleShort">
                        <!-- the first choose establishes whether a short title must be automatically generated -->
                        <xsl:variable name="vTitleShort1">
                            <xsl:choose>
                                <xsl:when
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='Shortened title']!=''">
                                    <!-- any mark-up inside citations causes trouble in Word -->
                                    <!--<i>-->
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Shortened title']"/>

                                    <!--</i>-->
                                </xsl:when>
                                <xsl:when
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']!=''">
                                    <!-- any mark-up inside citations causes trouble in Word -->
                                    <!--<i>-->
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']"/>
                                    <!--</i>-->
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- in case an automatic short title is to be generated this choose selects publication or article titles -->
                                    <xsl:variable name="vTitleToBeShortened1">
                                        <xsl:choose>
                                            <xsl:when
                                                test="contains($vRef/tss:publicationType/@name,'Article') or contains($vRef/tss:publicationType/@name,'Chapter')">
                                                <xsl:value-of
                                                  select="if(contains($vTitleArticle,':')) then(substring-before($vTitleArticle,':')) else($vTitleArticle)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="if(contains($vTitlePublication,':')) then(substring-before($vTitlePublication,':')) else($vTitlePublication)"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="vTitleToBeShortened2">
                                        <xsl:choose>
                                            <xsl:when
                                                test="starts-with(lower-case($vTitleToBeShortened1),'a ')">
                                                <xsl:value-of
                                                  select="substring($vTitleToBeShortened1, 3)"/>
                                            </xsl:when>
                                            <xsl:when
                                                test="starts-with(lower-case($vTitleToBeShortened1),'an ')">
                                                <xsl:value-of
                                                  select="substring($vTitleToBeShortened1, 4)"/>
                                            </xsl:when>
                                            <xsl:when
                                                test="starts-with(lower-case($vTitleToBeShortened1),'the ')">
                                                <xsl:value-of
                                                  select="substring($vTitleToBeShortened1, 5)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$vTitleToBeShortened1"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <!-- the regex \W asumes "-" as word boundary, but in rare cases it should not be considered thus -->
                                        <xsl:when
                                            test="count(tokenize($vTitleToBeShortened2,'(\s)'))&lt;=5">
                                            <xsl:value-of select="$vTitleToBeShortened2"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each
                                                select="tokenize(if(contains($vTitleToBeShortened2,':')) then(substring-before($vTitleToBeShortened2,':')) else($vTitleToBeShortened2),'(\s)')">
                                                <xsl:if test="position()&lt;5">
                                                  <xsl:value-of select="concat(.,' ')"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text> [...]</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- new in v2a -->
                        <xsl:choose>  
                            <xsl:when test="$pCaps='y' and $vLang='en'">
                                <xsl:call-template name="funcStringCaps">
                                    <xsl:with-param name="pString" select="$vTitleShort1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$pCaps='y' and $vLang='ar'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vTitleShort1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$pCaps='y'">
                                <xsl:call-template name="funcStringCapsFirst">
                                    <xsl:with-param name="pString" select="$vTitleShort1"/>
                                    <xsl:with-param name="pLang" select="$vLang"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$vTitleShort1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!--<xsl:call-template name="funcStringCaps">
                            <xsl:with-param name="pString" select="$vTitleShort1"/>
                        </xsl:call-template>-->
                    </xsl:variable>
                    <xsl:variable name="vC15-Contributors-additional">
                        <xsl:if test="$pMode='fn' or $pMode='fn2'">
                            <xsl:if test="$vRef/tss:authors/tss:author[@role='Translator']">
                                <xsl:value-of select="$vTranslators"/>
                            </xsl:if>
                            <xsl:if
                                test="$vRef/tss:authors/tss:author[@role='Editor'] and $vRef/tss:publicationType[not(@name='Edited Book')]">
                                <xsl:if test="$vRef/tss:authors/tss:author[@role='Translator']">
                                    <xsl:value-of select="$vSeparatorInfo"/>
                                </xsl:if>
                                <xsl:value-of select="$vEditors"/>
                                <!--<xsl:text> </xsl:text>-->
                            </xsl:if>
                        </xsl:if>
                        <!--<xsl:if test="$pMode='fn2'">
                            <xsl:if test="$vRef/tss:authors/tss:author[@role='Translator']">
                                <xsl:value-of select="concat($vTranslators,', ')"/>
                            </xsl:if>
                            <xsl:if test="$vRef/tss:authors/tss:author[@role='Editor'] and $vRef/tss:publicationType[not(@name='Edited Book')]">
                                <xsl:value-of select="$vEditors"/>
                                <xsl:choose>
                                    <xsl:when test="$vRef/tss:publicationType[@name='Book Chapter']">
                                        <xsl:text> </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:if>-->
                        <xsl:if test="$pMode='bibl'">
                            <xsl:if test="$vRef/tss:authors/tss:author[@role='Translator']">
                                <xsl:value-of select="$vTranslators"/>
                                <xsl:value-of select="$vSeparatorInfo"/>
                            </xsl:if>
                            <xsl:if test="$vRef/tss:authors/tss:author[@role='Editor']">
                                <xsl:value-of select="$vEditors"/>
                                <xsl:value-of select="$vSeparatorInfo"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vC15-Title-Orig-Trans">
                        <xsl:choose>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Orig.Title']">
                                <xsl:value-of select="concat(' [',$vTitleOrig,']')"/>
                            </xsl:when>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Translated title']">
                                <xsl:value-of select="concat(' [',$vTitleTranslated,']')"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vC15-Place-Publisher-Date">
                        <!-- according to C15 NB it should be put inside braces for notes -->
                        <xsl:value-of select="$vPlacePubl"/>
                        <xsl:if
                            test="$vRef/tss:characteristics/tss:characteristic[@name='publisher']!=''">
                            <xsl:variable name="vPublisher" select="$vRef/tss:characteristics/tss:characteristic[@name='publisher']"/>
                            <xsl:text>: </xsl:text>
                            <!--<xsl:value-of
                                select="$vRef/tss:characteristics/tss:characteristic[@name='publisher']"
                            />-->
                            <!-- new in v2a -->
                            <xsl:choose>  
                                <xsl:when test="$pCaps='y' and $vLang='en'">
                                    <xsl:call-template name="funcStringCaps">
                                        <xsl:with-param name="pString" select="$vPublisher"/>
                                        <xsl:with-param name="pLang" select="$vLang"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$pCaps='y' and $vLang='ar'">
                                    <xsl:call-template name="funcStringCapsFirst">
                                        <xsl:with-param name="pString" select="$vPublisher"/>
                                        <xsl:with-param name="pLang" select="$vLang"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <!--<xsl:when test="$pCaps='y'">
                                    <xsl:call-template name="funcStringCapsFirst">
                                        <xsl:with-param name="pString" select="$vPublisher"/>
                                        <xsl:with-param name="pLang" select="$vLang"/>
                                    </xsl:call-template>
                                </xsl:when>-->
                                <xsl:otherwise>
                                    <xsl:value-of select="$vPublisher"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!--<xsl:call-template name="funcStringCaps">
                                <xsl:with-param name="pString"
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='publisher']"
                                />
                            </xsl:call-template>-->
                        </xsl:if>
                        <xsl:text>, </xsl:text>
                        <xsl:choose>
                            <!-- Bills must carry the original publication date -->
                            <xsl:when test="$vRef/tss:publicationType/@name='Bill'">
                                <xsl:value-of select="$vDatePubl"/>
                            </xsl:when>
                            <xsl:when test="$vDatePubl!=''">
                                <!-- approximate dates -->
                                <xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:keywords/tss:keyword='approximate date'">
                                        <xsl:text>c.</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Medium']='Postcard'">
                                        <xsl:text>c.</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$vRef/tss:keywords/tss:keyword='Postcard'">
                                        <xsl:text>c.</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                <!--<xsl:value-of select="$vDatePubl"/>-->
                                <xsl:value-of select="$vArchDate"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>(N.D.)</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!--<xsl:value-of select="if($vDatePubl!='') then($vDatePubl) else('(N.D.)')"/>-->
                    </xsl:variable>
                    <xsl:variable name="vC15-Thesis-Publication-details">
                        <xsl:choose>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Othertype']='PhD Thesis'">
                                <xsl:text>PhD diss., </xsl:text>
                            </xsl:when>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Othertype']">
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='Othertype']"/>
                                <xsl:text>, </xsl:text>
                            </xsl:when>
                            <xsl:when test="$vRef/tss:publicationType[@name='Manuscript']">
                                <xsl:text>unpubl. MS, </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of
                            select="if($vRef/tss:characteristics/tss:characteristic[@name='affiliation']) then(concat($vRef/tss:characteristics/tss:characteristic[@name='affiliation'],', ')) else()"/>
                        <xsl:value-of select="$vDatePubl"/>
                    </xsl:variable>
                    <xsl:variable name="vVolumeClean">
                        <xsl:variable name="vVolTrans">
                            <xsl:call-template name="funcStringCleanTranscription">
                                <xsl:with-param name="pString"
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"
                                />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="funcStringCaps">
                            <xsl:with-param name="pString" select="$vVolTrans"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="vC15-Volume">
                        <xsl:if test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                            <xsl:text>Vol. </xsl:text>
                            <!-- here should the total number of volumes be listed -->
                            <xsl:choose>
                                <xsl:when test="$pMode='fn'">
                                    <xsl:value-of select="$vVolumeClean"/>
                                    <!--<xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"/>-->
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                                <!-- account for the possibility, that volume information might contain longer titles after -->
                                <xsl:when test="$pMode='fn2'">
                                    <xsl:choose>
                                        <xsl:when
                                            test="contains($vRef/tss:characteristics/tss:characteristic[@name='volume'],':')">
                                            <xsl:value-of
                                                select="substring-before($vRef/tss:characteristics/tss:characteristic[@name='volume'],':')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$vVolumeClean"/>
                                            <!--<xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"/>-->
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                                <xsl:when test="$pMode = 'bibl'">
                                    <xsl:value-of select="$vVolumeClean"/>
                                    <!--<xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"/>-->
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vC15-Series-Volume">
                        <xsl:if test="$vRef/tss:characteristics/tss:characteristic[@name='Series']">
                            <xsl:value-of
                                select="$vRef/tss:characteristics/tss:characteristic[@name='Series']"/>
                            <xsl:text> Vol. </xsl:text>
                            <!-- here should the total number of volumes be listed -->
                            <xsl:choose>
                                <xsl:when test="$pMode='fn'">
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Series volume']"/>
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                                <!-- account for the possibility, that volume information might contain longer titles after -->
                                <xsl:when test="$pMode='fn2'">
                                    <xsl:choose>
                                        <xsl:when
                                            test="contains($vRef/tss:characteristics/tss:characteristic[@name='Series volume'],':')">
                                            <xsl:value-of
                                                select="substring-before($vRef/tss:characteristics/tss:characteristic[@name='Series volume'],':')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='Series volume']"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text>, </xsl:text>
                                </xsl:when>
                                <xsl:when test="$pMode = 'bibl'">
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Series volume']"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vC15-Vol-Issue-Date">
                        <xsl:if test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                            <xsl:value-of
                                select="concat('',$vRef/tss:characteristics/tss:characteristic[@name='volume'])"
                            />
                        </xsl:if>
                        <xsl:if test="$vRef/tss:characteristics/tss:characteristic[@name='issue']">
                            <xsl:value-of
                                select="concat(', no. ',$vRef/tss:characteristics/tss:characteristic[@name='issue'])"
                            />
                        </xsl:if>
                        <xsl:value-of
                            select="concat(' (',$vRef/tss:dates/tss:date[@type='Publication']/@year,')')"
                        />
                    </xsl:variable>
                    <xsl:variable name="vC15-FnCitSubsequent">
                        <!-- according to Chicago Manual of Style this must be:
                            books etc.: Author's surname, "Short Title," page number -> books can have volumes, which need be acknowledged
                            articles etc.: Author's surname, *Short Title*, page number-->
                        <xsl:variable name="vTitleShortItalics">
                            <xsl:call-template name="funcStringTextDecoration">
                                <xsl:with-param name="pInputString" select="$vTitleShort"/>
                                <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                <xsl:with-param name="pDecoration" select="'italics'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="$pBibStyle='C15TillArchBib'">
                            <xsl:value-of select="concat($vAuthors,' ')"/>
                            <!-- special case for electronic citations, which in my case all stem from the EI2 -->
                            <xsl:if test="$vRef/tss:publicationType/@name='Electronic citation'">
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitleArticle"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:text> in </xsl:text>
                            </xsl:if>
                            <xsl:copy-of select="$vTitleShortItalics"/>
                            <xsl:if
                                test="$vRef/tss:publicationType/@name='Book' and $vC15-Volume!=''">
                                <xsl:value-of select="concat(', ',$vC15-Volume)"/>
                            </xsl:if>
                            <xsl:value-of
                                select="concat(' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                            <xsl:value-of select="$vCitedPages"/>
                        </xsl:if>
                        <xsl:if test="$pBibStyle='C15NB'">
                            <xsl:value-of select="$vAuthors"/>
                            <xsl:value-of
                                select="if(contains($vRef/tss:publicationType/@name,'Article') or contains($vRef/tss:publicationType/@name,'Chapter')) then(concat(', &quot;',$vTitleShort,',&quot; ')) else(concat(', ',$vTitleShortItalics,', '))"/>
                            <xsl:value-of select="$vCitedPages"/>
                        </xsl:if>

                    </xsl:variable>
                    <xsl:variable name="vC15-Url-Accessed">
                        <xsl:if test="$vRef/tss:characteristics/tss:characteristic[@name='URL']">
                            <!-- some URLs can be shortened without loosing their target -->
                            <xsl:choose>
                                <!-- delcampe postcards -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'www.delcampe.')">
                                    <xsl:text>http://www.delcampe.net/page/item/id,</xsl:text>
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='call-num']"/>
                                    <xsl:text>.html</xsl:text>
                                </xsl:when>
                                <!-- smithsonian institution -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'siris-archives.si.edu')">
                                    <xsl:text>http://siris-archives.si.edu/ipac20/ipac.jsp?uri=full=</xsl:text>
                                    <xsl:value-of
                                        select="substring-before(substring-after($vRef/tss:characteristics/tss:characteristic[@name='URL'],'uri=full='),'&amp;ri=1&amp;aspect=')"
                                    />
                                </xsl:when>
                                <!-- ashmolean creswell -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'http://creswell.ashmolean.museum/php/am-makepage1.php?')">
                                    <!--<xsl:text>http://creswell.ashmolean.museum/php/am-makepage1.php?</xsl:text>
                                    <xsl:for-each select="tokenize($vRef/tss:characteristics/tss:characteristic[@name='URL'],'&amp;')">
                                        <xsl:if test="starts-with(.,'db=')">
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test="starts-with(.,'city=')">
                                            <xsl:text>&amp;</xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test="starts-with(.,'what=')">
                                            <xsl:text>&amp;</xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test="starts-with(.,'cpos=')">
                                            <xsl:text>&amp;</xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <!-\-<xsl:if test="starts-with(.,'s1=')">
                                            <xsl:value-of select="."/>
                                        </xsl:if>-\->
                                    </xsl:for-each>-->
                                    <xsl:text>http://creswell.ashmolean.museum/archive/</xsl:text>
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='Signatur']"/>
                                    <xsl:text>.html</xsl:text>
                                </xsl:when>
                                <!-- facebook -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'www.facebook.')">
                                    <xsl:analyze-string select="." regex="fbid=(\d+)">
                                        <xsl:matching-substring>
                                            <xsl:text>https://www.facebook.com/photo.php?fbid=</xsl:text>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <!-- ebay -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'www.ebay.')">
                                    <xsl:analyze-string
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='URL']"
                                        regex="(.+)/(\d+)\?">
                                        <xsl:matching-substring>
                                            <xsl:value-of
                                                select="concat(regex-group(1),'/',regex-group(2))"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <!-- flickr -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'www.flickr.')">
                                    <!-- http://www.flickr.com/photos/77912654@N05/6994944618/lightbox/ -->
                                    <xsl:analyze-string
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='URL']"
                                        regex="(http://www.flickr.com/photos/)(.+/)(\d+)/">
                                        <xsl:matching-substring>
                                            <xsl:value-of
                                                select="concat(regex-group(1),regex-group(2),regex-group(3))"
                                            />
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <!-- ProQuest -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'proquest.umi.com')">
                                    <!-- http://referenceworks.brillonline.com/entries/encyclopaedia-of-islam-2/djumhuriyya-SIM_2112?s.num=0&amp;s.f.s2_parent=s.f.book.encyclopaedia-of-islam-2&amp;s.q=djumhuriyya -->
                                    <xsl:value-of
                                        select="if(contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'&amp;sid')) then(substring-before($vRef/tss:characteristics/tss:characteristic[@name='URL'],'&amp;sid')) else($vRef/tss:characteristics/tss:characteristic[@name='URL'])"
                                    />
                                </xsl:when>
                                <!-- Brill Online -->
                                <xsl:when
                                    test="contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'referenceworks.brillonline.com')">
                                    <!-- http://referenceworks.brillonline.com/entries/encyclopaedia-of-islam-2/djumhuriyya-SIM_2112?s.num=0&amp;s.f.s2_parent=s.f.book.encyclopaedia-of-islam-2&amp;s.q=djumhuriyya -->
                                    <xsl:value-of
                                        select="if(contains($vRef/tss:characteristics/tss:characteristic[@name='URL'],'?')) then(substring-before($vRef/tss:characteristics/tss:characteristic[@name='URL'],'?')) else($vRef/tss:characteristics/tss:characteristic[@name='URL'])"/>
                                    <!-- <xsl:analyze-string select="$vRef/tss:characteristics/tss:characteristic[@name='URL']" regex="(.+)\?">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>-->
                                </xsl:when>

                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="$vRef/tss:characteristics/tss:characteristic[@name='URL']"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="$vDateRetrieval!=''">
                                <xsl:text> (accessed </xsl:text>
                                <xsl:value-of select="$vDateRetrieval"/>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="vEdition">
                        <xsl:choose>
                            <xsl:when
                                test="$vRef/tss:characteristics/tss:characteristic[@name='Edition']!=''">
                                <!--<xsl:analyze-string select="$vRef/tss:characteristics/tss:characteristic[@name='Edition']" regex="(\d+)">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="functx:ordinal-number-en(regex-group(1))" />
                                    </xsl:matching-substring>
                                </xsl:analyze-string>-->
                                <xsl:choose>
                                    <xsl:when
                                        test="matches($vRef/tss:characteristics/tss:characteristic[@name='Edition'],'\d+$')">
                                        <xsl:value-of
                                            select="functx:ordinal-number-en(number($vRef/tss:characteristics/tss:characteristic[@name='Edition']))"/>
                                        <xsl:text> ed</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="$pMode='fn' or $pMode='fn2'">
                                                <xsl:text>., </xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$pMode = 'bibl'">
                                                <xsl:text>. </xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="$vRef/tss:characteristics/tss:characteristic[@name='Edition']"/>
                                        <xsl:choose>
                                            <xsl:when test="$pMode='fn' or $pMode='fn2'">
                                                <xsl:text>, </xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$pMode = 'bibl'">
                                                <xsl:text>. </xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- building the actual citations -->
                    <xsl:variable name="vCitationFinal">
                        <xsl:choose>
                        <!-- Periodicals -->
                        <!-- NOTE: many sources have been improperly filed into the categories "Newspaper article", "Archival Periodical" or "Archival Periodical Article". Many references in the "Newspaper article" category actually pertain to whole issues. In addition there should be a notable difference between newspapers and other periodicals -->
                        <!-- v1d: in order to shorten footnotes, one could look up whether the preceeding reference was to the same publication -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Newspaper article']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:choose>
                                    <!-- if the short title of the periodical is the same as the one before, it will be omitted -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] = preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <!--<xsl:text> **same** </xsl:text>-->
                                    </xsl:when>
                                    <!-- if the reference has a short title it will be used -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <xsl:value-of select="$vTitleShort"/>
                                    </xsl:when>
                                    <!-- otherwise, the full title will be returned -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vTitlePublication"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <!-- C15: Place of publication in brackets: (Beirut) -->
                                <xsl:value-of select="$vDatePubl"/>
                                <!-- for most newspapers I had to switch volume and issue numbers due to Sente's filing restrictions. But not in the case of the Levant Herald -->
                                <xsl:choose>
                                    <xsl:when test="$vTitleShort='Levant Herald'">
                                        <xsl:text> (vol.</xsl:text>
                                        <xsl:value-of
                                            select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"/>
                                        <xsl:text>, #</xsl:text>
                                        <xsl:value-of
                                            select="$vRef/tss:characteristics/tss:characteristic[@name='issue']"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                            <xsl:value-of
                                                select="concat(' (#',$vRef/tss:characteristics/tss:characteristic[@name='volume'],')')"
                                            />
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--<xsl:value-of select="$vDatePublWeekday"/>-->
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Periodical']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <!-- check if the "Archival Periodical" references a newspaper. this can either be done by reference to a specific title or through keywords -->
                                <xsl:choose>
                                    <xsl:when test="$vRef/tss:keywords/tss:keyword='daily' or $vRef/tss:keywords/tss:keyword='biweekly' or $vRef/tss:keywords/tss:keyword='weekly'">
                                        <!-- debugging -->
                                        <xsl:message>
                                            <xsl:text>newspaper issues classified as "Archival Periodical"</xsl:text>
                                        </xsl:message>
                                        <!-- the reference is a newspaper. use the newspaper content. -->
                                        <xsl:choose>
                                    <!-- if the short title of the periodical is the same as the one before, it will be omitted -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] = preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <!--<xsl:text> **same** </xsl:text>-->
                                    </xsl:when>
                                    <!-- if the reference has a short title it will be used -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <xsl:value-of select="$vTitleShort"/>
                                    </xsl:when>
                                    <!-- otherwise, the full title will be returned -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vTitlePublication"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <!-- C15: Place of publication in brackets: (Beirut) -->
                                <xsl:value-of select="$vDatePubl"/>
                                
                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                            <xsl:value-of
                                                select="concat(' (#',$vRef/tss:characteristics/tss:characteristic[@name='volume'],')')"
                                            />
                                        </xsl:if>
                                
                                <!--<xsl:value-of select="$vDatePublWeekday"/>-->
                                <xsl:value-of select="$vCitedPages"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                <xsl:choose>
                                    <!-- if the short title of the periodical is the same as the one before, it will be omitted -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] = preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <!--<xsl:text> **same** </xsl:text>-->
                                    </xsl:when>
                                    <!-- if the reference has a short title it will be used -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <xsl:value-of select="$vTitleShort"/>
                                    </xsl:when>
                                    <!-- otherwise, the full title will be returned -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vTitlePublication"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!--<xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <xsl:value-of
                                            select="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vTitlePublication"/>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:text> </xsl:text>
                                <xsl:if
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                    <xsl:if
                                        test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='Short Titel']),'salname')">
                                        <xsl:text>#</xsl:text>
                                    </xsl:if>
                                    <xsl:value-of
                                        select="concat('',$vRef/tss:characteristics/tss:characteristic[@name='volume'])"/>
                                    <xsl:if
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='issue']">
                                        <xsl:value-of
                                            select="concat('(',$vRef/tss:characteristics/tss:characteristic[@name='issue'],')')"
                                        />
                                    </xsl:if>
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <!-- dates -->
                                <!-- this allows for some idiosyncrasy in case of Ottoman yearbooks -->
                                <xsl:choose>
                                    <xsl:when
                                        test="contains(lower-case($vRef/tss:characteristics/tss:characteristic[@name='Short Titel']),'salname')">
                                        <!-- establish the primary calendar -->
                                        <xsl:choose>
                                            <!-- this matches all salnames that have a range in the Hijri field and were thus published for Mali years -->
                                            <xsl:when
                                                test="matches($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'\d{4}-\d')">
                                                <xsl:value-of
                                                  select="concat($vDateRorM,' / ',$vDateH)"/>
                                                <!-- add computed Gregorian dates -->
                                                <xsl:text> [</xsl:text>
                                                <xsl:variable name="vYearR2G"
                                                  select="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi'] + 584"/>
                                                <xsl:value-of select="$vYearR2G"/>
                                                <xsl:text>-</xsl:text>
                                                <xsl:value-of
                                                  select="substring(string($vYearR2G +1),3,2)"/>
                                                <xsl:text>]</xsl:text>
                                            </xsl:when>
                                            <!-- this matches all salnames that have a range in the Rumi field and were thus published for Hijri years -->
                                            <xsl:when
                                                test="matches($vRef/tss:characteristics/tss:characteristic[@name='Date Rumi'],'\d{4}-\d')">
                                                <xsl:value-of
                                                  select="concat($vDateH,' / ',$vDateRorM)"/>
                                                <!-- add computed Gregorian dates -->
                                                <xsl:variable name="vDateH1"
                                                  select="concat($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'-01-01')"/>
                                                <xsl:variable name="vDateG1">
                                                  <xsl:call-template name="funcDateH2G">
                                                  <xsl:with-param name="pDateH" select="$vDateH1"/>
                                                  </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:variable name="vDateH2"
                                                  select="concat($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'-12-29')"/>
                                                <xsl:variable name="vDateG2">
                                                  <xsl:call-template name="funcDateH2G">
                                                  <xsl:with-param name="pDateH" select="$vDateH2"/>
                                                  </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:text> [</xsl:text>
                                                <xsl:value-of select="substring($vDateG1,1,4)"/>
                                                <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
                                                <xsl:if
                                                  test="substring($vDateG1,1,4)!=substring($vDateG2,1,4)">
                                                  <xsl:text>-</xsl:text>
                                                  <xsl:choose>
                                                  <!-- the range 1899-1900 must be accounted for -->
                                                  <xsl:when test="substring($vDateG2,3,2)='00'">
                                                  <xsl:value-of select="substring($vDateG2,1,4)"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring($vDateG2,3,2)"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  <xsl:text>]</xsl:text>
                                                </xsl:if>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$vDateH"/>
                                                <xsl:if
                                                  test="$vRef/tss:characteristics/tss:characteristic[@name='Date Rumi']">
                                                  <xsl:text> / </xsl:text>
                                                  <xsl:value-of select="$vDateRorM"/>
                                                </xsl:if>

                                                <!-- add computed Gregorian dates -->
                                                <xsl:variable name="vDateH1"
                                                  select="concat($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'-01-01')"/>
                                                <xsl:variable name="vDateG1">
                                                  <xsl:call-template name="funcDateH2G">
                                                  <xsl:with-param name="pDateH" select="$vDateH1"/>
                                                  </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:variable name="vDateH2"
                                                  select="concat($vRef/tss:characteristics/tss:characteristic[@name='Date Hijri'],'-12-29')"/>
                                                <xsl:variable name="vDateG2">
                                                  <xsl:call-template name="funcDateH2G">
                                                  <xsl:with-param name="pDateH" select="$vDateH2"/>
                                                  </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:text> [</xsl:text>
                                                <xsl:value-of select="substring($vDateG1,1,4)"/>
                                                <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329)  -->
                                                <xsl:if
                                                  test="substring($vDateG1,1,4)!=substring($vDateG2,1,4)">
                                                  <xsl:text>-</xsl:text>
                                                  <xsl:choose>
                                                  <!-- the range 1899-1900 must be accounted for -->
                                                  <xsl:when test="substring($vDateG2,3,2)='00'">
                                                  <xsl:value-of select="substring($vDateG2,1,4)"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="substring($vDateG2,3,2)"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:if>
                                                <xsl:text>]</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vDatePubl"/>
                                        <xsl:value-of select="$vDateHR"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                                <xsl:value-of select="$vCitedPages"/>
                                <!-- repositort -->
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Repository']!='') then(concat(' (', $vRef/tss:characteristics/tss:characteristic[@name='Repository'],' copy)')) else()"
                                />
                            </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Periodical Article']">
                            <!-- some articles have no title. Account for that -->
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:value-of select="concat($vAuthorFirst,', ')"/>
                                <xsl:if test="$vTitleArticle!=''">
                                    <xsl:value-of select="concat('&quot;',$vTitleArticle,',&quot;')"
                                    />
                                </xsl:if>
                                <xsl:text> in </xsl:text>
                                <xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <!--<xsl:value-of select="concat('',$vTitleShortArchival,'')"
                                        />-->
                                        <!-- v1b: $vTitleShortArchival can contain html markup! -->
                                        <xsl:copy-of select="$vTitleShortArchival"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Shortened title']">
                                        <xsl:value-of
                                            select="$vRef/tss:characteristics/tss:characteristic[@name='Shortened title']"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$vTitlePublication"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!-- volume and issue -->
                                <xsl:if
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                    <xsl:value-of
                                        select="concat(' ',$vRef/tss:characteristics/tss:characteristic[@name='volume'])"
                                    />
                                </xsl:if>
                                <xsl:if
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='issue']">
                                    <xsl:value-of
                                        select="concat('(',$vRef/tss:characteristics/tss:characteristic[@name='issue'],')')"
                                    />
                                </xsl:if>
                                <xsl:if
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='volume'] or $vRef/tss:characteristics/tss:characteristic[@name='issue']">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                                <xsl:text> </xsl:text>
                                <!-- dates -->
                                <xsl:value-of select="$vDatePubl"/>
                                <xsl:value-of select="$vDateHR"/>
                                <!-- pages -->
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                        </xsl:when>

                        <!-- Archival Material -->
                        <!-- The Archival Book Chapter is limited to the HCPP -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Book Chapter']">
                            <xsl:value-of select="concat($vArchClassMarkShort,', ')"/>
                            <xsl:value-of
                                select="concat($vRef/tss:authors/tss:author[1]/tss:surname,' ')"/>
                            <xsl:call-template name="funcStringTextDecoration">
                                <xsl:with-param name="pInputString" select="$vTitleShort"/>
                                <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                <xsl:with-param name="pDecoration" select="'italics'"/>
                            </xsl:call-template>
                            <xsl:value-of
                                select="concat(' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                            <xsl:value-of select="$vCitedPages"/>
                            <!-- <xsl:value-of select="$vAuthors"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                    <!-\-<xsl:value-of select="concat('',$vTitleShortArchival,'')"/>-\->
                                    <!-\- v1b: $vTitleShortArchival can contain html markup! -\->
                                    <xsl:copy-of select="$vTitleShortArchival"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$vTitlePublication"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-\-<xsl:text> </xsl:text>-\->
                            <xsl:value-of
                                select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>-->
                            <!--<xsl:value-of select="$vDateHR"/>-->
                            <!--<xsl:value-of select="$vCitedPages"/>-->
                            <!--<xsl:copy-of select="$vC15-FnCitSubsequent"/>-->
                            <xsl:if test="$pMode='bibl'">
                                <!-- this produces the line-break in bibliographies -->
                                <xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival File']">
                            <xsl:value-of select="concat($vArchClassMarkLong,', ')"/>
                            <!-- the following is a potential problem -->
                            <xsl:value-of select="$vTitleShortArchival"/>
                            <xsl:value-of select="$vDatePubl"/>
                            <xsl:if test="$pMode='bibl'">
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Journal Entry']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:choose>
                                    <!-- if the short title of the periodical is the same as the one before, it will be omitted -->
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] = preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel']">
                                        <!--<xsl:text> **same** </xsl:text>-->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="if($vArchClassMarkShort!='') then(concat($vArchClassMarkShort,', ')) else()"/>
                                        <xsl:value-of
                                            select="concat($vRef/tss:authors/tss:author[1]/tss:surname,'')"/>
                                        <!--<xsl:value-of select="concat(' ',$vTitleShortArchival,'')"/>-->
                                        <!-- v1b: $vTitleShortArchival can contain html markup! -->
                                        <xsl:copy-of select="$vTitleShortArchival"/>
                                        <xsl:value-of
                                            select="concat(' ',$vRef/tss:characteristics/tss:characteristic[@name='publicationCountry'],', ')"/>
                                        <!-- if the current reference is the first and the following references belong to the same journal, "entry" should be "entries" -->
                                        <xsl:choose>
                                            <!-- this condition does not work, when their is no preceding sibling  -->
                                            <xsl:when
                                                test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] = following-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel'] and ($vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] != preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='Short Titel'] or $vRef[1])">
                                                <xsl:text>entries of </xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>entry of </xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$vDatePubl"/>
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Letter']">
                            <!-- very late in the process of writing my thesis, I decided to render Nāṣīf Mishāqa as he himself did: Nasif Meshaka -->
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:value-of select="concat($vArchClassMarkLong,', ')"/>
                                <xsl:choose>
                                    <xsl:when test="$vAuthorFirst = 'Nāṣīf Mishāqa'">
                                        <xsl:text>Meshaka</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="if($vRef/tss:authors/tss:author[1]/tss:surname) then($vRef/tss:authors/tss:author[1]/tss:surname) else('N.N.')"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Recipient']) then(' to ') else(', ')"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Recipient']='Mishāqa'">
                                        <xsl:text>Meshaka, </xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Recipient']!=''">
                                        <xsl:value-of
                                            select="concat($vRef/tss:characteristics/tss:characteristic[@name='Recipient'],', ')"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                                <!--<xsl:value-of
                                    select="if($vTitleShortArchival!='') then(concat(' ',$vTitleShortArchival,', ')) else()"/>-->
                                <!-- v1b: $vTitleShortArchival can contain html markup! -->
                                <xsl:if test="$vTitleShortArchival!=''">
                                    <xsl:copy-of select="$vTitleShortArchival"/>
                                </xsl:if>
                                <xsl:value-of select="$vDatePubl"/>
                            </xsl:if>
                        </xsl:when>

                        <xsl:when test="$vRef/tss:publicationType[@name='Archival Material']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:value-of select="concat($vArchClassMarkLong,', ')"/>
                                <xsl:value-of select="$vDatePubl"/>
                            </xsl:if>
                        </xsl:when>

                        <!-- Photographs are not yet done -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Photograph']">
                            <xsl:if test="$pMode='fn'  or 'fn2'">
                                <!-- according to Chicago it should be
                                - Author: forename surname, 
- Title / Caption in italics,
- Date.
- Medium,
- Measures,
- Housing institution.
- "Reproduced from Delcampe, url (accessed etc. )"
                                -->
                                <xsl:value-of
                                    select="if($vRef/tss:authors/tss:author[@role='Photographer']) then(concat($vRef/tss:authors/tss:author[@role='Photographer'][1]/tss:forenames,' ',$vRef/tss:authors/tss:author[@role='Photographer'][1]/tss:surname,', ')) else('Unknown photographer, ')"/>
                                <!-- caption or publication title -->
                                <xsl:choose>
                                	<xsl:when test="$vRef/tss:characteristics/tss:characteristic[@name='Caption']!=''">
                                		<xsl:call-template name="funcStringTextDecoration">
                                            <xsl:with-param name="pInputString"
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='Caption']!=''"/>
                                            <xsl:with-param name="pOutputFormat"
                                                select="$pOutputFormat"/>
                                            <xsl:with-param name="pDecoration" select="'italics'"/>
                                        </xsl:call-template>
                                        <xsl:text>, </xsl:text>
                                	</xsl:when>
                                    <xsl:when test="$vTitlePublication!=''">
                                        <xsl:call-template name="funcStringTextDecoration">
                                            <xsl:with-param name="pInputString"
                                                select="$vTitlePublication"/>
                                            <xsl:with-param name="pOutputFormat"
                                                select="$pOutputFormat"/>
                                            <xsl:with-param name="pDecoration" select="'italics'"/>
                                        </xsl:call-template>
                                        <xsl:text>, </xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:value-of select="$vC15-Place-Publisher-Date"/>
                                <xsl:text>, </xsl:text>
                                <!--<xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Medium']) then(concat($vRef/tss:characteristics/tss:characteristic[@name='Medium'],', ')) else('Photograph, ')"/>-->
                                <xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:characteristics/tss:characteristic[@name='Medium']!=''">
                                        <xsl:call-template name="funcStringCaps">
                                            <xsl:with-param name="pString"
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='Medium']"
                                            />
                                        </xsl:call-template>
                                        <xsl:text>, </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>photograph, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of
                                    select="if($vArchClassMarkShort!='') then(concat($vArchClassMarkShort,', ')) else()"/>
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Collection description']) then($vRef/tss:characteristics/tss:characteristic[@name='Collection description']) else('unknown collection')"/>
                                <!-- / series -->
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Item']) then(concat(' #',$vRef/tss:characteristics/tss:characteristic[@name='Item'],'')) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat(', ',$vC15-Url-Accessed)) else()"/>

                                <!-- <xsl:value-of
                                    select="if($vArchClassMarkShort!='') then(concat($vArchClassMarkShort,', ')) else()"/>
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Medium']) then(concat($vRef/tss:characteristics/tss:characteristic[@name='Medium'],': ')) else()"/>
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='Collection description']"/>
                                <xsl:value-of
                                    select="if($vRef/tss:characteristics/tss:characteristic[@name='Item']) then(concat(' (#',$vRef/tss:characteristics/tss:characteristic[@name='Item'],')')) else()"/>
                                <xsl:text>. </xsl:text>
                                <xsl:choose>
                                    <xsl:when
                                        test="$vRef/tss:authors/tss:author[@role='Photographer']">
                                        <xsl:value-of select="$vPhotographers"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Unknown photographer</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of
                                    select="if($vTitlePublication) then(concat('*',$vTitlePublication,'*. ')) else()"/>
                                <xsl:value-of select="$vC15-Contributors-additional"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$vC15-Place-Publisher-Date"/>-->
                            </xsl:if>
                        </xsl:when>

                        <!-- Legal texts -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Bill']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <xsl:value-of select="concat('&quot;',$vTitleArticle)"/>
                                <!--<xsl:value-of select="$vC15-Title-Orig-Trans"/>-->
                                <xsl:text>,"</xsl:text>
                                <!-- in long chains of references to parts of the same law and/or publications in different translations, publications etc., the repetitive promulgation date could be omitted -->
                                <!--<xsl:value-of
                                    select="if($vArchDate!='') then(concat(' promulgated on ',$vArchDate,', ')) else(' ')"/>-->
                                <xsl:if test="$vArchDate!=''">
                                    <xsl:choose>
                                        <!-- tests if the preceding reference is also a law -->
                                        <xsl:when
                                            test="preceding-sibling::tss:reference[1]/tss:publicationType[@name='Bill']">
                                            <xsl:choose>
                                                <!-- tests if the preceding ref is a law, whose title commences with the same 10 letters -->
                                                <xsl:when
                                                  test="lower-case(substring($vRef/tss:characteristics/tss:characteristic[@name='articleTitle'],1,10)) = lower-case(substring(preceding-sibling::tss:reference[1]/tss:characteristics/tss:characteristic[@name='articleTitle'],1,10))">
                                                  <xsl:text> </xsl:text>
                                                </xsl:when>


                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat(' promulgated on ',$vArchDate,', ')"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat(' promulgated on ',$vArchDate,', ')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>

                                </xsl:if>
                                <!--<xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat($vC15-Contributors-additional, ', ')) else()"/>-->
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat($vC15-Contributors-additional, ', ')) else()"/>

                                <!-- in case the publication is a serial, further information is needed -->
                                <xsl:choose>
                                    <!-- as I know the newspapers I am using, I can implement custom code -->
                                    <!-- check for newspapers -->
                                    <xsl:when
                                        test="$vTitleShort='Thamarāt' or $vTitleShort='Bashīr' or $vTitleShort='Ḥadīqat' or $vTitleShort='Lisān' or $vTitleShort='Suriye' or $vTitleShort='Sūriye' or  lower-case($vTitleShort)='jarīdat al-muqtabas' or $vTitleShort = 'Iqbāl' or $vTitleShort = 'Ittiḥād'">
                                        <xsl:value-of select="concat('in ',$vTitleShort)"/>
                                        <xsl:text> </xsl:text>
                                        <!-- C15: Place of publication in brackets: (Beirut) -->
                                        <xsl:value-of select="$vDatePubl"/>
                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                            <xsl:value-of
                                                select="concat(' (#',$vRef/tss:characteristics/tss:characteristic[@name='volume'],')')"
                                            />
                                        </xsl:if>
                                    </xsl:when>
                                    <!-- check for other periodicals such as monthly journals: might need to add Maḥabba, Ḥasnāʾ-->
                                    <xsl:when
                                        test="$vTitleShort='Jinān' or $vTitleShort='Muqtaṭaf' or $vTitleShort='Majallat al-Muqtabas'">
                                        <xsl:value-of select="concat('in ',$vTitleShort)"/>
                                        <xsl:text> </xsl:text>

                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='volume']"
                                            />
                                        </xsl:if>
                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='issue']">
                                            <xsl:value-of
                                                select="concat('(',$vRef/tss:characteristics/tss:characteristic[@name='issue'],')')"
                                            />
                                        </xsl:if>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="$vDatePubl"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- publication title -->
                                        <xsl:choose>
                                            <xsl:when
                                                test="$vRef/tss:characteristics/tss:characteristic[@name='Short Titel'] or $vRef/tss:characteristics/tss:characteristic[@name='Shortened title']">
                                                <xsl:value-of select="concat('in ',$vTitleShort)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="concat('in ',$vTitlePublication)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:choose>
                                            <xsl:when
                                                test="$vRef/tss:characteristics/tss:characteristic[@name='volume']">
                                                <xsl:value-of
                                                  select="concat(' ',$vRef/tss:characteristics/tss:characteristic[@name='volume'])"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise/>
                                        </xsl:choose>
                                        <xsl:value-of select="$vSeparatorInfo"/>
                                        <xsl:if
                                            test="$vRef/tss:characteristics/tss:characteristic[@name='Series']">
                                            <xsl:value-of
                                                select="$vRef/tss:characteristics/tss:characteristic[@name='Series']"/>
                                            <xsl:value-of select="$vSeparatorInfo"/>
                                        </xsl:if>
                                        <xsl:value-of select="$vC15-Place-Publisher-Date"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                        </xsl:when>

                        <!-- Maps -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Maps']">
                            <xsl:if test="$pMode='fn' or 'fn2'">
                                <!--<xsl:if test="$vArchClassMarkShort!=''">
                                    <xsl:value-of select="$vArchClassMarkShort"/>
                                </xsl:if>-->
                                
                                <xsl:if test="$vAuthors!=''">
                                    <xsl:call-template name="funcStringRemoveTrailing">
                                        <xsl:with-param name="pString" select="$vAuthors"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="$vSeparatorInfo"/>
                                </xsl:if>
                                <!--<xsl:value-of select="concat('&quot;',$vTitleArticle)"/>-->
                                <!--<xsl:text>,"</xsl:text>-->
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitleArticle"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:text> [map], </xsl:text>
                                <!-- add additional information: I stored information on the scale in the description field -->
                                <xsl:choose>
                                    <xsl:when test="contains($vRef/tss:characteristics/tss:characteristic[@name='Description'],'1:')">
                                        <xsl:value-of select="$vRef/tss:characteristics/tss:characteristic[@name='Description']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>scale not given</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$vSeparatorInfo"/>
                                <xsl:if test="$vTitlePublication!=''">
                                    <xsl:text> in </xsl:text>
                                    <xsl:call-template name="funcStringTextDecoration">
                                        <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                        <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                        <xsl:with-param name="pDecoration" select="'italics'"/>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:value-of select="if($vC15-Volume!='') then(concat(', ',$vC15-Volume)) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat(', ',$vC15-Contributors-additional)) else()"/>
                                <xsl:value-of select="concat(' (',$vC15-Place-Publisher-Date,')')"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of select="$vCitedPages"/>
                                <!--<xsl:value-of select="$vC15-Url-Accessed"/>-->
                            </xsl:if>
                        </xsl:when>
                        
                        <!-- Regular references -->
                        <xsl:when test="$vRef/tss:publicationType[@name='Book']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:choose>
                                    <xsl:when test="$vEdition!='' or $vC15-Volume!=''">
                                        <xsl:text>, </xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$vC15-Contributors-additional!=''">
                                        <xsl:text>, </xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:value-of select="$vEdition"/>
                                <xsl:value-of select="$vC15-Volume"/>
                                <xsl:value-of select="$vC15-Contributors-additional"/>
                                <xsl:value-of select="concat(' (',$vC15-Place-Publisher-Date,')')"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$vEdition"/>
                                <xsl:value-of select="$vC15-Volume"/>
                                <xsl:value-of select="$vC15-Contributors-additional"/>
                                <xsl:value-of select="$vC15-Place-Publisher-Date"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Edited Book']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>-->
                                <!--<xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>-->
                                <xsl:value-of select="$vAuthors"/>
                                <xsl:text>, </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <!--<xsl:value-of select="$vC15-Volume"/>-->
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat(', ',$vC15-Contributors-additional)) else()"/>
                                <xsl:value-of select="concat(' (',$vC15-Place-Publisher-Date,')')"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$vC15-Place-Publisher-Date"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Book Chapter']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                                <xsl:value-of select="$vCitedPages"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,',&quot;')"/>
                                <xsl:text> in </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <!--<xsl:text>, </xsl:text>-->
                                <xsl:value-of select="if($vC15-Volume!='') then(concat(', ',$vC15-Volume)) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat(', ',$vC15-Contributors-additional)) else()"/>
                                <xsl:value-of select="concat(' (',$vC15-Place-Publisher-Date,')')"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,'.&quot;')"/>
                                <xsl:text> In </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of select="$vC15-Volume"/>
                                <xsl:value-of select="$vC15-Contributors-additional"/>
                                <xsl:value-of select="$vC15-Place-Publisher-Date"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of
                                    select="concat(': ',$vRef/tss:characteristics/tss:characteristic[@name='pages'])"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Journal Article']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                                <xsl:value-of select="$vCitedPages"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,',&quot; ')"/>

                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat(', ',$vC15-Contributors-additional)) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Vol-Issue-Date!='') then(concat(' ',$vC15-Vol-Issue-Date)) else()"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,'.&quot; ')"/>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of
                                    select="if($vC15-Contributors-additional!='') then(concat('. ',$vC15-Contributors-additional)) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Vol-Issue-Date!='') then(concat(' ',$vC15-Vol-Issue-Date)) else()"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of
                                    select="concat(': ',$vRef/tss:characteristics/tss:characteristic[@name='pages'])"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Thesis type']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                                <xsl:value-of select="$vCitedPages"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of
                                    select="concat('&quot;',$vTitlePublication,',&quot; ')"/>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of
                                    select="concat('(',$vC15-Thesis-Publication-details,')')"/>
                                <xsl:value-of select="$vCitedPages"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat(', ',$vC15-Url-Accessed)) else()"
                                />
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitlePublication,'.&quot;')"/>
                                <xsl:if test="$vC15-Title-Orig-Trans!=''">
                                    <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                </xsl:if>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$vC15-Thesis-Publication-details"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat('. ',$vC15-Url-Accessed)) else()"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Manuscript']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                                <xsl:value-of select="$vCitedPages"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, &quot;</xsl:text>
                                <xsl:value-of
                                    select="if($vTitlePublication!='') then($vTitlePublication) else($vTitleArticle)"/>
                                <xsl:text>,&quot; </xsl:text>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of
                                    select="concat('(',$vC15-Thesis-Publication-details,')')"/>
                                <xsl:value-of select="$vCitedPages"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat(', ',$vC15-Url-Accessed)) else()"
                                />
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. &quot;</xsl:text>
                                <xsl:value-of
                                    select="if($vTitlePublication!='') then($vTitlePublication) else($vTitleArticle)"/>
                                <xsl:text>.&quot; </xsl:text>
                                <xsl:if test="$vC15-Title-Orig-Trans!=''">
                                    <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                </xsl:if>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$vC15-Thesis-Publication-details"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat('. ',$vC15-Url-Accessed)) else()"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$vRef/tss:publicationType[@name='Electronic citation']">
                            <xsl:if test="$pMode='fn'">
                                <!--<xsl:value-of
                                    select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                                <xsl:value-of select="$vCitedPages"/>-->
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,',&quot;')"/>
                                <xsl:text> in </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,', ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>, </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$vEdition"/>
                                <!--<xsl:value-of select="$vC15-Contributors-additional"/>-->
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='publisher']"/>
                                <xsl:value-of
                                    select="if($vDatePubl!='') then(concat(', ',$vDatePubl)) else()"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat(', ',$vC15-Url-Accessed)) else()"
                                />
                                <xsl:value-of select="$vCitedPages"/>
                            </xsl:if>
                            <xsl:if test="$pMode='fn2'">
                                <!-- this currently produces a short version of the publication, but not the article, title. As in my thesis all references in this group stem from the EI2, I can make a custom version -->

                                <xsl:copy-of select="$vC15-FnCitSubsequent"/>
                            </xsl:if>
                            <xsl:if test="$pMode='bibl'">
                                <xsl:call-template name="funcStringRemoveTrailing">
                                    <xsl:with-param name="pString" select="$vAuthors"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="concat('&quot;',$vTitleArticle,'.&quot;')"/>
                                <xsl:text> </xsl:text>
                                <xsl:call-template name="funcStringTextDecoration">
                                    <xsl:with-param name="pInputString" select="$vTitlePublication"/>
                                    <xsl:with-param name="pOutputFormat" select="$pOutputFormat"/>
                                    <xsl:with-param name="pDecoration" select="'italics'"/>
                                </xsl:call-template>
                                <xsl:text>. </xsl:text>
                                <!--<xsl:choose>
                                    <xsl:when test="$vC15-Title-Orig-Trans!=''">
                                        <xsl:value-of select="concat($vC15-Title-Orig-Trans,'. ')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <xsl:value-of select="$vEdition"/>
                                <!--<xsl:value-of select="$vC15-Volume"/>
                                <xsl:value-of select="$vC15-Contributors-additional"/>-->
                                <xsl:value-of
                                    select="$vRef/tss:characteristics/tss:characteristic[@name='publisher']"/>
                                <xsl:value-of
                                    select="if($vDatePubl!='') then(concat(', ',$vDatePubl)) else()"/>
                                <xsl:value-of
                                    select="if($vDateOrig!='') then(concat(' [',$vDateOrig,']')) else()"/>
                                <xsl:value-of
                                    select="if($vC15-Url-Accessed!='') then(concat('. ',$vC15-Url-Accessed)) else()"/>
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat($vAuthors,' ',$vRef/tss:dates/tss:date[@type='Publication']/@year)"/>
                            <xsl:value-of select="$vCitedPages"/>
                            <xsl:if test="$pMode='bibl'">
                                <!-- this produces the line-break in bibliographies -->
                                <!--<xsl:value-of select="'.&#10;'" disable-output-escaping="no"/>-->
                                <xsl:value-of select="$vSeparatorRefs" disable-output-escaping="yes"
                                />
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                   
                    </xsl:variable>
                    <!-- embedd the final citation in potential surrounding code -->
                    <xsl:choose>
                        <xsl:when test="$pOutputFormat='tei'">
                            <tei:bibl>
                                <xsl:copy-of select="$vCitationFinal"/>
                            </tei:bibl>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$vCitationFinal"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- debugging -->
                    <!--<xsl:message select="$vLang"/>-->
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$pMode='fn' or $pMode='fn2'">
                    <xsl:value-of select="if(@strProt!='') then(concat(', ',@strProt)) else()"/>
                    <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$pMode='bibl'">
                    <!-- this produces a whole lot of unnecessary line-breaks with introductory points -->
                    <!--<xsl:text>.</xsl:text>
                    <xsl:if test="not(position()=last())">-->
                    <!-- new line &#10; which is &#xA;-->
                    <!-- carriage return: &#13; which is &#xD; -->
                    <!--<xsl:value-of select="'&#10;'" disable-output-escaping="no"/>
                    </xsl:if>-->
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- this template produces the clickable Citation ID "author+year" -->
    <xsl:template name="funcCitID">
        <xsl:param name="pRef" select="ancestor-or-self::tss:reference"/>
        <xsl:variable name="vCitId">
            <xsl:choose>
                <xsl:when
                    test="$pRef/tss:characteristics/tss:characteristic[@name='Citation identifier']!=''">
                    <!-- <xsl:call-template name="funcReplacement">
                        <xsl:with-param name="pString" select="$pRef/tss:characteristics/tss:characteristic[@name='Citation identifier']"/>
                        <xsl:with-param name="pFind" select="' '"/>
                        <xsl:with-param name="pReplace" select="'+'"/>
                    </xsl:call-template> -->
                    <xsl:value-of
                        select="replace($pRef/tss:characteristics/tss:characteristic[@name='Citation identifier'],' ','+')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>No CitationID</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$vCitId"/>
    </xsl:template>

    <!-- this template looks up the UUIDs for provided citation ids -->
    <xsl:template name="funcCitUUID">
        <xsl:param name="pLibrary"/>
        <xsl:param name="pCitID"/>
        <xsl:value-of
            select="$pLibrary//tss:reference[tss:characteristics/tss:characteristic[@name='Citation identifier']=$pCitID]//tss:characteristic[@name='UUID']"
        />
    </xsl:template>

    <xsl:template name="funcCitDocxAmend">
        <xsl:param name="pCitID"/>
        <!-- vCitID splits the input string into nodes containing individual citation IDs -->
        <xsl:variable name="vCitID">
            <xsl:variable name="vCitIDs" select="translate($pCitID,'\{\}',' ')"/>
            <!-- v1c -->
            <xsl:for-each-group select="tokenize($vCitIDs,';\s*')" group-by=".">
                <xsl:element name="till:citId">
                    <!-- v1b -->
                    <xsl:variable name="vCitId">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[1])"/>
                    </xsl:variable>
                    <xsl:variable name="vProtectedString">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[2])"/>
                    </xsl:variable>
                    
                    <xsl:if test="contains($vCitId,'@')">
                        <xsl:attribute name="citPages">
                            <xsl:value-of
                                select="normalize-space(if(contains($vCitId,'@')) then(substring-after($vCitId,'@')) else())"
                            />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$vProtectedString!=''">
                        <xsl:attribute name="strProt" select="$vProtectedString"/>
                    </xsl:if>
                    <xsl:value-of
                        select="normalize-space(if(contains($vCitId,'@')) then(substring-before($vCitId,'@')) else($vCitId))"
                    />
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:element name="till:refGroup">
            <xsl:for-each-group select="$vCitID/till:citId" group-by=".">
                <xsl:element name="till:reference">
                    <xsl:attribute name="citation" select="."/>
                    <xsl:attribute name="pages" select="@citPages"/>
                    <xsl:attribute name="date"/>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:template>
    <xsl:template name="funcCitEditedBook">
        <xsl:param name="pCitID"/>
        <xsl:param name="pUUID"/>
        <xsl:param name="pRef"/>
        <xsl:param name="pLibrary"/>
        <!-- vCitID splits the input string into nodes containing individual citation IDs -->
        <xsl:variable name="vCitID">
            <xsl:variable name="vCitIDs" select="translate($pCitID,'\{\}',' ')"/>
            <!-- v1c -->
            <xsl:for-each-group select="tokenize($vCitIDs,';\s*')" group-by=".">
                <xsl:element name="till:citId">
                    <!-- v1b -->
                    <xsl:variable name="vCitId">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[1])"/>
                    </xsl:variable>
                    <xsl:variable name="vProtectedString">
                        <xsl:value-of
                            select="normalize-space(tokenize(current-grouping-key(),'/')[2])"/>
                    </xsl:variable>
                    
                    <xsl:if test="contains($vCitId,'@')">
                        <xsl:attribute name="citPages">
                            <xsl:value-of
                                select="normalize-space(if(contains($vCitId,'@')) then(substring-after($vCitId,'@')) else())"
                            />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$vProtectedString!=''">
                        <xsl:attribute name="strProt" select="$vProtectedString"/>
                    </xsl:if>
                    <xsl:value-of
                        select="normalize-space(if(contains($vCitId,'@')) then(substring-before($vCitId,'@')) else($vCitId))"
                    />
                </xsl:element>
            </xsl:for-each-group>
        </xsl:variable>
        
        <!-- vRefs pulls the references corresponding to the citation IDs in vCitID from the Sente XML library specified in pLibrary -->
        <xsl:variable name="vRefs">
            <xsl:choose>
                <xsl:when test="$pCitID!=''">
                    <!-- this should take into account that some references might not be found in the library -->
                    <xsl:for-each select="$vCitID/till:citId">
                        <xsl:variable name="vCitID1" select="."/>
                        <xsl:element name="tss:reference">
                            <xsl:attribute name="citPages" select="./@citPages"/>
                            <xsl:attribute name="strProt" select="./@strProt"/>
                            <xsl:choose>
                                <!-- check whether the library contains a match -->
                                <xsl:when
                                    test="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=$vCitID1]">
                                    <xsl:variable name="vRef"
                                        select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=$vCitID1]"/>
                                    <xsl:choose>
                                        <!-- check whether the CitationID is unique! -->
                                        <xsl:when test="count($vRef/tss:dates)=1">
                                            <!-- to ease sorting a new attribute is built -->
                                            <xsl:variable name="vPubDate">
                                                <xsl:variable name="vDPubY"
                                                    select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                                                <xsl:variable name="vDPubM"
                                                    select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>
                                                <xsl:variable name="vDPubD"
                                                    select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                                                <xsl:value-of
                                                    select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                                            </xsl:variable>
                                            <xsl:attribute name="datePubl" select="$vPubDate"/>
                                            <xsl:for-each select="$vRef/node()">
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="error">duplicate</xsl:attribute>
                                            <xsl:copy-of select="$vCitID1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="error">not found</xsl:attribute>
                                    <xsl:copy-of select="$vCitID1"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$pUUID!=''">
                    <xsl:variable name="vRef"
                        select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='UUID']=$pUUID]"/>
                    <xsl:element name="tss:reference">
                        <!-- to ease sorting a new attribute is built -->
                        <xsl:variable name="vPubDate">
                            <xsl:variable name="vDPubY"
                                select="$vRef/tss:dates/tss:date[@type='Publication']/@year"/>
                            <xsl:variable name="vDPubM"
                                select="if($vRef/tss:dates/tss:date[@type='Publication']/@month) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@month),'00')) else()"/>
                            <xsl:variable name="vDPubD"
                                select="if($vRef/tss:dates/tss:date[@type='Publication']/@day) then(format-number(number($vRef/tss:dates/tss:date[@type='Publication']/@day),'00')) else()"/>
                            <xsl:value-of select="concat($vDPubY,'-',$vDPubM,'-',$vDPubD)"/>
                        </xsl:variable>
                        <xsl:attribute name="datePubl" select="$vPubDate"/>
                        <xsl:for-each select="$vRef/node()">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$pRef"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Look up, if vRef is of type "Book Chapter" -->
        <xsl:variable name="vParentBook">
            <xsl:for-each select="$vRefs/tss:reference">
                <xsl:if test="./tss:publicationType/@name='Book Chapter'">
                    <!--<xsl:message select="'is book chapter'"/>-->
                    <xsl:variable name="vPubTitle" select="lower-case(normalize-space(./tss:characteristics/tss:characteristic[@name='publicationTitle']))"/>
                    <!--<xsl:message select="$vPubTile"/>-->
                    <!--<xsl:for-each select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:publicationType/@name='Edited Book'][lower-case(normalize-space(./tss:characteristics/tss:characteristic[@name='publicationTitle']))=$vPubTile]">
                        <!-\-<xsl:message select="'there is a parent reference'"/>-\->
                        <xsl:value-of select="concat('{',./tss:characteristics/tss:characteristic[@name='Citation identifier'],'}')"/>
                    </xsl:for-each>-->
                    <xsl:choose>
                        <xsl:when test="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:publicationType/@name='Edited Book'][lower-case(normalize-space(./tss:characteristics/tss:characteristic[@name='publicationTitle']))=$vPubTitle]">
                            <xsl:variable name="vParentRef" select="$pLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:publicationType/@name='Edited Book'][lower-case(normalize-space(./tss:characteristics/tss:characteristic[@name='publicationTitle']))=$vPubTitle]"/>
                            <!--<xsl:message select="'there is a parent reference'"/>-->
                            <xsl:element name="till:reference">
                                <xsl:attribute name="citation">
                                    <xsl:value-of select="$vParentRef/tss:characteristics/tss:characteristic[@name='Citation identifier']"/>
                                </xsl:attribute>
                                <xsl:attribute name="publicationType" select="'Edited Book'"/>
                                <xsl:value-of select="$vPubTitle"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="till:reference">
                                <xsl:attribute name="citation">
                            <xsl:value-of select="./tss:characteristics/tss:characteristic[@name='Citation identifier']"/>
                                </xsl:attribute>
                                <xsl:attribute name="publicationType" select="'Book Chapter'"/>
                                <xsl:value-of select="$vPubTitle"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:element name="till:refGroup">
            <xsl:copy-of select="$vParentBook/till:reference[@publicationType='Edited Book']"/>
            
        </xsl:element>
        <xsl:element name="till:refGroup">
            <xsl:copy-of select="$vParentBook/till:reference[@publicationType='Book Chapter']"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
