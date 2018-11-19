<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    exclude-result-prefixes="xs html tei tss"
    version="3.0">
    
    <!-- reproduce all nodes that lack a more specific match argument -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tss:characteristic[@name='language']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- fix language information by a) converting existing information to BCP 47 -->
            <xsl:variable name="v_lang" select="lower-case(normalize-space(.))"/>
            <xsl:choose>
                <!-- correct language codes -->
                <xsl:when test="$v_lang = ('arabic' , 'arabisch')">
                    <xsl:text>ar</xsl:text>
                </xsl:when>
                <xsl:when test="$v_lang = ('ottoman' , 'ottoman turkish')">
                    <xsl:text>ota</xsl:text>
                </xsl:when>
                <xsl:when test="$v_lang = ('english' , 'englisch')">
                    <xsl:text>en</xsl:text>
                </xsl:when>
                <xsl:when test="$v_lang = ('french' , 'französisch')">
                    <xsl:text>fr</xsl:text>
                </xsl:when>
                <xsl:when test="$v_lang = ('german' , 'deutsch')">
                    <xsl:text>de</xsl:text>
                </xsl:when>
                <xsl:when test="$v_lang = ('turkish' , 'türkish')">
                    <xsl:text>tr</xsl:text>
                </xsl:when>
                <!-- try to assert language in case of missing language codes -->
                <xsl:when test="$v_lang = ''">
                    <xsl:call-template name="t_language-test">
                        <xsl:with-param name="p_input-string" select="concat(parent::tss:characteristics/tss:characteristic[@name='publicationTitle'],' ',parent::tss:characteristics/tss:characteristic[@name='articleTitle'])"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$v_lang"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="t_language-test">
        <xsl:param name="p_input-string"/>
        <xsl:variable name="v_input-string" select="lower-case($p_input-string)"/>
        <xsl:variable name="v_arabic-values"
            select="'bi','fī','fīhi','fīhā','wa','aw','ilā','min','maʿa','ʿan','ʿalā','alā','li-','wa-'"/>
        <xsl:variable name="v_french-values"
            select="'à','á','d','dans','de','du','en','et','ou','un','une','la','le','les','sur'"/>
        <xsl:variable name="v_german-values"
            select="'auf','als','bei','bis','der','die','das','den','dem','einer','eine','eines','einem','einen','für','im','ist','oder','und','unter','über','von','vom','zu','zur','zum'"/>
        <xsl:variable name="v_ottoman-values" select="'-yi','-i','-ı'"/>
        <xsl:variable name="v_turkish-values" select="'ve'"/>
        <xsl:variable name="v_english-values"
            select="'an','and','as','at','by','but','during','from','for','in','is','it','its','of','on','or','nor','the','to','under','was','with','were'"/>
        
        <!-- the template should look at every word and test if it is part of a language variable -->
        <xsl:variable name="v_lang">
            <xsl:choose>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_arabic-values)">
                    <xsl:text>ar</xsl:text>
                </xsl:when>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_french-values)">
                    <xsl:text>fr</xsl:text>
                </xsl:when>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_german-values)">
                    <xsl:text>de</xsl:text>
                </xsl:when>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_ottoman-values)">
                    <xsl:text>ota</xsl:text>
                </xsl:when>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_turkish-values)">
                    <xsl:text>tr</xsl:text>
                </xsl:when>
                <xsl:when test="tokenize($v_input-string,'\W')=($v_english-values)">
                    <xsl:text>en</xsl:text>
                </xsl:when>
                <!-- fallback -->
                <xsl:otherwise>
                    <xsl:text>NA</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$v_lang"/>
    </xsl:template>
    
</xsl:stylesheet>