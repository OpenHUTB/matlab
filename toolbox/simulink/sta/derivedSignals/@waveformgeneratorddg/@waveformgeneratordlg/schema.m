function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('waveformgeneratorddg');


    hThisClass=schema.class(hCreateInPackage,'waveformgeneratordlg',hDeriveFromClass);


    p=schema.prop(hThisClass,'paramsMap','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'rows','int');
    p.FactoryValue=-1;

    p=schema.prop(hThisClass,'dlgID','string');
    p.FactoryValue='';

    p=schema.prop(hThisClass,'signals','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'selection','string');
    p.FactoryValue='';


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


