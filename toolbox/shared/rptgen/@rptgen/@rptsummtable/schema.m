function schema




    pkgRG=findpackage('rptgen');
    h=schema.class(pkgRG,'rptsummtable',pkgRG.findclass('rptcomponent'));

    p=rptgen.prop(h,'LoopType','ustring','',...
    getString(message('rptgen:r_rptsummtable:objectTypeLabel')));
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.GetFunction=@getLoopType;
    p.SetFunction=@setLoopType;

    rptgen.prop(h,'TitleType',{
    'auto',getString(message('rptgen:r_rptsummtable:autoLabel'))
    'manual',[getString(message('rptgen:r_rptsummtable:customLabel')),':']
    },'auto',getString(message('rptgen:r_rptsummtable:tableTitleLabel')));

    rptgen.prop(h,'TableTitle','ustring','Summary');

    pkgRG.findclass('summsrc');
    p=rptgen.prop(h,'TypeInfo','rptgen.summsrc vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Init='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.SetFunction=@setTypeInfo;
    p.GetFunction=@getTypeInfo;
    p.Visible='off';


    p=rptgen.prop(h,'LoopComp','handle');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getLoopComp;
    p.SetFunction=@setLoopComp;


    p=rptgen.prop(h,'Properties','string vector');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getProperties;
    p.SetFunction=@setProperties;


    p=rptgen.prop(h,'Anchor','bool');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getAnchor;
    p.SetFunction=@setAnchor;


    p=rptgen.prop(h,'ColumnWidths','MATLAB array');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getColumnWidths;
    p.SetFunction=@setColumnWidths;


    p=rptgen.prop(h,'ColumnHeaders','string vector');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getColumnHeaders;
    p.SetFunction=@setColumnHeaders;


    p=rptgen.prop(h,'FilterEmptyColumns','bool');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getFilterEmptyColumns;
    p.SetFunction=@setFilterEmptyColumns;


    p=rptgen.prop(h,'isTransposeTable','bool');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getTransposeTable;
    p.SetFunction=@setTransposeTable;


    rptgen.makeStaticMethods(h,{
'makeSummTable'
'summ_getDefaultType'
'summ_getDefaultTypeInfo'
'summ_getSplitPropName'
'summ_getTypeList'
    },{
'getLoopObjects'
'summ_get'
'summ_getPropList'
'summ_getPropName'
'summ_getSplitProps'
'summ_getSplitPropTypes'
'summ_getSplitPropList'
'summ_getSplitPropProps'
'summ_set'
'mcodeConstructor'
    });
