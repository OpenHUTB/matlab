function schema






    hBasePackage=findpackage('PMDialogs');
    hBaseObj=hBasePackage.findclass('PmGuiObj');
    hCreateInPackage=findpackage('NetworkEngine');


    hThisClass=schema.class(hCreateInPackage,...
    'PmNeComponentChooserPanel',hBaseObj);


    schema.prop(hThisClass,'Enabled','bool');
    schema.prop(hThisClass,'ComponentName','ustring');
    schema.prop(hThisClass,'ComponentDescription','ustring');
    schema.prop(hThisClass,'ComponentTitle','ustring');


    m=schema.method(hThisClass,'Apply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'PreApply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'Refresh');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'BrowseSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'viewSource');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'viewParameters');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool','mxArray'};
