function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_NDIndexing',hDeriveFromClass);


    p=schema.prop(hThisClass,'DialogData','mxArray');
    p.FactoryValue={};




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


    m=schema.method(hThisClass,'NumDimsCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'ParamWidgetCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle','string','bool','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'CloseCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getNumDims');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getCommonWidgets');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray','mxArray','mxArray'};

    m=schema.method(hThisClass,'getDimsPropTableColHeader');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getColId');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getColWidth');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getDimsPropTableData');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getEnumValFromStr');
    s=m.Signature;
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'isAllOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getIndexStrForPortOpt');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getIndexPortName');
    s=m.Signature;
    s.InputTypes={'handle','int'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getIndexStrForAllOpt');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'constructDlgStruct');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','int','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDefIdxOpt');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getDefIdxParamAndOutputSize');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'initWidget');
    s=m.Signature;
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={'mxArray'};


