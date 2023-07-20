function schema







    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_property',pkgRG.findclass('rpt_var_display'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'ObjectType',rptgen_sl.enumSimulinkType,'System',...
    getString(message('RptgenSL:rsl_csl_property:objectTypeLabel')),lic);


    p=rptgen.prop(h,'ModelProperty',rptgen.makeStringType,'Name',...
    getString(message('RptgenSL:rsl_csl_property:modelParameterNameLabel')),lic);


    p=rptgen.prop(h,'SystemProperty',rptgen.makeStringType,'Name',...
    getString(message('RptgenSL:rsl_csl_property:systemParameterNameLabel')),lic);


    p=rptgen.prop(h,'BlockProperty',rptgen.makeStringType,'Name',...
    getString(message('RptgenSL:rsl_csl_property:blockParameterNameLabel')),lic);


    p=rptgen.prop(h,'SignalProperty',rptgen.makeStringType,'Name',...
    getString(message('RptgenSL:rsl_csl_property:signParameterNameLabel')),lic);


    p=rptgen.prop(h,'AnnotationProperty',rptgen.makeStringType,'Text',...
    getString(message('RptgenSL:rsl_csl_property:annotationParameterNameLabel')),lic);







    rptgen.makeStaticMethods(h,{
    },{
'getDisplayName'
'getDisplayValue'
    });
