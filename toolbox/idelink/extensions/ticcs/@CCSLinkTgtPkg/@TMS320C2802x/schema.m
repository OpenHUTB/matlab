function schema()






    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'TMS320C2000');
    hThisClass=schema.class(hCreateInPackage,'TMS320C2802x',hDeriveFromClass);
