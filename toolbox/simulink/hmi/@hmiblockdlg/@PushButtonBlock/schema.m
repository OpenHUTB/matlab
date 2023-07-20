



function schema
    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ParameterDlg');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'PushButtonBlock',hDeriveFromClass);


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


    schema.prop(this,'BackgroundColor','string');
    schema.prop(this,'ForegroundColor','string');
    schema.prop(this,'IconOnColor','MATLAB array');
    schema.prop(this,'IconOffColor','MATLAB array');
    schema.prop(this,'Icon','string');
    schema.prop(this,'CustomIcon','string');
    schema.prop(this,'ApplyCustom','bool');
    schema.prop(this,'InitialCustom','bool');
end
