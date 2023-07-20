function schema

mlock



    hCreateInPackage=findpackage('Simulink');
    hDeriveFromPackage=findpackage('schema');
    hDeriveFromClass=findclass(hDeriveFromPackage,'prop');
    hThisClass=schema.class(hCreateInPackage,'TargetCCProperty',hDeriveFromClass);

    p=schema.prop(hThisClass,'TargetCCPropertyAttributes','mxArray');
    p.FactoryValue=[];

    m=schema.method(hThisClass,'TargetCCProperty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'setGrandfathered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


