function schema




    hCreateInPackage=findpackage('RTW');
    hBaseClass=findclass(hCreateInPackage,'ModelCPPClass');
    hThisClass=schema.class(hCreateInPackage,'ModelCPPArgsClass',hBaseClass);

    hThisProp=schema.prop(hThisClass,'selRow','int32');
    hThisProp.FactoryValue=0;
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'getSectionDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'upCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'downCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

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

    m=schema.method(hThisClass,'getArgName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgCategory');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgCategory');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgPosition');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int32'};

    m=schema.method(hThisClass,'setArgPosition');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','int32'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getArgQualifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'setArgQualifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','string'};
    s.OutputTypes={};

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

    m=schema.method(hThisClass,'setDefaultStepMethodName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setDefaultClassName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};
