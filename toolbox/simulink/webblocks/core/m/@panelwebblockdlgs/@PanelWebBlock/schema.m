function schema
    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('panelwebblockdlgs');
    this=schema.class(hCreateInPackage,'PanelWebBlock',hDeriveFromClass);


    m=schema.method(this,'getSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(this,'PanelWebBlockDialogPropertyCB','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    schema.prop(this,'blockObj','mxArray');
end