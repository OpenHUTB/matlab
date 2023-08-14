function schema()





    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Processor');
    hThisClass=schema.class(hCreateInPackage,'TMS320C2000',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ProdHWDeviceType','string');
    hThisProp.FactoryValue='TI C2000';
