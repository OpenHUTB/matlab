function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_subform',pkgRG.findclass('cform_base'));


    rptgen.makeStaticMethods(h,{},{});
