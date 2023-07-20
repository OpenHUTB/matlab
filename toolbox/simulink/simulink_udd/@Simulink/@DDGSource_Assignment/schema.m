function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'DDGSource_NDIndexing');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_Assignment',hDeriveFromClass);


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'isDialogOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isPortOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'isSpecifyingOutSize');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getOutSizeStrForOutInit');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};


