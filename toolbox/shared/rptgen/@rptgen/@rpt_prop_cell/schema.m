function schema




    pkgRG=findpackage('rptgen');
    h=schema.class(pkgRG,'rpt_prop_cell',...
    pkgRG.findclass('DAObject'));

    rptgen.prop(h,'Align',rptgen.enumTableHorizAlign,'center',...
    getString(message('rptgen:r_rpt_prop_cell:alignmentLabel')));

    rptgen.prop(h,'BorderLower','bool',true,...
    getString(message('rptgen:r_rpt_prop_cell:lowerBorderLabel')));
    rptgen.prop(h,'BorderRight','bool',true,...
    getString(message('rptgen:r_rpt_prop_cell:rightBorderLabel')));

    rptgen.prop(h,'Text','ustring','',...
    getString(message('rptgen:r_rpt_prop_cell:contentsLabel')));

    rptgen.prop(h,'Render',{
    'v','Value'
    'p v','Property Value'
    'N v','PROPERTY Value'
    'p:v','Property: Value'
    'N:v','PROPERTY: Value'
    'p-v','Property - Value'
    'N-v','PROPERTY - Value'
    },'p v',getString(message('rptgen:r_rpt_prop_cell:showAsLabel')));



    rptgen.prop(h,'ColSpan','int32',1);
    rptgen.prop(h,'RowSpan','int32',1);
    rptgen.prop(h,'SpanOrigin','handle',[]);


    p=rptgen.prop(h,'TitleMode','bool',false);


    p.Visible='off';

    m=find(h.Method,'Name','getDialogSchema');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','string'};
        s.OutputTypes={'mxArray'};
    end
