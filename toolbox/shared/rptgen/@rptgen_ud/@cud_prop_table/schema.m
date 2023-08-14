function schema




    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkgUD,'cud_prop_table',...
    pkgRG.findclass('rpt_prop_table'));


    p=rptgen.makeProp(h,'UddType',rptgen_ud.enumObjectType,'Class',...
    getString(message('rptgen:ru_cud_prop_table:typeLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getReportedObject'
    });