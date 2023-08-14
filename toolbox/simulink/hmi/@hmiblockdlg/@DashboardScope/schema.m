



function schema
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'DashboardScope',hDeriveFromClass);


    m=schema.method(this,'init');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
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


    m=schema.method(this,'closeDialogCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};


    m=schema.method(this,'applyBindingChanges');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(this,'validateAxisLimits','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','handle','bool'};
    s.OutputTypes={'bool','string'};


    m=schema.method(this,'highlightSignalInModel','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'double','string','double'};
    s.OutputTypes={};


    m=schema.method(this,'enterKeyPressed','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={};


    m=schema.method(this,'onBindingPropUpdated','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'double','string'};
    s.OutputTypes={};


    m=schema.method(this,'findScopeDialog','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'double'};
    s.OutputTypes={'handle'};


    m=schema.method(this,'getFontColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'string'};


    m=schema.method(this,'setFontColor','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','string','bool'};
    s.OutputTypes={};


    schema.prop(this,'widgetId','string');
    schema.prop(this,'widgetType','string');
    schema.prop(this,'isLibWidget','bool');
    schema.prop(this,'blockObj','mxArray');
    schema.prop(this,'srcBlockObj','mxArray');
    schema.prop(this,'OutputPortIndex','double');
    schema.prop(this,'Listeners','mxArray');
    schema.prop(this,'SelectedSignals','mxArray');
    schema.prop(this,'PreviousBinding','mxArray');
    schema.prop(this,'BackgroundColor','string');
    schema.prop(this,'ForegroundColor','string');
    schema.prop(this,'FontColor','string');
end
