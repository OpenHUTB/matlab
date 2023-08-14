function schema
    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ParameterDlg');
    hCreateInPackage=findpackage('customwebblocksdlgs');
    this=schema.class(hCreateInPackage,'CustomTuningWebBlock',hDeriveFromClass);


    m=schema.method(this,'getProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','bool','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'setProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','string','bool','bool'};
    s.OutputTypes={};


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};


    m=schema.method(this,'rejectUpdateConfiguration','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={};


    m=schema.method(this,'resetValuePreview','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string'};
    s.OutputTypes={};


    schema.prop(this,'ConfigurationJSON','string');
    schema.prop(this,'metadata','string');
    schema.prop(this,'editingFcn','int');
    schema.prop(this,'propMap','MATLAB array');
    schema.prop(this,'tableState','bool');
end