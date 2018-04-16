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
    
    <!-- This helper stylesheet builds applescript to download images (or any link) from the net to a folder -->
    <!-- The stylesheet can be called from other XSLT stylesheets which have to supply the data for the target folder, the link list, and the list of file names to be generated
        pTargetFolder must be wrapped in single quotes to make it a literal string
        pUrlDoc and pID are comma-separated lists of values in double quotes -->
    
    
    
    <xsl:template name="t_applescript">
        <xsl:param name="p_target-folder"/>
        <xsl:param name="p_url-base"/>
        <xsl:param name="p_url-doc"/>
        <xsl:param name="p_id"/>
        <![CDATA[
set vUrlBase to "]]><xsl:value-of select="replace($p_url-base,'\s','')" disable-output-escaping="no"/><![CDATA["]]>
        <![CDATA[
set vUrlDoc to {]]><xsl:value-of select="replace($p_url-doc,'\s','')" disable-output-escaping="no"/><![CDATA[}]]>
        <![CDATA[
set vID to {]]><xsl:value-of select="replace($p_id,'\s','')"/><![CDATA[}]]>
        <![CDATA[

set vErrors to {}
set vFolder to "]]><xsl:value-of select="$p_target-folder"/><![CDATA["

repeat with Y from 1 to (number of items) of vUrlDoc
	set vUrlDocSelected to item Y of vUrlDoc
	set vIDSelected to item Y of vID
	set vFileName to vFolder & "/" & vIDSelected & ".jpg"
	delay 0.5
	try
		do shell script "curl -o '" & vFileName & "' " & vUrlBase & vUrlDocSelected
	on error
		set end of vErrors to vUrlDocSelected
		set the clipboard to vErrors as text
	end try
	
end repeat

]]>

        <!-- tell application "TextEdit"
	make new document
	set text of document 1 to (the clipboard as text)
	save document 1 in vFolder1 & "/postcard-errors.txt"
end tell -->

    </xsl:template>
  
</xsl:stylesheet>