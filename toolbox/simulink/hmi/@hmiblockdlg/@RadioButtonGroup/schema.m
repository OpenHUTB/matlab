

function schema

    hDeriveFromPackage=findpackage('hmiblockdlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ParameterDlg');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'RadioButtonGroup',hDeriveFromClass);


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


    m=schema.method(this,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    schema.prop(this,'propMap','MATLAB array');
    schema.prop(this,'tableState','bool');
    schema.prop(this,'BackgroundColor','string');
    schema.prop(this,'ForegroundColor','string');
end
