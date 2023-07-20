function schema




    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'rpt_section',pkgRG.findclass('rptcomponent'));


    rptgen.makeStaticMethods(h,{
'getParentSectionType'
    },{
'addTitle'
'closeSection'
'getChunkFileName'
'getSectionFileName'
'getSectionType'
'makeSection'
'writeChildren'
'writeComment'
'writeProcessingInstruction'
'writeXmlHeader'
    });


    rptgen.prop(h,'SectionType',{
    'book',getString(message('rptgen:r_rpt_section:bookLabel'))
    'chapter',getString(message('rptgen:r_rpt_section:chapterLabel'))
    'sect1',getString(message('rptgen:r_rpt_section:sectionOneLabel'))
    'sect2',getString(message('rptgen:r_rpt_section:sectionTwoLabel'))
    'sect3',getString(message('rptgen:r_rpt_section:sectionThreeLabel'))
    'sect4',getString(message('rptgen:r_rpt_section:sectionFourLabel'))
    'sect5',getString(message('rptgen:r_rpt_section:sectionFiveLabel'))
    'simplesect',getString(message('rptgen:r_rpt_section:simpleSectionLabel'))
    'auto',getString(message('rptgen:r_rpt_section:autoLabel'))
    },'auto',...
    'SectionType');

    rptgen.prop(h,'RuntimeSectionType','ustring','','Section type (runtime)',2);



    rptgen.prop(h,'RuntimeSerializer','MATLAB array',[],'',2);
    rptgen.prop(h,'RuntimeRelativeFileName','ustring','','',2);
    rptgen.prop(h,'RuntimeSectionIndex','int32',0,'',2);




