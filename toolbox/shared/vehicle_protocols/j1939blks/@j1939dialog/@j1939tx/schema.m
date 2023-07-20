function schema





    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('j1939dialog');


    hThisClass=schema.class(package,'j1939tx',parentClass);


    schema.prop(hThisClass,'Block','mxArray');
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'ConfigName','string');
    schema.prop(hThisClass,'NodeName','string');
    schema.prop(hThisClass,'PGList','string');
    schema.prop(hThisClass,'PGName','string');
    schema.prop(hThisClass,'SignalInfo','string');
    schema.prop(hThisClass,'NSignals','string');
    schema.prop(hThisClass,'PGPriority','string');
    schema.prop(hThisClass,'MsgLength','string');
    schema.prop(hThisClass,'DestAddrID','string');
    schema.prop(hThisClass,'DestAddrName','string');
    schema.prop(hThisClass,'TransmitPeriodically','bool');
    schema.prop(hThisClass,'MessagePeriod','string');
    schema.prop(hThisClass,'SampleTime','string');


    schema.prop(hThisClass,'IsDifferentCANdbFile','bool');
    schema.prop(hThisClass,'IsInvalidCANdbFile','bool');
    schema.prop(hThisClass,'IsDummyRefresh','bool');
    schema.prop(hThisClass,'NodeID','string');
    schema.prop(hThisClass,'SignalSchema','handle vector');
    schema.prop(hThisClass,'IsDifferentPGConfig','bool');
