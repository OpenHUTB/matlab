function schema






    pkgFP=findpackage('rptgen_fp');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkgFP,'cfp_prop_table',pkgRG.findclass('rpt_prop_table'));


    rptgen.makeStaticMethods(h,{
    },{
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getReportedObject'
    });
