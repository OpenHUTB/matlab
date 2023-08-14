function schema





    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'ResourceAccessorLinks',hDeriveFromClass1);








    hThisProp=schema.prop(hThisClass,'ResourceOwnerBlock','MATLAB array');
    hThisProp.FactoryValue={};



    hThisProp=schema.prop(hThisClass,'StateInfo','MATLAB array');
    hThisProp.FactoryValue={};



    hThisProp=schema.prop(hThisClass,'ParamInfo','MATLAB array');
    hThisProp.FactoryValue={};






    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'hiliteBlockCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double'};
