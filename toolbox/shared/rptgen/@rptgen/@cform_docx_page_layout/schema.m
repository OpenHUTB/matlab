function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_docx_page_layout',pkgRG.findclass('cform_page_layout'));


    rptgen.prop(h,'PageNumFormat',{
    'none',getString(message('rptgen:r_cform_docx_page_layout:noneLabel'))
    'a',getString(message('rptgen:r_cform_docx_page_layout:lowerAlphaLabel'))
    'upAlpha',getString(message('rptgen:r_cform_docx_page_layout:upperAlphaLabel'))
    'i',getString(message('rptgen:r_cform_docx_page_layout:lowerRomanNumLabel'))
    'upRoman',getString(message('rptgen:r_cform_docx_page_layout:upperRomanNumLabel'))
    'n',getString(message('rptgen:r_cform_docx_page_layout:arabicNumLabel'))
    'numberInDash',getString(message('rptgen:r_cform_docx_page_layout:numberInDashLabel'))
    'hebrew1',getString(message('rptgen:r_cform_docx_page_layout:hebrew1Label'))
    'hebrew2',getString(message('rptgen:r_cform_docx_page_layout:hebrew2Label'))
    'arabicAlpha',getString(message('rptgen:r_cform_docx_page_layout:arabicAlphaLabel'))
    'arabicAbjad',getString(message('rptgen:r_cform_docx_page_layout:arabicAbjadLabel'))
    'thaiLetters',getString(message('rptgen:r_cform_docx_page_layout:thaiLettersLabel'))
    'thaiNumbers',getString(message('rptgen:r_cform_docx_page_layout:thaiNumbersLabel'))
    'thaiCounting',getString(message('rptgen:r_cform_docx_page_layout:thaiCountingLabel'))
    },'none',...
    getString(message('rptgen:r_cform_docx_page_layout:pageNumFormatLabel')));


    rptgen.makeStaticMethods(h,{},{});