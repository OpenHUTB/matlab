function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'DDGSource_Bus');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_BusCreator',hDeriveFromClass);


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'str2doubleNoComma');
    s=m.Signature;
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={'double'};


    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'refresh_hook');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'remove_hook');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'inheritNames');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'updateInputs');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'rename');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'retainWidgetStatus');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};



    m=schema.method(hThisClass,'getNumInputs');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getListEntries');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'hiliteSignalInList');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setUpDownRenameWidgetStatus');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'updateSelection');
    s=m.Signature;
    s.InputTypes={'handle','handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'updateSelectedSignalList');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'retrieveSelection');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'addSignal');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'swapSignal');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'cellArr2Str');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'str2CellArr');
    s=m.Signature;
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={'mxArray'};


