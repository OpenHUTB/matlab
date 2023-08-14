function schema







    basePackage=findpackage('Simulink');
    baseClass=findclass(basePackage,'SLDialogSource');
    createPackage=findpackage('PMDialogs');
    cls=schema.class(createPackage,'DynDlgSource',baseClass);

    schema.prop(cls,'BuilderObj','handle');
    schema.prop(cls,'BlockHandle','double');
    schema.prop(cls,'DialogRefresh','bool');
    schema.prop(cls,'ShowRuntime','bool');

    m=schema.method(cls,'internalGetSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={'mxArray','string'};

    m=schema.method(cls,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'preApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','ustring'};

    m=schema.method(cls,'preRevertCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool'};

    m=schema.method(cls,'closeDialogCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};

    m=schema.method(cls,'internalGetPmSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(cls,'internalValidateLicense');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'string'};

    m=schema.method(cls,'makeDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'mxArray'};


