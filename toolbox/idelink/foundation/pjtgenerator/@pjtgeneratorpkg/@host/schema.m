function schema()




    hCreateInPackage=findpackage('pjtgeneratorpkg');
    hDeriveFromPackage=findpackage('LinkTgtPkg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Processor');
    hThisClass=schema.class(hCreateInPackage,'host',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ProdHWDeviceType','string');
    hThisProp.FactoryValue='host';
    hThisProp=schema.prop(hThisClass,'SeedCDBFile','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'DefaultCDBMemorySectionName','string');
    hThisProp.FactoryValue='';
