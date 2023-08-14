


function schema
    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SignalDlg');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'MultiStateImageBlock',hDeriveFromClass);


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


    m=schema.method(this,'getMultiStateImageProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'setMultiStateImageProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','string','bool','bool'};
    s.OutputTypes={};


    schema.prop(this,'States','MATLAB array');
    schema.prop(this,'DefaultImage','MATLAB array');
end
