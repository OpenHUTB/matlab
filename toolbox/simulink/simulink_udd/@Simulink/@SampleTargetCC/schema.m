function schema()





    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');


    hThisClass=schema.class(hCreateInPackage,'SampleTargetCC',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'MatFileLogging','on/off');
    hThisProp.FactoryValue='off';



    m=schema.method(hThisClass,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getStringFormat');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


