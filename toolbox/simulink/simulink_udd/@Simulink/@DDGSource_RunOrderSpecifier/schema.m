function schema()




    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,...
    'DDGSource_RunOrderSpecifier',hDeriveFromClass);


    p=schema.prop(hThisClass,'paramsMap','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'ActiveTab','int');
    p.FactoryValue=0;

    p=schema.prop(hThisClass,'UserData','mxArray');
    p.FactoryValue=[];


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'runOrderSpecifiedSubsystemDDG');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getBlockDescription');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray','mxArray'};
