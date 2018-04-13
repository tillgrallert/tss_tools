<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:kml="http://earth.google.com/kml/2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"
        name="xml"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- statuses must be mapped to keywords -->
    <xsl:template match="tss:keywords">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
            <xsl:if test="ancestor::tss:reference/descendant::tss:characterstic[@name='status']">
                <xsl:element name="tss:keyword">
                <xsl:attribute name="assigner" select="'Sente User Sebastian'"/>
                <xsl:text>status: </xsl:text>
                <xsl:value-of select="ancestor::tss:reference/descendant::tss:characterstic[@name='status']"/>
            </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- add caption based on pub title -->
    <xsl:template match="tss:characteristics[ancestor::tss:reference/tss:publicationType/@name='Photograph']">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
            <xsl:if test="child::tss:characteristic/@name='articleTitle'">
                <xsl:element name="tss:characteristic">
                <xsl:attribute name="name" select="'Caption'"/>
                <xsl:analyze-string select="child::tss:characteristic[@name='articleTitle']" regex="(Image\s\d+:\s+)(.[^\[]+)\[">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:element></xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- change the local path -->
   <xsl:template match="tss:attachmentReference">
       <xsl:copy>
           <xsl:choose>
               <xsl:when test="starts-with(child::tss:name,'Scan')">
                   <xsl:variable name="vName" select="child::tss:name"/>
                   <xsl:variable name="vFileName" select="parent::node()/tss:attachmentReference[child::tss:name=concat('URL ',$vName)]/tss:URL"/>
                   <xsl:copy-of select="child::tss:name"/>
                   <xsl:element name="URL">
                       <xsl:text>file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Photos/TFDC</xsl:text>
                       <xsl:value-of select="substring-after($vFileName,'-TFDC')"/>
                   </xsl:element>
               </xsl:when>
               <xsl:when test="starts-with(child::tss:name,'Archived Website')">
                   <xsl:copy-of select="child::tss:name"/>
                   <xsl:element name="URL">
                       <xsl:text>file:///BachUni/BachSources/EAP644%20Bonfils%20Collection/Websites/</xsl:text>
                       <xsl:value-of select=" translate(ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='call-num'],'/','-')"/>
                       <xsl:text>.html</xsl:text>
                   </xsl:element>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:apply-templates select="node()"/>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:copy>
   </xsl:template> 
   
</xsl:stylesheet>