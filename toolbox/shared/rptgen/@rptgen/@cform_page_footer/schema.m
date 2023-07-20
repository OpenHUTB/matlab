function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_page_footer',pkgRG.findclass('cform_page_hdr_ftr'));



    rptgen.makeStaticMethods(h,{},{});