function schema


    hSuperPackage=findpackage('Simulink');
    hSuperClass=findclass(hSuperPackage,'SLDialogSource');
    hPackage=findpackage('eda');
    this=schema.class(hPackage,'FILSfunctionDialogT',hSuperClass);

    schema.prop(this,'block','mxArray');
    schema.prop(this,'root','mxArray');
    schema.prop(this,'params','mxArray');
    schema.prop(this,'buildInfo','mxArray');
    schema.prop(this,'dialogState','mxArray');


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'preApplyMethod');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};
    m.Signature.OutputTypes={'bool','string'};

    m=schema.method(this,'onWidgetChange');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','string','mxArray'};

    m=schema.method(this,'onSigTableWidgetChange');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle','int','int','mxArray'};

    m=schema.method(this,'onLoadBits');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};

    m=schema.method(this,'onBrowseForBitstream');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};






