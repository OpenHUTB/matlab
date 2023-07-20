function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'LibraryRpt',...
    pkgRG.findclass('DAObject'));

    p=schema.prop(clsH,'FileName','ustring');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';

    p=schema.prop(clsH,'PathName','ustring');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';

    p=schema.prop(clsH,'Description','ustring');

    p.AccessFlags.Reset='off';


    m=schema.method(clsH,'cbkOpen');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'cbkReport');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'cbkSimulink');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

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
    s.OutputTypes={'ustring'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};






















