function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_UnitConfigurator',hDeriveFromClass);


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

    m=schema.method(hThisClass,'getEnumValFromStr');
    s=m.Signature;
    s.InputTypes={'handle','string','mxArray'};
    s.OutputTypes={'int'};

    m=schema.method(hThisClass,'cacheDialogParams');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'PreApplyCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'CloseCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'availablelist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'selectedlist_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'allowbtn_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'disallowbtn_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'allowallunitsystems_cb');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray','string','string','string','string'};
    s.OutputTypes={};

