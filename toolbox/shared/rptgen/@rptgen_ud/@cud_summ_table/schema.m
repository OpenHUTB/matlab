function schema






    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkgUD,'cud_summ_table',pkgRG.findclass('rptsummtable'));

    rptgen.prop(this,'LoopType',rptgen_ud.enumObjectType,'Class',getString(message('rptgen:ru_cud_summ_table:typeLabel')));


    rptgen.makeStaticMethods(this,{
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
'summ_getTypeList'
'summ_getSplitPropName'
    },{
'summ_getPropList'
    });
