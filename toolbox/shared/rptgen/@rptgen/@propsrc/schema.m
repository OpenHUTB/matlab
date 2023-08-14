function schema





    mlock;

    pkg=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'propsrc',...
    pkg.findclass('DAObject'));

    p=rptgen.prop(clsH,'DlgFilter','ustring');
    p.AccessFlags.Serialize='off';


    p.Visible='off';

    p=rptgen.prop(clsH,'DlgProperty','ustring');
    p.AccessFlags.Serialize='off';


    p.Visible='off';













    m=find(clsH.Method,'Name','getDialogSchema');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','ustring'};
        s.OutputTypes={'mxArray'};
    end

    m=schema.method(clsH,'dlgSelectAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','ustring'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgAddAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','handle','ustring'};
    s.OutputTypes={};

