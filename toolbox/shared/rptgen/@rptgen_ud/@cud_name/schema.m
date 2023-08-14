function schema






    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgUD,'cud_name',pkgRG.findclass('rpt_name'));

    p=rptgen.makeProp(h,'UddType',rptgen_ud.enumObjectTypeAuto,'auto',...
    getString(message('rptgen:ru_cud_name:typeLabel')));





    rptgen.makeStaticMethods(h,{
    },{
'name_getGenericType'
'name_getObject'
'name_getPropSrc'
    });