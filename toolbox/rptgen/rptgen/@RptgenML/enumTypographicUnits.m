function e=enumTypographicUnits




    eType='rptgen_typographic_units';


    e=rptgen.enum(eType,{
'in'
'pt'
'pi'
'pixels'
    },{
    getString(message('rptgen:RptgenML_StylesheetTitlePage:unitsInches'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:unitsPoints'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:unitsPicas'))
    getString(message('rptgen:RptgenML_StylesheetTitlePage:unitsPixels'))
    });
