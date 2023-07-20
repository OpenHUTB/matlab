function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'rpt_list',pkgRG.findclass('rptcomponent'));


    rptgen.makeProp(h,'ListTitle','ustring','',...
    getString(message('rptgen:r_rpt_list:listTitleLabel')));


    rptgen.makeProp(h,'ListStyle',{
    'itemizedlist',getString(message('rptgen:r_rpt_list:bulletedListLabel'))
    'orderedlist',getString(message('rptgen:r_rpt_list:numberedListLabel'))
    },'itemizedlist',...
    getString(message('rptgen:r_rpt_list:listTypeLabel')));


    p=rptgen.makeProp(h,'Spacing',{
    'compact',getString(message('rptgen:r_rpt_list:compactLabel'))
    'normal',getString(message('rptgen:r_rpt_list:normalLabel'))
    },'compact',...
    getString(message('rptgen:r_rpt_list:listSpacingLabel')));
    p.Visible='off';


    rptgen.makeProp(h,'NumerationType',{
    'arabic','1,2,3,4,...'
    'loweralpha','a,b,c,d,...'
    'upperalpha','A,B,C,D,...'
    'lowerroman','i,ii,iii,iv,...'
    'upperroman','I,II,III,IV,...'
    },'arabic',...
    getString(message('rptgen:r_rpt_list:numberingStyle')));


    rptgen.makeProp(h,'NumInherit',{
    'inherit',getString(message('rptgen:r_rpt_list:showParentLabel'))
    'ignore',getString(message('rptgen:r_rpt_list:onlyShowCurrent'))
    },'ignore','');


    p=rptgen.makeProp(h,'NumContinue',{
    'continues',getString(message('rptgen:r_rpt_list:continueNumberingLabel'))
    'restarts',getString(message('rptgen:r_rpt_list:startAtOneLabel'))
    },'restarts','');
    p.Visible='off';



    label=getString(message('rptgen:r_rpt_list:listStyleNameLabel'));
    rptgen.makeProp(h,'ListStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);


    rptgen.prop(h,'ListStyleName','ustring','');



    label=getString(message('rptgen:r_rpt_list:listTitleStyleNameLabel'));
    rptgen.makeProp(h,'TitleStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);


    rptgen.prop(h,'TitleStyleName','ustring','');


    rptgen.makeStaticMethods(h,{
    },{
'list_getDialogSchema'
'list_getContent'
'list_getTitle'
    });
