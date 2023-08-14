function schema





    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('LinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Processor');
    hThisClass=schema.class(hCreateInPackage,'Processor',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ProdHWDeviceType','string');
    hThisProp.FactoryValue='Specified';
