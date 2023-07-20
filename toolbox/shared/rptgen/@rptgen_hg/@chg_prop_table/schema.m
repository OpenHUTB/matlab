function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'chg_prop_table',pkgRG.findclass('rpt_prop_table'));

    rptgen.prop(this,'ObjectType',rptgen_hg.enumHandleGraphicsType,'Figure','');
    rptgen.makeProp(this,'FilterByClass','bool',false,getString(message('rptgen:rh_chg_prop_table:filterByClassLabel')));
    rptgen.makeProp(this,'FilterClass','ustring','','');


    rptgen.makeStaticMethods(this,{
    },{
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getReportedObject'
    });