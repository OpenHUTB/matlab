function schema()





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'BaseRTWInfo');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'CustomRTWInfo',hDeriveFromClass);


    schema.method(hThisClass,'writeSelfContentsForSaveVars','static');
