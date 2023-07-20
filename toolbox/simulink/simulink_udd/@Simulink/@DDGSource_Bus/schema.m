function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_Bus',hDeriveFromClass);


    p=schema.prop(hThisClass,'paramsMap','mxArray');
    p.FactoryValue={};
    schema.prop(hThisClass,'signalSelector','handle vector');



    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'errorDlg');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createBusDialog');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createBlkDescGroup');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createInputGroup');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createSignalSelector');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'createFindButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createAddButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};



    m=schema.method(hThisClass,'createSelectButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createRefreshButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createOutputGroup');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createUpButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createDownButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createRemoveButton');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'combineGroups');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createDialogStruct');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};



    m=schema.method(hThisClass,'CloseCallback');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'unhilite');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'refresh');
    s=m.Signature;
    s.InputTypes={'handle','handle','bool'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'refresh_hook');
    s=m.Signature;
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'updateSelection');
    s=m.Signature;
    s.InputTypes={'handle','handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'hiliteSignalInList');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'findSrc');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'swap');
    s=m.Signature;
    s.InputTypes={'handle','handle','double'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'add');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'remove');
    s=m.Signature;
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'validateSelections');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};




    m=schema.method(hThisClass,'getSelectedSignalString');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getHierarchyInfo');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'oldFormat2NewFormat');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getCachedSignalHierarchy');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getBlockHandles');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray','mxArray'};

    m=schema.method(hThisClass,'setBusItem');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'findBusSrc');
    s=m.Signature;
    s.InputTypes={'handle','mxArray','ustring'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'cellArr2Str');
    s=m.Signature;
    s.InputTypes={'handle','mxArray',};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'str2CellArr');
    s=m.Signature;
    s.InputTypes={'handle','ustring','ustring'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'cleanQuestionMarks');
    s=m.Signature;
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'mxArray'};
