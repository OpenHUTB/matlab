function e=enumTitlePageContents




    eType='rptgen_titlepage_contents';

    e=rptgen.enum(eType,{
'title'
'subtitle'
'author'
'image'
'copyright'
'pubdate'
'legalnotice'
'abstract'
    },{
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemTitle'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemSubtitle'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemAuthor'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemImage'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemCopyright'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemPublicationDate'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemLegalNotice'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:tpElemAbstract'))
    });
