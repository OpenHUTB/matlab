function schema()




    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_Subsystem',hDeriveFromClass);







    p=schema.prop(hThisClass,'paramsMap','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'isSlimDialog','bool');
    p.FactoryValue=false;





    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getSlimDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'buildBlockDescription');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray','mxArray'};


    m=schema.method(hThisClass,'buildParameterGroup');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'createMainTabItems');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createCodeGenTabItems');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createConcurrencyTabItems');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'createSubsystemRefTabItems');
    s=m.Signature;
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'addWidget');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','mxArray','string','bool'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'getIsCondExecSubsystem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'getIsReferenceSubsystem');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'appendWidget');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};
end
