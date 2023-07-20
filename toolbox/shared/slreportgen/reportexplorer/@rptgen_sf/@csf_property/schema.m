function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_property',pkgRG.findclass('rpt_var_display'));

    p=rptgen.prop(h,'StateflowProperty',rptgen.makeStringType,'Name',...
    getString(message('RptgenSL:rsf_csf_property:propertyNameLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
'getDisplayName'
'getDisplayValue'
    });