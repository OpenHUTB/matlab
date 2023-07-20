function schema()









mlock


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CoreParameter');
    hCreateInPackage=findpackage('Simulink');


    schema.class(hCreateInPackage,'MCoreParameter',hDeriveFromClass);

end


