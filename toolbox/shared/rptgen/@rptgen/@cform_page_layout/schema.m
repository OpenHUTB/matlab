function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_page_layout',pkgRG.findclass('cform_component'));


    rptgen.prop(h,'FirstPageNumType',{
    'auto',getString(message('rptgen:r_cform_page_layout:autoLabel'))
    'specify',getString(message('rptgen:r_cform_page_layout:specifyLabel'))
    },'auto',...
    getString(message('rptgen:r_cform_page_layout:firstPageNumLabel')));


    rptgen.prop(h,'FirstPageNum','int32',1,'');


    rptgen.prop(h,'PageNumFormat',{
    'none',getString(message('rptgen:r_cform_page_layout:noneLabel'))
    'a',getString(message('rptgen:r_cform_page_layout:lowerAlphaLabel'))
    'upAlpha',getString(message('rptgen:r_cform_page_layout:upperAlphaLabel'))
    'i',getString(message('rptgen:r_cform_page_layout:lowerRomanNumLabel'))
    'upRoman',getString(message('rptgen:r_cform_page_layout:upperRomanNumLabel'))
    'n',getString(message('rptgen:r_cform_page_layout:arabicNumLabel'))
    },'none',...
    getString(message('rptgen:r_cform_page_layout:pageNumFormatLabel')));


    rptgen.prop(h,'SectionBreak',{
    'next',getString(message('rptgen:r_cform_page_layout:nextPageLabel'))
    'same',getString(message('rptgen:r_cform_page_layout:samePageLabel'))
    'odd',getString(message('rptgen:r_cform_page_layout:oddPageLabel'))
    'even',getString(message('rptgen:r_cform_page_layout:evenPageLabel'))
    },'next',...
    getString(message('rptgen:r_cform_page_layout:sectionBreakLabel')));


    rptgen.prop(h,'PageMargin',{
    'auto',getString(message('rptgen:r_cform_page_layout:autoLabel'))
    'specify',getString(message('rptgen:r_cform_page_layout:specifyLabel'))
    },'auto',...
    getString(message('rptgen:r_cform_page_layout:pageMarginLabel')));


    rptgen.prop(h,'TopMargin','ustring','1in',getString(message('rptgen:r_cform_page_layout:topLabel')));


    rptgen.prop(h,'BottomMargin','ustring','1in',getString(message('rptgen:r_cform_page_layout:bottomLabel')));


    rptgen.prop(h,'LeftMargin','ustring','1in',getString(message('rptgen:r_cform_page_layout:leftLabel')));


    rptgen.prop(h,'RightMargin','ustring','1in',getString(message('rptgen:r_cform_page_layout:rightLabel')));


    rptgen.prop(h,'HeaderMargin','ustring','0.5in',getString(message('rptgen:r_cform_page_layout:headerLabel')));


    rptgen.prop(h,'FooterMargin','ustring','0.5in',getString(message('rptgen:r_cform_page_layout:footerLabel')));


    rptgen.prop(h,'GutterMargin','ustring','0px',getString(message('rptgen:r_cform_page_layout:gutterLabel')));


    rptgen.prop(h,'PageSize',{
    'auto',getString(message('rptgen:r_cform_page_layout:autoLabel'))
    'specify',getString(message('rptgen:r_cform_page_layout:specifyLabel'))
    },'auto',...
    getString(message('rptgen:r_cform_page_layout:pageSizeLabel')));


    rptgen.prop(h,'Height','ustring','11in',getString(message('rptgen:r_cform_page_layout:heightLabel')));


    rptgen.prop(h,'Width','ustring','8.5in',getString(message('rptgen:r_cform_page_layout:widthLabel')));


    rptgen.prop(h,'Orientation',{
    'portrait',getString(message('rptgen:r_cform_page_layout:portraitLabel'))
    'landscape',getString(message('rptgen:r_cform_page_layout:landscapeLabel'))
    },'portrait',...
    getString(message('rptgen:r_cform_page_layout:orientationLabel')));


    rptgen.prop(h,'FileName','ustring','',...
    getString(message('rptgen:r_cform_page_layout:filenameLabel')),1);


    rptgen.prop(h,'Scale',{
    'auto',getString(message('rptgen:r_cform_page_layout:autoLabel'))
    'specify',getString(message('rptgen:r_cform_page_layout:specifyLabel'))
    },'auto',...
    getString(message('rptgen:r_cform_page_layout:scalingLabel')));


    rptgen.prop(h,'ImageHeight','ustring','',getString(message('rptgen:r_cform_page_layout:heightLabel')));


    rptgen.prop(h,'ImageWidth','ustring','',getString(message('rptgen:r_cform_page_layout:widthLabel')));



    rptgen.makeStaticMethods(h,{},{});
