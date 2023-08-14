function schema







    pkgSF=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgSF,'csf_obj_name',pkgRG.findclass('rpt_name'));

    p=rptgen.prop(h,'NameType',{
    'name',getString(message('RptgenSL:rsf_csf_obj_name:objectNameLabel'))
    'sfname',getString(message('RptgenSL:rsf_csf_obj_name:objectNameWithSFPathLabel'))
    'slsfname',getString(message('RptgenSL:rsf_csf_obj_name:objectNameWithSLSFPathLabel'))
    },'name',getString(message('RptgenSL:rsf_csf_obj_name:displayNameAsLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
'name_getName'
'name_getObject'
'name_getPropSrc'
    });