function schema







    pkgSF=findpackage('rptgen_sf');
    pkgDV=findpackage('RptSldv');

    h=schema.class(pkgDV,'SfObjName',pkgSF.findclass('csf_obj_name'));


    rptgen.makeStaticMethods(h,{
    },{
'name_getName'
    });