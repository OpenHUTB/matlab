function schema






    pkgSL=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkgSL,'csl_prop_table',pkgRG.findclass('rpt_prop_table'));

    rptgen.prop(this,'ObjectType',rptgen_sl.enumSimulinkType,'Model','','SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(this,{
    },{
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getReportedObject'
    });
