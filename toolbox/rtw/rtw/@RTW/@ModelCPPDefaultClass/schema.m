function schema




    hCreateInPackage=findpackage('RTW');
    hBaseClass=findclass(hCreateInPackage,'ModelCPPClass');
    hThisClass=schema.class(hCreateInPackage,'ModelCPPDefaultClass',hBaseClass);


    m=schema.method(hThisClass,'getSectionDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'codeConstruction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'runValidation');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'getPortDefaultConf');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double','int32','int32'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getNumArgs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'int32'};

    m=schema.method(hThisClass,'getPreview');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'needsCompilation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

