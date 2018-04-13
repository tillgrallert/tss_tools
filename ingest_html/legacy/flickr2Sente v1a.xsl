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
    
    <!-- This stylesheet builds Sente XML and an applescript from the links to flickr sites -->
    
    <!-- keep in mind that all local attachments must be available upon import into Sente, otherwise the links will be stripped from the references -->
    <!-- v1a: original test version. 
    PROBLEM: flickr returns buggy html, which causes the debugger to terminate the extraction of the image url. Shit! -->
    <!--
    - mode m5 produces an applescript to download the image files to the hd 
    - mode m4 produces the Sente XML references with links to the downloaded images
    -->
    
    <!-- as the import engine is extremely bugy or rather as duplicate detection is a bit over ambitious, I have to introduce individual article titles to get all references imported. As the eap links are unique for each number, I will use the catId-string from them for this purpose -->
    
    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions.xsl"/> <!-- provides replacement functions -->
    
    <xsl:param name="pgDoc" select="document('http://www.flickr.com/photos/39631091@N03/3752306117/')"/>
    
    <xsl:template match="*">
        <xsl:variable name="vImgUrl" select="$pgDoc/head//meta[@property='og:image']/@content"/>
        <xsl:value-of select="$vImgUrl"/>
    </xsl:template>
    
</xsl:stylesheet>