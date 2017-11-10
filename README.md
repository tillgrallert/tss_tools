---
title: "read me: tss_tools"
author: Till Grallert
date: 2017-07-04 12:04:52 +0200
---

This repository contains mainly XSLT stylesheets that process Sente XML. I have used Sente as a reference manager to manage all historical sources, storing a mix of bibliographic data, annotations, translations, and transkriptions. All of these can contain mark-up. Sente export escapes all mark-up in text nodes (in order to avoid generating invalid XML). However, the escaping is buggy since ampersands are twice escaped: `&amp;amp;`, `&amp;lt;` etc.

1. The stylesheet [`tss_unescape-text-nodes.xsl`](tss_unescape-text-nodes.xsl) corrects the faulty character escaping and unescapes an explicitly defined set of nodes in order to be further processed.
2. The stylesheet [`tss_correct-namespace-in-text-nodes.xsl`](tss_correct-namespace-in-text-nodes.xsl) adds necessary namespace information (such as HTML and TEI) to the escaped nodes.
    - *NOTE*: In order to be able to re-import the XML files into Sente, all non-Sente (tss namespace) nodes must be unescaped again and all additional namespace declarations must be removed!
        - Sente will abort import of files containing additional namespace declarations on any tss node without even an error message
        - all unescaped mark-up will be stripped out without a trace
4. The stylesheet [`tss_citation-functions.xsl`](tss_citation-functions.xsl) provides functions to format citations as HTML, markdown, or Word XML.
    - *NOTE*: in order to safe computation time and power, the formatted references could be included in the Sente XML and then copied when needed.

