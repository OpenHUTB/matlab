function schema






    pkgFP=findpackage('rptgen_fp');
    pkgSL=findpackage('rptgen_sl');
    this=schema.class(pkgFP,'cfp_summ_table',pkgSL.findclass('csl_summ_table'));

    rptgen.prop(this,'LoopType',{'fixed-point block','fixed-point block'},'fixed-point block',...
    getString(message('rptgen:fp_cfp_summ_table:objectType')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(this,{
'summ_getTypeList'
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
    },{
    });