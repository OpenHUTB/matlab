function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'csl_summ_table',pkgRG.findclass('rptsummtable'));

    rptgen.prop(this,'LoopType',rptgen_sl.enumSimulinkType,'Block',...
    getString(message('RptgenSL:rsl_csl_summ_table:objectTypeLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(this,{
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
'summ_getTypeList'
'summ_getSplitPropName'
    },{
'summ_getPropList'
'summ_getSplitPropProps'
'summ_getSplitPropTypes'
    });
