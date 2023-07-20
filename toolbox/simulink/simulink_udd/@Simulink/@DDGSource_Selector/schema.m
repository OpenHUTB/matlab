function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'DDGSource_NDIndexing');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_Selector',hDeriveFromClass);


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


    m=schema.method(hThisClass,'isIdxVectOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isStartEndOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getOutSizeStrForAllOpt');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getOutSizeStrForDlgIdxOpt');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getOutSizeStrForPrtIdxOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getOutSizeStrForPrtStartEndOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'string'};


