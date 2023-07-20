function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'chg_summ_table',pkgRG.findclass('rptsummtable'));

    rptgen.prop(this,'LoopType',rptgen_hg.enumHandleGraphicsType,'Figure',getString(message('rptgen:rh_chg_summ_table:objectTypeLabel')));


    rptgen.makeStaticMethods(this,{
'summ_getTypeList'
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
    },{
    });