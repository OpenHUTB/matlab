function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');

    package=findpackage('daqdialog');
    hThisClass=schema.class(package,'diossdlg',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'IsDigitalInput','bool');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'EnableApplyButtonAtInit','bool');
    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'DeviceMenu','string');
    schema.prop(hThisClass,'ModuleInfo','string');
    schema.prop(hThisClass,'ObjConstructor','string');
    schema.prop(hThisClass,'NLinesSelected','string');
    schema.prop(hThisClass,'Lines','string');
    schema.prop(hThisClass,'NPorts','string');
    schema.prop(hThisClass,'BlockSampleTime','string');
    schema.prop(hThisClass,'OutputTimestamp','bool');
    schema.prop(hThisClass,'AnyCallbackErrors','double');
    schema.prop(hThisClass,'LinesSchema','handle vector');


    schema.prop(hThisClass,'DAQObject','MATLAB array');
    schema.prop(hThisClass,'ChannelInfoList','MATLAB array');
    schema.prop(hThisClass,'subSystemType','string');


    schema.prop(hThisClass,'ObjectBeingDestroyedListener','MATLAB array');
    schema.prop(hThisClass,'PropertyChangedListener','MATLAB array');

