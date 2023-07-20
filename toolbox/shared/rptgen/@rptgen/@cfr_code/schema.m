function schema






    pkg=findpackage('rptgen');
    h=schema.class(pkg,'cfr_code',pkg.findclass('rptcomponent'));


    pkg.findclass('cfr_paragraph');


    rptgen.prop(h,'Content','ustring','',...
    getString(message('rptgen:r_cfr_code:textToIncludeLabel')));


    rptgen.makeProp(h,'StyleNameType',{
    'auto',getString(message('rptgen:r_cfr_code:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_code:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_code:styleNameLabel')));



    rptgen.prop(h,'StyleName','ustring','rgCode');


    rptgen.prop(h,'isBold','bool',false,...
    getString(message('rptgen:r_cfr_code:boldLabel')));


    rptgen.prop(h,'isItalic','bool',false,...
    getString(message('rptgen:r_cfr_code:italicLabel')));


    rptgen.prop(h,'isUnderline','bool',false,...
    getString(message('rptgen:r_cfr_code:underlineLabel')));


    rptgen.prop(h,'Color',rptgen.makeStringType,'auto',...
    getString(message('rptgen:r_cfr_code:colorLabel')));


    rptgen.makeProp(h,'ParaComp','rptgen.cfr_paragraph',[],'');


    p=rptgen.prop(h,'isWhiteSpace','bool',true,...
    getString(message('rptgen:r_cfr_code:preserveTextWhiteSpaceLabel')));
    p.Visible='off';


    p=rptgen.prop(h,'ForceParagraph','bool',false,...
    getString(message('rptgen:r_cfr_text:forceToParagraphLabel')));
    p.Visible='off';


    rptgen.makeStaticMethods(h,{},{
'getDlgStyle'
    });

