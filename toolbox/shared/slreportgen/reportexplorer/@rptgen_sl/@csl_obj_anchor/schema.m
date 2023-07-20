function schema






    pkgSL=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgSL,'csl_obj_anchor',pkgRG.findclass('rpt_anchor'));


    p=rptgen.prop(h,'ObjectType',rptgen_sl.enumSimulinkTypeAuto,'auto',...
    getString(message('RptgenSL:rsl_csl_obj_anchor:linkFromCurrentLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
'anchor_getGenericType'
'anchor_getObject'
'anchor_getPropSrc'
    });
