function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_EVCGKernelScheduler',hDeriveFromClass);


    p=schema.prop(hThisClass,'DialogData','mxArray');
    p.FactoryValue={};




    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


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

    m=schema.method(hThisClass,'getInpKernelTblWidget');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getColId');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getInpKernelTableData');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getEnumValFromStr');
    s=m.Signature;
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'constructDlgStruct');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'initWidget');
    s=m.Signature;
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'inputslist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


