function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_template_hole',pkgRG.findclass('cform_component'));


    p=rptgen.prop(h,'HoleID','ustring','',...
    getString(message('rptgen:r_cform_template_hole:holeIdentifierLabel')));
    p.AccessFlags.AbortSet='on';
    p.SetFunction=@setHoleID;


    rptgen.prop(h,'HoleType','ustring','',...
    getString(message('rptgen:r_cform_template_hole:holeTypeLabel')));


    rptgen.prop(h,'HoleDesc','ustring','',...
    getString(message('rptgen:r_cform_template_hole:holeDescLabel')));


    rptgen.prop(h,'DefaultStyleName','ustring','',...
    getString(message('rptgen:r_cform_template_hole:defStyleNameLabel')));


    rptgen.makeStaticMethods(h,{},{...
'getLayoutInfo'
    });