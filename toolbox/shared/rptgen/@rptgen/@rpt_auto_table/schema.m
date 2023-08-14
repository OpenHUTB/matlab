function schema






    pkgRG=findpackage('rptgen');

    h=schema.class(pkgRG,'rpt_auto_table',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('rptgen:r_rpt_auto_table:noTitleLabel'))
    'name',getString(message('rptgen:r_rpt_auto_table:nameLabel'))
    'manual',[getString(message('rptgen:r_rpt_auto_table:customLabel')),':']
    },'name',getString(message('rptgen:r_rpt_auto_table:tableTitleLabel')));


    p=rptgen.prop(h,'Title','ustring',getString(message('rptgen:r_rpt_auto_table:titleLabel')),...
    '');


    p=rptgen.prop(h,'HeaderType',{
    'none',getString(message('rptgen:r_rpt_auto_table:noHeaderLabel'))
    'typename',getString(message('rptgen:r_rpt_auto_table:typenameLabel'))
    'manual',[getString(message('rptgen:r_rpt_auto_table:customLabel')),':']
    },'none',getString(message('rptgen:r_rpt_auto_table:headerRowLabel')));

    p=rptgen.prop(h,'HeaderColumn1','ustring',getString(message('rptgen:r_rpt_auto_table:nameLabel')),'');
    p=rptgen.prop(h,'HeaderColumn2','ustring',getString(message('rptgen:r_rpt_auto_table:valueLabel')),'');


    p=rptgen.prop(h,'RemoveEmpty','bool',true,...
    getString(message('rptgen:r_rpt_auto_table:noEmptyValuesLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'atGetDialogSchema'
'atGetName'
'atGetObjects'
'atGetPropertyList'
'atGetPropertySource'
'atGetPropertyValue'
'atGetType'
'atIgnoreValue'
'atMakeAutoTable'
    });
