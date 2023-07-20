function schema
    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SignalDlg');
    hCreateInPackage=findpackage('customwebblocksdlgs');
    this=schema.class(hCreateInPackage,'CustomWebBlock',hDeriveFromClass);


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


    m=schema.method(this,'cacheStates','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string'};
    s.OutputTypes={};


    schema.prop(this,'ScaleColors','MATLAB array');
    schema.prop(this,'ConfigurationJSON','string');
    schema.prop(this,'metadata','string');
    schema.prop(this,'CachedStates','string');
end