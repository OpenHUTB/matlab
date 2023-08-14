function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_auto_table',pkgRG.findclass('rpt_auto_table'));


    p=rptgen.prop(h,'ShowFullName','bool',false,...
    getString(message('RptgenSL:rsl_csl_auto_table:fullPathLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'ShowNamePrompt','bool',true,...
    getString(message('RptgenSL:rsl_csl_auto_table:propertyNamesAsPromptsLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'ObjectType',rptgen_sl.enumSimulinkTypeAuto,'auto',...
    getString(message('RptgenSL:rsl_csl_auto_table:showCurrentLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'PropertyListMode',{
    'auto',getString(message('RptgenSL:rsl_csl_auto_table:autoPropertiesLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_auto_table:showPropertiesLabel'))
    },'auto','','SIMULINK_Report_Gen');


    p=rptgen.prop(h,'PropertyList','MATLAB array',{},...
    '','SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
'atGetName'
'atGetObjects'
'atGetPropertyList'
'atGetPropertySource'
'atGetPropertyValue'
'atGetType'
'atIgnoreValue'
    });
