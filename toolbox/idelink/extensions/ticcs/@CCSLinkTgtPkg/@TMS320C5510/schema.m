function schema





    chipInfo=c5000_getClassInfo('TMS320C5510');


    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,chipInfo.parent);
    hThisClass=schema.class(hCreateInPackage,chipInfo.this,hDeriveFromClass);

