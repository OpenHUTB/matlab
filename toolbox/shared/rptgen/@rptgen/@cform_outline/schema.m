function schema





    pkg=findpackage('rptgen');


    h=schema.class(pkg,'cform_outline',pkg.findclass('coutline'));


    rptgen.prop(h,'Description','ustring',getString(message('rptgen:r_cform_outline:formDescriptionDefault')),...
    getString(message('rptgen:r_coutline:reportDescriptionLabel')));


    p=rptgen.prop(h,'Key','ustring','','Key',1);
    p.Visible='off';



    p=rptgen.prop(h,'CacheTemplateInfo','MATLAB array',{},'CacheTemplateInfo',2);



    p=rptgen.prop(h,'TemplateInfo','MATLAB array',{},'TemplateInfo',1);
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getTemplateInfo;
    p.SetFunction=@setTemplateInfo;
    p.Visible='off';


    rptgen.makeStaticMethods(h,{
    },{
'getHolesInfo'
'getDocumentPartsList'
    });
