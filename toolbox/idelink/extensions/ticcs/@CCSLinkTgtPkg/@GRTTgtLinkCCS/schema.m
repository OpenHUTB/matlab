function schema()





    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('LinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'GRTTgtLink');
    hThisClass=schema.class(hCreateInPackage,'GRTTgtLinkCCS',hDeriveFromClass);
