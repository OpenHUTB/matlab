function schema






    pkgSF=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgSF,'csf_obj_anchor',pkgRG.findclass('rpt_anchor'));


    rptgen.makeStaticMethods(h,{
    },{
'anchor_getObject'
'anchor_getPropSrc'
    });