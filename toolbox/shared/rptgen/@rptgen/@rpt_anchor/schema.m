function schema






    pkgRG=findpackage('rptgen');

    h=schema.class(pkgRG,'rpt_anchor',pkgRG.findclass('rptcomponent'));


    p=rptgen.makeProp(h,'LinkText','ustring','',...
    getString(message('rptgen:r_rpt_anchor:insertTextLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'anchor_getGenericType'
'anchor_getObject'
'anchor_getPropSrc'
    });