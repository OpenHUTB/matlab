function schema









    pkgHG=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgHG,'chg_obj_name',pkgRG.findclass('rpt_name'));


    p=rptgen.makeProp(h,'ObjType',{
    'Figure',getString(message('rptgen:rh_chg_obj_name:figureLabel'))
    'Axes',getString(message('rptgen:rh_chg_obj_name:axesLabel'))
    'Object',getString(message('rptgen:rh_chg_obj_name:otherObjectLabel'))
    },'Figure',getString(message('rptgen:rh_chg_obj_name:showCurrentLabel')));



    rptgen.makeStaticMethods(h,{
    },{
'name_getGenericType'
'name_getObject'
'name_getPropSrc'
    });
