function schema()





    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('LinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'ERTTgtLink');
    hThisClass=schema.class(hCreateInPackage,'ERTTgtLinkCCS',hDeriveFromClass);
