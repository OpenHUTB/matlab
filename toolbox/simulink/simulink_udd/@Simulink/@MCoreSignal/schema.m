function schema()









mlock


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CoreSignal');
    hCreateInPackage=findpackage('Simulink');


    schema.class(hCreateInPackage,'MCoreSignal',hDeriveFromClass);

end


