function schema()






    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'TMS320C2000');
    hThisClass=schema.class(hCreateInPackage,'TMS320C280x',hDeriveFromClass);
