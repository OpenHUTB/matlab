

function schema

    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'SignalDlg',hDeriveFromClass);


    m=schema.method(this,'init');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


    m=schema.method(this,'getBaseDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getBaseSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'closeDialogCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};


    m=schema.method(this,'bindSignal');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(this,'cacheSignalSelection','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','double'};
    s.OutputTypes={};


    m=schema.method(this,'clearCacheSignalSelection','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={};


    m=schema.method(this,'getInitialState','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','bool','string','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getChannel','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getScaleColors','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'getBackgroundColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'getForegroundColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'getPushButtonIconOffColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'getPushButtonIconOnColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'getPushButtonProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'setPushButtonProperties','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','string','bool','bool'};
    s.OutputTypes={};


    m=schema.method(this,'getGridColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'getFontColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'setColorDisplayBlock','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','string','bool'};
    s.OutputTypes={};


    m=schema.method(this,'setScaleColors','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','string','string','bool','bool'};
    s.OutputTypes={};


    m=schema.method(this,'highlightSignalInModel','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','double'};
    s.OutputTypes={};


    m=schema.method(this,'enterKeyPressed','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={};

    schema.prop(this,'widgetId','string');
    schema.prop(this,'widgetType','string');
    schema.prop(this,'isLibWidget','bool');
    schema.prop(this,'blockObj','mxArray');
    schema.prop(this,'srcBlockObj','mxArray');
    schema.prop(this,'OutputPortIndex','double');
    schema.prop(this,'PreviousBinding','mxArray');
    schema.prop(this,'listeners','mxArray');
    schema.prop(this,'Timer','MATLAB array');
    schema.prop(this,'ScaleColors','MATLAB array');
    schema.prop(this,'ScaleColorLimits','mxArray');

end
