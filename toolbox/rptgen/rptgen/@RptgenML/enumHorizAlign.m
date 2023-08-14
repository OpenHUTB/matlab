function e=enumHorizAlign




    eType='rptgen_horiz_align';

    e=rptgen.enum(eType,{
'left'
'center'
'right'
    },{
    getString(message('rptgen:RptgenML_StylesheetTitlePage:halignLeft'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:halignCenter'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:halignRight'))
    });
