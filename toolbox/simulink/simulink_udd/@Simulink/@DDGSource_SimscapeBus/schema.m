function schema()


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DDGSource_SimscapeBus',hDeriveFromClass);


    p=schema.prop(hThisClass,'UserData1','mxArray');
    p.FactoryValue=[];


    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDialogButtonSets');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle'},'OutputTypes',{'mxArray'});

