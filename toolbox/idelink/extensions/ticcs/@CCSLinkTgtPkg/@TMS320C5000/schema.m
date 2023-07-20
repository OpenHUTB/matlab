function schema()





    chipInfo=c5000_getClassInfo('TMS320C5000');


    hCreateInPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromPackage=findpackage('CCSLinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,chipInfo.parent);
    hThisClass=schema.class(hCreateInPackage,chipInfo.this,hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ProdHWDeviceType','string');
    hThisProp.FactoryValue='TI C5000';
    hThisProp=schema.prop(hThisClass,'SeedCDBFile','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'DefaultCDBMemorySectionName','string');
    hThisProp.FactoryValue='';

