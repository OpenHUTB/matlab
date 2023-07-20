function schema






    pkg=findpackage('RptgenRMI');
    pkgRG=findpackage('rptgen_sl');
    this=schema.class(pkg,'CSummaryTable',pkgRG.findclass('csl_summ_table'));

    rptgen.prop(this,'LoopType',RptgenRMI.enumRMIType,'Block',getString(message('Slvnv:RptgenRMI:SummTable:schema:xlate_ObjectType')));


    rptgen.makeStaticMethods(this,{
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
'summ_getTypeList'
    },{
    });
