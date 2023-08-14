function schema




    pkgRG=findpackage('rptgen');
    clsH=schema.class(pkgRG,'rpt_prop_table',pkgRG.findclass('rptcomponent'));

    pkgRG.findclass('rpt_prop_cell');


    p=rptgen.prop(clsH,'TableTitle','rptgen.rpt_prop_cell');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getTableTitle;
    p.SetFunction=@setTableTitle;

    rptgen.prop(clsH,'isBorder','bool',true,...
    getString(message('rptgen:r_rpt_prop_table:displayOuterBorderLabel')));

    rptgen.prop(clsH,'isPageWide','bool',true,...
    getString(message('rptgen:r_rpt_prop_table:pageWideLabel')));

    rptgen.prop(clsH,'SingleValueMode','bool',false,...
    getString(message('rptgen:r_rpt_prop_table:splitPropertyCellsLabel')));

    rptgen.prop(clsH,'ColWidths','MATLAB array',[],...
    getString(message('rptgen:r_rpt_prop_table:columnWidthsLabel')));

    p=rptgen.prop(clsH,'TableContent','rptgen.rpt_prop_cell vector');
    p.AccessFlags.Init='off';


    p.AccessFlags.Copy='off';
    p.SetFunction=@setTableContent;

    rptgen.prop(clsH,'DlgCellIndex',...
    'mxArray',...
    0,'',2);






    m=schema.method(clsH,'dlgApplyPresetTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    rptgen.makeStaticMethods(clsH,{
    },{
'addCell'
'orderCells'
'init'
'doCopy'
'dlgEditor'
'dlgSelectCell'
'applyPresetTable'
'dlgApplyPresetTable'
'pt_applyPresetTable'
'pt_getObjectName'
'pt_getPresetTableList'
'pt_getPropertySource'
'pt_getReportedObject'
'setTableStrings'
'v1convert_table'
'mcodeConstructor'
'mergeCells'
'canMergeCells'
'splitCells'
'canSplitCells'
'getCurrentCell'
'setCurrentCell'
'getTableDims'
'changeLayout'
'canChangeLayout'
    });

