function schema





    pkg=findpackage('rptgen');

    h=schema.class(pkg,'summsrc',pkg.findclass('DAObject'));

    p=rptgen.prop(h,'Type','string');
    p.AccessFlags.PublicSet='off';

    pkg.findclass('propsrc');
    p=rptgen.prop(h,'PropSrc','rptgen.propsrc');
    p.AccessFlags.PublicSet='off';

    pkg.findclass('rpt_looper');
    p=rptgen.prop(h,'LoopComp','rptgen.rpt_looper');
    p.AccessFlags.Init='off';
    p.AccessFlags.AbortSet='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';
    p.GetFunction=@getLoopComp;
    p.SetFunction=@setLoopComp;

    rptgen.prop(h,'Properties','string vector',{},...
    getString(message('rptgen:r_summsrc:propertyColumnsLabel')));

    rptgen.prop(h,'ColumnHeaders','string vector',{},...
    getString(message('rptgen:r_summsrc:customHeadersLabel')));

    rptgen.prop(h,'Anchor','bool',false,...
    getString(message('rptgen:r_summsrc:insertAnchorLabel')));

    rptgen.prop(h,'FilterEmptyColumns','bool',true,...
    getString(message('rptgen:r_summsrc:removeEmptyLabel')));

    rptgen.prop(h,'isTransposeTable','bool',false,...
    getString(message('rptgen:r_summsrc:transposeLabel')));

    rptgen.prop(h,'ColumnWidths','MATLAB array',[],...
    getString(message('rptgen:r_summsrc:relativeWidthsLabel')));

    rptgen.prop(h,'DlgCurrentPropertyIdx','int32',1,'',2);

    m=find(h.Method,'Name','getDialogSchema');

    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','string'};
        s.OutputTypes={'mxArray'};
    end
