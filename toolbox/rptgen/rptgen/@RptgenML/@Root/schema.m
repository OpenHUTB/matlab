function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'Root',...
    pkgRG.findclass('DAObject'));

    p=schema.prop(clsH,'Editor','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'Library','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';


    p=schema.prop(clsH,'PrevLibrary','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'ReportList','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'StylesheetLibrary','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';







    p=schema.prop(clsH,'HandleClipboard','handle');

    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'Actions','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'StatusWindow','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(clsH,'Listeners','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';











    m=schema.method(clsH,'areChildrenOrdered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(clsH,'canAcceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};









