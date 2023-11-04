function schema
    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('j1939dialog');

    hThisClass=schema.class(package,'j1939nodeconfig',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'ConfigName','string');
    schema.prop(hThisClass,'NodeID','string');
    schema.prop(hThisClass,'NodeName','string');

    schema.prop(hThisClass,'AllowAAC','bool');
    schema.prop(hThisClass,'NodeAddress','string');
    schema.prop(hThisClass,'IndustryGroup','string');
    schema.prop(hThisClass,'VehicleSystem','string');
    schema.prop(hThisClass,'VehicleSystemInstance','string');

    schema.prop(hThisClass,'FunctionID','string');
    schema.prop(hThisClass,'FunctionInstance','string');
    schema.prop(hThisClass,'ECUInstance','string');
    schema.prop(hThisClass,'ManufacturerCode','string');
    schema.prop(hThisClass,'IDNumber','string');

    schema.prop(hThisClass,'SampleTime','string');
    schema.prop(hThisClass,'OutputAddress','bool');
    schema.prop(hThisClass,'OutputACStatus','bool');
    schema.prop(hThisClass,'IsDifferentConfig','bool');
    schema.prop(hThisClass,'IsDifferentNode','bool');
    schema.prop(hThisClass,'IsInvalidCANdbFile','bool');
    schema.prop(hThisClass,'ShowError','bool');