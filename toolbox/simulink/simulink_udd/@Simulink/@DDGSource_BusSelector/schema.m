function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'DDGSource_Bus');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_BusSelector',hDeriveFromClass);


    p=schema.prop(hThisClass,'mOutputSignals','ustring');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createInvisibleGroup');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createSelectionList');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createOutputCheckBox');
    s=m.Signature;
    s.InputTypes={'handle',};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'select');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'remove_hook');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};




    m=schema.method(hThisClass,'updateSelectedSignalList');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'retrieveSelection');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'swapSignal');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};
