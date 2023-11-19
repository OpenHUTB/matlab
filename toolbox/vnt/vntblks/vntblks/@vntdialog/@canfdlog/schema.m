function schema
    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('vntdialog');

    hThisClass=schema.class(package,'canfdlog',parentClass);

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
    schema.prop(hThisClass,'MaxNumMessages','string');
    schema.prop(hThisClass,'LogFrom','string');

    schema.prop(hThisClass,'Device','string');
    schema.prop(hThisClass,'IsDifferentDevice','bool');
    schema.prop(hThisClass,'ObjConstructor','string');

    schema.prop(hThisClass,'SampleTime','string');

    schema.prop(hThisClass,'CANFDObject','MATLAB array');