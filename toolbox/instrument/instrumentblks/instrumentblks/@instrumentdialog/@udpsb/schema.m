function schema




    parentPackage=findpackage('Simulink');
    parentClass=findclass(parentPackage,'SLDialogSource');


    package=findpackage('instrumentdialog');

    hThisClass=schema.class(package,'udpsb',parentClass);


    p=schema.prop(hThisClass,'Block','mxArray');%#ok<NASGU>
    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    schema.prop(hThisClass,'Host','string');
    schema.prop(hThisClass,'Port','string');
    schema.prop(hThisClass,'LocalPort','string');
    schema.prop(hThisClass,'EnableBlockingMode','bool');
    schema.prop(hThisClass,'ByteOrder','string');
    schema.prop(hThisClass,'OutputDatagramPacketSize','string');
    schema.prop(hThisClass,'EnablePortSharing','bool');
    schema.prop(hThisClass,'LocalAddress','string');