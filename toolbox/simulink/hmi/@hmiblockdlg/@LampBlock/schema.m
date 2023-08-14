

function schema

    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SignalDlg');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'LampBlock',hDeriveFromClass);


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


    m=schema.method(this,'getLampProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'setLampProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','string','bool','bool'};
    s.OutputTypes={};


    m=schema.method(this,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    schema.prop(this,'StateColors','MATLAB array');
    schema.prop(this,'States','MATLAB array');
    schema.prop(this,'Icon','string');
    schema.prop(this,'CustomIcon','string');

    schema.prop(this,'ApplyCustom','bool');
    schema.prop(this,'DisableApplyColorSlimDialog','bool');
    schema.prop(this,'InitialCustom','bool');
    schema.prop(this,'DefaultColor','MATLAB array');
    schema.prop(this,'ApplyColorChange','MATLAB array');
end
