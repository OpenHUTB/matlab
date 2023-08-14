function schema()





    hDeriveFromPackage=findpackage('RTWConfiguration');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Data');
    hCreateInPackage=findpackage('TargetsCommonConfig');


    hThisClass=schema.class(hCreateInPackage,'CCP',hDeriveFromClass);


