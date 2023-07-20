function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfr_paragraph',pkgRG.findclass('rptcomponent'));


    pkgRG.findclass('cfr_text');


    rptgen.makeProp(h,'TitleStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_text:styleNameLabel')));


    rptgen.prop(h,'TitleStyleName','ustring','rgParagraphTitle');


    rptgen.makeProp(h,'StyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_text:styleNameLabel')));


    rptgen.prop(h,'StyleName','ustring','rgParagraph');


    rptgen.makeProp(h,'TitleType',{
    'none',getString(message('rptgen:r_cfr_paragraph:noTitleLabel'))
    'subcomp',getString(message('rptgen:r_cfr_paragraph:takeFromFirstLabel'))
    'specify',getString(message('rptgen:r_cfr_paragraph:customTitleLabel'))
    },'none','');


    rptgen.makeProp(h,'ParaTitle','ustring',...
    getString(message('rptgen:r_cfr_paragraph:paragraphTitleLabel')),'');


    p=rptgen.makeProp(h,'ParaText','ustring','','');
    p.AccessFlags.Serialize='off';
    p.GetFunction={@getCompProp,'ParaTextComp','Content'};
    p.SetFunction={@setCompProp,'ParaTextComp','Content'};


    rptgen.makeProp(h,'ParaTextComp','rptgen.cfr_text',[],'');


    rptgen.makeStaticMethods(h,{
    },{
'doCopy'
    });
