function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('vntdialog');


    hThisClass=schema.class(package,'j1939cantl',parentClass);


    schema.prop(hThisClass,'Block','mxArray');
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'ConfigName','string');
    schema.prop(hThisClass,'DeviceMenu','string');
    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'IsDifferentConfig','bool');
    schema.prop(hThisClass,'ObjConstructor','string');
    schema.prop(hThisClass,'BusSpeedStr','string');
    schema.prop(hThisClass,'SampleTime','string');