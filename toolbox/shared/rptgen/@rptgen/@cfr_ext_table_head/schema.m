function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table_head',pkgRG.findclass('cfr_ext_table_section'));


    rptgen.makeStaticMethods(h,{
    },{
    });



    rptgen.makeProp(h,'StyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_text:styleNameLabel')));


    rptgen.prop(h,'StyleName','ustring','');
