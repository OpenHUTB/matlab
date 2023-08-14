function schema







    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_obj_name',pkgRG.findclass('rpt_name'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'ObjectType',rptgen_sl.enumSimulinkTypeAuto,'auto',...
    getString(message('RptgenSL:rsl_csl_obj_name:objectTypeLabel')),lic);


    p=rptgen.prop(h,'isFullName','bool',false,...
    getString(message('RptgenSL:rsl_csl_obj_name:showFullPathLabel')),lic);


    rptgen.makeStaticMethods(h,{
    },{
'name_getGenericType'
'name_getName'
'name_getObject'
'name_getPropSrc'
    });

