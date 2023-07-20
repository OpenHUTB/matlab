function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_page_hdr_ftr',pkgRG.findclass('cform_base'));


    rptgen.prop(h,'PageType',{
    'default',getString(message('rptgen:r_cform_page_hdr_ftr:defaultLabel'))
    'even',getString(message('rptgen:r_cform_page_hdr_ftr:evenLabel'))
    'first',getString(message('rptgen:r_cform_page_hdr_ftr:firstLabel'))
    },'default',...
    getString(message('rptgen:r_cform_page_hdr_ftr:pageTypeLabel')));



    rptgen.makeStaticMethods(h,{},{});