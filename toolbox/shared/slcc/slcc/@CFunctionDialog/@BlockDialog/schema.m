function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('CFunctionDialog');


    hThisClass=schema.class(hCreateInPackage,'BlockDialog',hDeriveFromClass);


    m=schema.method(hThisClass,'getDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle','string'},...
    'OutputTypes',{'mxArray'});


