function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_ImplicitIterator',hDeriveFromClass);


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

    m=schema.method(hThisClass,'getInpIterTblWidget');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getOutConcatTblWidget');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMaskPrmIterTblWidget');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getStateWidgets');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getActFlagWidget');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getIdxTypeWidgets');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getShowWidgets');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray','mxArray','mxArray'};

    m=schema.method(hThisClass,'getColId');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getInpIterTableData');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getOutConcatTableData');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getMaskPrmIterTableData');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'getEnumValFromStr');
    s=m.Signature;
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'getStrForNotIter');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'constructDlgStruct');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'initWidget');
    s=m.Signature;
    s.InputTypes={'handle','string','bool'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'StateResetVisible');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'IterationActFlagVisible');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'ShowIndex');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'inputslist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


