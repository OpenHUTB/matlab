function schema






    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgUD,'cud_anchor',pkgRG.findclass('rpt_anchor'));


    p=rptgen.makeProp(h,'UddType',rptgen_ud.enumObjectTypeAuto,'auto',...
    getString(message('rptgen:ru_cud_anchor:typeLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'anchor_getGenericType'
'anchor_getObject'
'anchor_getPropSrc'
    });