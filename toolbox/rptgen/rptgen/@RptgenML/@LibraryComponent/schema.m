function schema




    mlock;

    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'LibraryComponent',...
    pkgRG.findclass('DAObject'));

    p=schema.prop(clsH,'ClassName','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';

    p=schema.prop(clsH,'DisplayName','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';



    p=schema.prop(clsH,'ComponentInstance','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Reset='off';
    p.Visible='off';

    p=schema.prop(clsH,'HelpMapFile','string');
    p.AccessFlags.Reset='off';

    p=schema.prop(clsH,'HelpMapKey','string');
    p.AccessFlags.Reset='off';

    p=schema.prop(clsH,'HelpHtmlFile','string');
    p.AccessFlags.Reset='off';


    m=schema.method(clsH,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

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

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};






















