function schema




    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hThisClass=schema.class(hCreateInPackage,'ModelDDLinksButtonPanel',hDeriveFromClass);


    prop=schema.prop(hThisClass,'rootAdapter','mxArray');


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'setDirty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


