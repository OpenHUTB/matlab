function schema





    pkgHG=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgHG,'chg_obj_anchor',pkgRG.findclass('rpt_anchor'));



    rptgen.makeProp(h,'ObjectType',{
    'Automatic',getString(message('rptgen:rh_chg_obj_anchor:objTypeAutomatic'))
    'Figure',getString(message('rptgen:rh_chg_obj_anchor:objTypeFigure'))
    'Axes',getString(message('rptgen:rh_chg_obj_anchor:objTypeAxes'))
    'Object',getString(message('rptgen:rh_chg_obj_anchor:objTypeObject'))
    },'Automatic',getString(message('rptgen:rh_chg_obj_anchor:useCurrentLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'anchor_getGenericType'
'anchor_getObject'
'anchor_getPropSrc'
    });
