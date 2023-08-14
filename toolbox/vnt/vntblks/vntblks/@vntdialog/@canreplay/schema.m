function schema





    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('vntdialog');

    hThisClass=schema.class(package,'canreplay',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'FullPathFileName','string');
    schema.prop(hThisClass,'FileName','string');
    schema.prop(hThisClass,'VariableName','string');
    schema.prop(hThisClass,'NoTimesReplay','string');
    schema.prop(hThisClass,'ReplayTo','string');

    schema.prop(hThisClass,'DeviceMenu','string');
    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'ObjConstructor','string');

    schema.prop(hThisClass,'SampleTime','string');

    schema.prop(hThisClass,'BusOutput','bool');


    schema.prop(hThisClass,'CANObject','MATLAB array');