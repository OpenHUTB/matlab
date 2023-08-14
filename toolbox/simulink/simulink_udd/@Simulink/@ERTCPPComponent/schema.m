function schema()







mlock


    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CPPComponent');


    hThisClass=schema.class(hCreateInPackage,'ERTCPPComponent',hDeriveFromClass);




    m=schema.method(hThisClass,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};




