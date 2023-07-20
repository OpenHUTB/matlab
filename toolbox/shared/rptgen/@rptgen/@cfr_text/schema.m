function schema






    pkg=findpackage('rptgen');
    h=schema.class(pkg,'cfr_text',pkg.findclass('rptcomponent'));


    pkg.findclass('cfr_paragraph');


    rptgen.prop(h,'Content','ustring','',...
    getString(message('rptgen:r_cfr_text:textToIncludeLabel')));


    rptgen.makeProp(h,'StyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_text:styleNameLabel')));


    rptgen.prop(h,'StyleName','ustring','');


    p=rptgen.prop(h,'isEmphasis','bool',false,...
    getString(message('rptgen:r_cfr_text:emphasizeLabel')));
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getIsEmphasis;
    p.SetFunction=@setIsEmphasis;
    p.Visible='off';


    rptgen.prop(h,'isItalic','bool',false,...
    getString(message('rptgen:r_cfr_text:italicLabel')));


    rptgen.prop(h,'isBold','bool',false,...
    getString(message('rptgen:r_cfr_text:boldLabel')));


    rptgen.prop(h,'isUnderline','bool',false,...
    getString(message('rptgen:r_cfr_text:underlineLabel')));


    rptgen.prop(h,'isStrikethrough','bool',false,...
    getString(message('rptgen:r_cfr_text:strikethroughLabel')));


    rptgen.prop(h,'isSuperscript','bool',false,...
    getString(message('rptgen:r_cfr_text:superscriptLabel')));


    rptgen.prop(h,'isSubscript','bool',false,...
    getString(message('rptgen:r_cfr_text:subscriptLabel')));






    p=rptgen.prop(h,'Code','bool',false,...
    getString(message('rptgen:r_cfr_text:syntaxHighlightedMCodeLabel')));
    p.Visible='off';









    m=rptgen.prop(h,'isCode','bool',false,...
    getString(message('rptgen:r_cfr_text:syntaxHighlightedMCodeLabel')));
    m.AccessFlags.AbortSet='off';
    m.AccessFlags.Copy='off';
    m.AccessFlags.Init='off';
    m.GetFunction=@getIsCode;
    m.SetFunction=@setIsCode;







    p=rptgen.prop(h,'Literal','bool',false,...
    getString(message('rptgen:r_cfr_text:preserveWhitespaceLabel')));
    p.Visible='off';









    m=rptgen.prop(h,'isLiteral','bool',false,...
    getString(message('rptgen:r_cfr_text:preserveWhitespaceLabel')));
    m.AccessFlags.AbortSet='off';
    m.AccessFlags.Copy='off';
    m.AccessFlags.Init='off';
    m.GetFunction=@getIsLiteral;
    m.SetFunction=@setIsLiteral;






    m=rptgen.prop(h,'WhiteSpace','bool',true,...
    getString(message('rptgen:r_cfr_text:preserveTextWhiteSpaceLabel')));
    m.Visible='off';








    m=rptgen.prop(h,'isWhiteSpace','bool',true,...
    getString(message('rptgen:r_cfr_text:preserveTextWhiteSpaceLabel')));
    m.AccessFlags.AbortSet='off';
    m.AccessFlags.Copy='off';
    m.AccessFlags.Init='off';
    m.GetFunction=@getIsWhiteSpace;
    m.SetFunction=@setIsWhiteSpace;


    p=rptgen.prop(h,'isBackwardCompatible','bool',false,...
    getString(message('rptgen:r_cfr_text:emphasizeLabel')));
    p.AccessFlags.Serialize='off';
    p.Visible='off';


    p=rptgen.prop(h,'ForceParagraph','bool',false,...
    getString(message('rptgen:r_cfr_text:forceToParagraphLabel')));
    p.Visible='off';


    rptgen.prop(h,'Color',rptgen.makeStringType,'auto',...
    getString(message('rptgen:r_cfr_text:colorLabel')));


    rptgen.makeProp(h,'ParaComp','rptgen.cfr_paragraph',[],'');


    rptgen.makeStaticMethods(h,{},{
'getDlgStyle'
    });

