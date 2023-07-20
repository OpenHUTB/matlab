function schema





    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_titlepage',pkgRG.findclass('rptcomponent'));


    pkgRG.findclass('cfr_text');
    pkgRG.findclass('cfr_image');


    rptgen.makeProp(h,'Title','ustring','',getString(message('rptgen:r_cfr_titlepage:titleLabel')));


    rptgen.makeProp(h,'Subtitle','ustring','',getString(message('rptgen:r_cfr_titlepage:subtitleLabel')),1);


    rptgen.makeProp(h,'AuthorMode',{
    'none',getString(message('rptgen:r_cfr_titlepage:noAuthorLabel'))
    'auto',getString(message('rptgen:r_cfr_titlepage:autoAuthorLabel'))
    'manual',getString(message('rptgen:r_cfr_titlepage:customAuthorLabel'))
    },'manual','');


    rptgen.makeProp(h,'Author','ustring',getenv('USER'));



    rptgen.makeProp(h,'Include_Date','bool',true,...
    getString(message('rptgen:r_cfr_titlepage:includeCreationLabel')));


    rptgen.makeProp(h,'DateFormat','ustring','dd-mmm-yyyy HH:MM:SS','');


    rptgen.makeProp(h,'Include_Copyright','bool',false,...
    getString(message('rptgen:r_cfr_titlepage:includeCopyrightLabel')));


    rptgen.makeProp(h,'Copyright_Holder','ustring','');



    rptgen.makeProp(h,'Copyright_Date','ustring','');


    p=rptgen.makeProp(h,'Image','RGComponentOrParsedString','',...
    getString(message('rptgen:r_cfr_titlepage:imageSourceLabel')));
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getImage;
    p.SetFunction=@setImage;


    rptgen.makeProp(h,'ImageComp','rptgen.rpt_graphic',[],'');


    p=rptgen.makeProp(h,'Abstract','ustring','',...
    getString(message('rptgen:r_cfr_titlepage:abstractLabel')));
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction={@getCompProp,'AbstractComp','Content'};
    p.SetFunction={@setCompProp,'AbstractComp','Content'};


    rptgen.makeProp(h,'AbstractComp','rptgen.cfr_text',[],'');


    p=rptgen.makeProp(h,'Legal_Notice','ustring','',...
    getString(message('rptgen:r_cfr_titlepage:legalNoticeLabel')));
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction={@getCompProp,'LegalNoticeComp','Content'};
    p.SetFunction={@setCompProp,'LegalNoticeComp','Content'};


    rptgen.makeProp(h,'LegalNoticeComp','rptgen.cfr_text',[],'');


    rptgen.prop(h,'DoSinglePage','bool',false,...
    getString(message('rptgen:r_cfr_titlepage:doSinglePageLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'doCopy'
    });
