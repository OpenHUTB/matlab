

function schema

    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('hmiblockdlg');
    this=schema.class(hCreateInPackage,'ParameterDlg',hDeriveFromClass);


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


    m=schema.method(this,'bindParameter');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(this,'cacheParamSelection','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','string','string'};
    s.OutputTypes={};


    m=schema.method(this,'cacheElementInput','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string','string','string','string'};
    s.OutputTypes={};


    m=schema.method(this,'clearCacheParamSelection','Static');
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


    m=schema.method(this,'updateDiagram','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string','string'};
    s.OutputTypes={};


    m=schema.method(this,'highlightParameterInModel','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
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
    schema.prop(this,'srcParamOrVar','string');
    schema.prop(this,'srcElement','string');
    schema.prop(this,'srcWksType','string');
    schema.prop(this,'listeners','mxArray');
    schema.prop(this,'timer','MATLAB array');
end


