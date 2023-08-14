function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_base',pkgRG.findclass('cform_component'));


    rptgen.prop(h,'TemplateType',{
    'library',getString(message('rptgen:r_cform_base:libraryLabel'))
    'file',getString(message('rptgen:r_cform_base:fileLabel'))
    'pageLayout',getString(message('rptgen:r_cform_base:pageLayoutLabel'))
    },'library',...
    getString(message('rptgen:r_cform_base:templateTypeLabel')));


    p=rptgen.prop(h,'TemplateTypeUI',{
    'library',getString(message('rptgen:r_cform_base:libraryLabel'))
    'file',getString(message('rptgen:r_cform_base:fileLabel'))
    'pageLayout',getString(message('rptgen:r_cform_base:pageLayoutLabel'))
    },'library',...
    getString(message('rptgen:r_cform_base:templateTypeLabel')));
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@setTemplateTypeUI;
    p.GetFunction=@getTemplateTypeUI;
    p.Visible='off';


    rptgen.prop(h,'Template','ustring','',...
    getString(message('rptgen:r_cform_base:templateLabel')));


    p=rptgen.prop(h,'TemplateUI','ustring','',...
    getString(message('rptgen:r_cform_base:templateLabel')));
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@setTemplateUI;
    p.GetFunction=@getTemplateUI;
    p.Visible='off';


    rptgen.prop(h,'TemplateSource',{
    'reportForm',getString(message('rptgen:r_cform_base:reportForm'))
    'parentSubform',getString(message('rptgen:r_cform_base:parentSubform'))
    'other',getString(message('rptgen:r_cform_base:other'))
    },'reportForm',getString(message('rptgen:r_cform_base:templateSourceLabel')));


    p=rptgen.prop(h,'TemplateSourceUI',{
    'reportForm',getString(message('rptgen:r_cform_base:reportForm'))
    'parentSubform',getString(message('rptgen:r_cform_base:parentSubform'))
    'other',getString(message('rptgen:r_cform_base:other'))
    },'reportForm',getString(message('rptgen:r_cform_base:templateSourceLabel')));
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@setTemplateSourceUI;
    p.GetFunction=@getTemplateSourceUI;
    p.Visible='off';


    p=rptgen.prop(h,'DocPartTemplateName','ustring','',...
    getString(message('rptgen:r_cform_base:docPartTemplateNameLabel')));



    p=rptgen.prop(h,'TemplateNameUI','ustring','',...
    getString(message('rptgen:r_cform_base:docPartTemplateNameLabel')),1);
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@setTemplateNameUI;
    p.GetFunction=@getTemplateNameUI;
    p.Visible='off';


    p=rptgen.prop(h,'CacheTemplateInfo','MATLAB array',{},'TemplateInfo',2);



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
'getDocumentPartsList'
'getHolesInfo'
'getStylesheet'
    });