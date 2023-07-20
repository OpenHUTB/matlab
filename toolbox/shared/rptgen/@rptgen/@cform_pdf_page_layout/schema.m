function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_pdf_page_layout',pkgRG.findclass('cform_page_layout'));


    rptgen.prop(h,'SectionBreak',{
    'next',getString(message('rptgen:r_cform_pdf_page_layout:nextPageLabel'))
    'odd',getString(message('rptgen:r_cform_pdf_page_layout:oddPageLabel'))
    'even',getString(message('rptgen:r_cform_pdf_page_layout:evenPageLabel'))
    },'next',...
    getString(message('rptgen:r_cform_pdf_page_layout:sectionBreakLabel')));


    rptgen.makeStaticMethods(h,{},{});