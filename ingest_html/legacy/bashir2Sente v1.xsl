<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no"
        version="1.0" xpath-default-namespace="http://www.thirdstreetsoftware.com/SenteXML-1.0"/>
    <xsl:output encoding="UTF-8" method="text" name="text" omit-xml-declaration="yes"/>

    <!-- This stylesheet builds Sente XML for scans of periodicals. It does not need html as input -->

    <!-- v1: production version; currently adapted to hadiqat -->
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. I used the unique call-numbers for this purpose -->
    <!-- provides citations, date, and currency conversion -->
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>

    <xsl:variable name="vgDate" select="current-date()"/>

    <xsl:param name="pgStartDate" select="'1871-01-07'"/>
    <xsl:param name="pgStopDate" select="'1871-12-31'"/>
    <xsl:param name="pgStartImg" select="1"/>
    <xsl:param name="pgStartIssue" select="19"/>
    <xsl:param name="pgVolume" select="1"/>
    <xsl:param name="pgPages" select="4"/>
    <!-- sometimes the computation of Hijri dates is one day off from the local Hijrī -->
    <xsl:param name="pgDHCorrector" select="0"/>
    <!-- these two paramaters select the folder containing the image files -->
    <xsl:param name="pgUrlBase" select="'/BachUni/BachSources/'"/>
    <xsl:param name="pgUrlVar" select="'al-bashir/AUB/mic54_albashir_1907-19011_'"/>


    <!--<xsl:template match="*">
        <xsl:apply-templates mode="m4"/>
    </xsl:template>-->


    <xsl:template match="*">
        <xsl:result-document
            href="bashir2Sente {replace($pgStartDate,'-','')}-{replace($pgStopDate,'-','')} {format-date($vgDate,'[Y01][M01][D01]')}.xml"
            method="xml">
            <xsl:element name="tss:senteContainer">
                <xsl:attribute name="version">1.0</xsl:attribute>
                <xsl:attribute name="xsi:schemaLocation"
                    >http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd</xsl:attribute>
                <xsl:element name="tss:library">
                    <xsl:element name="tss:references">
                        <xsl:call-template name="tReferencesM4"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="tReferencesM4">
        <!-- for al-Hasna it must be monthly -->
        <xsl:variable name="vRefs">
            <xsl:call-template name="tIncrementWeekly"/>
        </xsl:variable>
        <xsl:for-each select="$vRefs/issue">
            <xsl:element name="tss:reference">
                <xsl:element name="tss:publicationType">
                    <xsl:attribute name="name">Archival Periodical</xsl:attribute>
                </xsl:element>
                <xsl:element name="tss:dates">
                    <xsl:element name="tss:date">
                        <xsl:attribute name="type">Publication</xsl:attribute>
                        <xsl:attribute name="day">
                            <xsl:value-of select="tokenize(normalize-space(./date),'-')[3]"/>
                        </xsl:attribute>
                        <xsl:attribute name="month">
                            <xsl:value-of select="tokenize(normalize-space(./date),'-')[2]"/>
                        </xsl:attribute>
                        <xsl:attribute name="year">
                            <xsl:value-of select="tokenize(normalize-space(./date),'-')[1]"/>
                        </xsl:attribute>
                    </xsl:element>
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

                </xsl:element>
                <xsl:element name="tss:characteristics">
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">articleTitle</xsl:attribute>
                        <xsl:value-of select="./number"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationTitle</xsl:attribute>
                        <xsl:value-of select="'al-Bashīr'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Short Titel</xsl:attribute>
                        <xsl:value-of select="'Bashīr'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">volume</xsl:attribute>
                        <xsl:value-of select="$pgVolume"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">issue</xsl:attribute>
                        <xsl:value-of select="./number"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">language</xsl:attribute>
                        <xsl:value-of select="'Arabic'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">pages</xsl:attribute>
                        <xsl:value-of select="concat('1-',$pgPages)"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publicationCountry</xsl:attribute>
                        <xsl:value-of select="'Bayrūt'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">publisher</xsl:attribute>
                        <xsl:value-of select="'Maṭbaʿat al-Ābāʾ al-Yasūʿiyīn'"/>
                    </xsl:element>
                    <!--<xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Date Hijri</xsl:attribute>
                        <xsl:variable name="vDateH">
                            <xsl:call-template name="funcDateG2H">
                                <xsl:with-param name="pDateG" select="./date"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateHFormatted">
                            <xsl:call-template name="funcDateFormatTei">
                                <xsl:with-param name="pDate" select="$vDateH"/>
                                <xsl:with-param name="pCal" select="'H'"/>
                                <xsl:with-param name="pOutput" select="'formatted'"/>
                                <xsl:with-param name="pWeekday" select="'n'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="$vDateHFormatted"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Date Rumi</xsl:attribute>
                        <!-\- one has to select either mali or rumi here -\->
                        <xsl:variable name="vDateM">
                            <xsl:call-template name="funcDateG2M">
                                <xsl:with-param name="pDateG" select="./date"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateMFormatted">
                            <xsl:call-template name="funcDateFormatTei">
                                <xsl:with-param name="pDate" select="$vDateM"/>
                                <xsl:with-param name="pCal" select="'M'"/>
                                <xsl:with-param name="pOutput" select="'formatted'"/>
                                <xsl:with-param name="pWeekday" select="'n'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateJ">
                            <xsl:call-template name="funcDateG2J">
                                <xsl:with-param name="pDateG" select="./date"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateJFormatted">
                            <xsl:call-template name="funcDateFormatTei">
                                <xsl:with-param name="pDate" select="$vDateJ"/>
                                <xsl:with-param name="pCal" select="'J'"/>
                                <xsl:with-param name="pOutput" select="'formatted'"/>
                                <xsl:with-param name="pWeekday" select="'n'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <!-\- one has to select either mali (M) or rumi (J) here -\->
                        <xsl:value-of select="$vDateMFormatted"/>
                    </xsl:element>-->

                    <!--<xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Repository</xsl:attribute>
                        <xsl:value-of select="'EAP'"/>
                    </xsl:element>-->
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Standort</xsl:attribute>
                        <xsl:value-of select="'AUB'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">call-num</xsl:attribute>
                        <xsl:value-of select="'Mic-Na:54'"/>
                    </xsl:element>
                    <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">Citation identifier</xsl:attribute>
                        <xsl:value-of select="concat('bashir ',$pgVolume,'-',./number)"/>
                    </xsl:element>
                    <!-- <xsl:element name="tss:characteristic">
                        <xsl:attribute name="name">URL</xsl:attribute>
                        <xsl:value-of select="concat('http://eap.bl.uk/database/','overview_item.a4d?catId=892;r=11337')"/>
                    </xsl:element>-->
                </xsl:element>
                <xsl:element name="tss:attachments">
                    <xsl:call-template name="tIncrementUrl2">
                        <xsl:with-param name="pNumStart" select="./img"/>
                        <xsl:with-param name="pNumStop" select="number(./img) +$pgPages -1"/>
                        <xsl:with-param name="pDate" select="./date"/>
                    </xsl:call-template>
                </xsl:element>
                <!--<xsl:element name="tss:attachments">
                    <xsl:call-template name="tIncrementUrl1">
                        <xsl:with-param name="pNumStart" select="./img"/>
                        <xsl:with-param name="pNumStop" select="./img + $pgPages - 1"/>
                    </xsl:call-template>
                </xsl:element>-->
                <xsl:element name="tss:keywords">
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>Source</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>newspaper/periodical</xsl:text>
                    </xsl:element>
                    <xsl:element name="tss:keyword">
                        <xsl:attribute name="assigner">Sente User Sebastian</xsl:attribute>
                        <xsl:text>weekly</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="tIncrementUrl2">
        <xsl:param name="pNumStart"/>
        <xsl:param name="pNumStop"/>
        <xsl:param name="pDate"/>
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="concat($pgUrlBase,$pgUrlVar)"/>
        </xsl:variable>
        <xsl:element name="tss:attachmentReference">
            <!--<xsl:element name="name">
                <xsl:value-of select="concat('p',$pNumStart)"/>
            </xsl:element>-->
            <xsl:element name="URL">
                <xsl:value-of select="concat($vUrlImgBase, format-number($pNumStart,'0000'),'.jpg')"
                />
            </xsl:element>
        </xsl:element>
        <xsl:if test="number($pNumStart) lt number($pNumStop)">
            <xsl:call-template name="tIncrementUrl2">
                <xsl:with-param name="pNumStart" select="$pNumStart + 1"/>
                <xsl:with-param name="pNumStop" select="$pNumStop"/>
                <xsl:with-param name="pDate" select="$pDate"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="tIncrementUrl1">
        <xsl:param name="pNumStart"/>
        <xsl:param name="pNumStop"/>
        <xsl:variable name="vUrlImgBase">
            <xsl:value-of select="concat($pgUrlBase,$pgUrlVar,'/HA-1_Page_')"/>
        </xsl:variable>
        <xsl:element name="tss:attachmentReference">
            <xsl:element name="name">
                <xsl:value-of select="concat('p',$pNumStart)"/>
            </xsl:element>
            <xsl:element name="URL">
                <xsl:value-of
                    select="concat($vUrlImgBase, format-number($pNumStart,'000'),'_150dpi.jpg')"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="number($pNumStart) lt number($pNumStop)">
            <xsl:call-template name="tIncrementUrl1">
                <xsl:with-param name="pNumStart" select="$pNumStart + 1"/>
                <xsl:with-param name="pNumStop" select="$pNumStop"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <!-- this template produces a series of <issue> notes with children for <date>, <number>, <img> -->
    <xsl:template name="tIncrementWeekly">
        <xsl:param name="pDate" select="$pgStartDate"/>
        <xsl:param name="pIssue" select="$pgStartIssue"/>
        <xsl:param name="pImgUrl" select="$pgStartImg"/>
        <xsl:variable name="vDateJD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="pDateG" select="$pDate"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateInc">
            <xsl:call-template name="funcDateJD2G">
                <xsl:with-param name="pJD" select="$vDateJD + 7"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vIssueInc">
            <xsl:value-of select="$pIssue + 1"/>
        </xsl:variable>
        <xsl:element name="issue">
            <xsl:element name="date">
                <xsl:value-of select="$pDate"/>
            </xsl:element>
            <xsl:element name="number">
                <xsl:value-of select="$pIssue"/>
            </xsl:element>
            <xsl:element name="img">
                <xsl:value-of select="$pImgUrl"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="$vDateInc lt $pgStopDate">
            <xsl:call-template name="tIncrementWeekly">
                <xsl:with-param name="pDate" select="$vDateInc"/>
                <xsl:with-param name="pIssue" select="$pIssue + 1"/>
                <xsl:with-param name="pImgUrl" select="$pImgUrl + $pgPages"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="tIncrementFortnightly">
        <xsl:param name="pDate" select="$pgStartDate"/>
        <xsl:param name="pIssue" select="$pgStartIssue"/>
        <xsl:param name="pImgUrl" select="$pgStartImg"/>
        <xsl:variable name="vDayInc">
            <xsl:choose>
                <xsl:when test="number(tokenize($pDate,'-')[3])=1">
                    <xsl:value-of select="'15'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'01'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vMonthInc">
            <!-- only increments if the day is 15 or higher -->
            <xsl:choose>
                <xsl:when test="number(tokenize($pDate,'-')[3]) &gt;=15">
                    <xsl:value-of select="number(tokenize($pDate,'-')[2]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="number(tokenize($pDate,'-')[2])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vDateInc">
            <xsl:choose>
                <xsl:when test="$vMonthInc &lt;= 12">
                    <xsl:value-of
                        select="concat(tokenize($pDate,'-')[1],'-',format-number($vMonthInc,'00'),'-',$vDayInc)"
                    />
                </xsl:when>
                <!-- this only kicks in for January -->
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(number(tokenize($pDate,'-')[1])+1,'-',format-number($vMonthInc -12,'00'),'-',$vDayInc)"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vIssueInc">
            <xsl:value-of select="$pIssue + 1"/>
        </xsl:variable>
        <xsl:element name="issue">
            <xsl:element name="date">
                <xsl:value-of select="$pDate"/>
            </xsl:element>
            <xsl:element name="number">
                <xsl:value-of select="$pIssue"/>
            </xsl:element>
            <xsl:element name="img">
                <xsl:value-of select="$pImgUrl"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="$vDateInc lt $pgStopDate">
            <xsl:call-template name="tIncrementFortnightly">
                <xsl:with-param name="pDate" select="$vDateInc"/>
                <xsl:with-param name="pIssue" select="$pIssue + 1"/>
                <xsl:with-param name="pImgUrl" select="$pImgUrl + $pgPages"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="tIncrementMonthly">
        <xsl:param name="pDate" select="$pgStartDate"/>
        <xsl:param name="pIssue" select="$pgStartIssue"/>
        <xsl:param name="pImgUrl" select="$pgStartImg"/>
        <xsl:variable name="vMonthInc" select="number(tokenize($pDate,'-')[2]) + 1"/>
        <xsl:variable name="vDateInc">
            <xsl:choose>
                <xsl:when test="$vMonthInc &lt;= 12">
                    <xsl:value-of
                        select="concat(tokenize($pDate,'-')[1],'-',format-number($vMonthInc,'00'),'-',tokenize($pDate,'-')[3])"
                    />
                </xsl:when>
                <!-- this only kicks in for January -->
                <xsl:otherwise>
                    <xsl:value-of select="number(tokenize($pDate,'-')[1])+1"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number($vMonthInc -12,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="tokenize($pDate,'-')[3]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vIssueInc">
            <xsl:value-of select="$pIssue + 1"/>
        </xsl:variable>
        <xsl:element name="issue">
            <xsl:element name="date">
                <xsl:value-of select="$pDate"/>
            </xsl:element>
            <xsl:element name="number">
                <xsl:value-of select="$pIssue"/>
            </xsl:element>
            <xsl:element name="img">
                <xsl:value-of select="$pImgUrl"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="$vDateInc lt $pgStopDate">
            <xsl:call-template name="tIncrementMonthly">
                <xsl:with-param name="pDate" select="$vDateInc"/>
                <xsl:with-param name="pIssue" select="$pIssue + 1"/>
                <xsl:with-param name="pImgUrl" select="$pImgUrl + $pgPages"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
