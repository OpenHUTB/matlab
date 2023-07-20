function schema





    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'ConnectorInfoLinks',hDeriveFromClass1);








    hThisProp=schema.prop(hThisClass,'ConnectorType','MATLAB array');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'OriginalOwners','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'OriginalReaders','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'OriginalWriters','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'OriginalReaderWriters','MATLAB array');
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

