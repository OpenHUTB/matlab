function schema






    pkg=findpackage('rptgen');
    h=schema.class(pkg,'cfr_preformatted',pkg.findclass('rptcomponent'));


    rptgen.prop(h,'Content','ustring','',...
    getString(message('rptgen:r_cfr_preformatted:PreformattedToIncludeLabel')));



    rptgen.makeProp(h,'StyleNameType',{
    'auto',getString(message('rptgen:r_cfr_code:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_code:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_code:styleNameLabel')));


    rptgen.prop(h,'StyleName','ustring','rgProgramListing');


    rptgen.prop(h,'isItalic','bool',false,...
    getString(message('rptgen:r_cfr_code:italicLabel')));


    rptgen.prop(h,'isBold','bool',false,...
    getString(message('rptgen:r_cfr_code:boldLabel')));


    p=rptgen.prop(h,'Code','bool',false,...
    getString(message('rptgen:r_cfr_code:syntaxHighlightedMCodeLabel')));
    p.Visible='off';







    m=rptgen.prop(h,'isCode','bool',false,...
    getString(message('rptgen:r_cfr_code:syntaxHighlightedMCodeLabel')));
    m.AccessFlags.AbortSet='off';
    m.AccessFlags.Copy='off';
    m.AccessFlags.Init='off';
    m.GetFunction=@getIsCode;
    m.SetFunction=@setIsCode;


    rptgen.prop(h,'Color',rptgen.makeStringType,'auto',...
    getString(message('rptgen:r_cfr_code:colorLabel')));


    rptgen.makeStaticMethods(h,{},{
'getDlgStyle'
    });

