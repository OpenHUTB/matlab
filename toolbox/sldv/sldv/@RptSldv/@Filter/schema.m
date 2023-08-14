function schema







    pkg=findpackage('RptSldv');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'Filter',pkgRG.findclass('rptcomponent'));



    p=rptgen.prop(h,'FilterContainer','string','',...
    getString(message('Sldv:RptSldv:Filter:schema:LookupObjectIn')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'addAnchor','bool',true,...
    getString(message('Sldv:RptSldv:Filter:schema:AutomaticallyInsertLinkingAnchor')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
    });
