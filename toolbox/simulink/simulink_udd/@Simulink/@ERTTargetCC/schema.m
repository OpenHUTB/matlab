function schema()




mlock


    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'CustomTargetCC');


    hThisClass=schema.class(hCreateInPackage,'ERTTargetCC',hDeriveFromClass);


    hThisClass=configset.udd_definitions.ERTTargetCC(hThisClass);
