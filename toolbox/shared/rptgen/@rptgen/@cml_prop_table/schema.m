function schema




    pkgRG=findpackage('rptgen');

    h=schema.class(pkgRG,'cml_prop_table',pkgRG.findclass('rpt_prop_table'));


    rptgen.makeStaticMethods(h,{
    },{
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getDialogSchema'
'pt_getReportedObject'
    });