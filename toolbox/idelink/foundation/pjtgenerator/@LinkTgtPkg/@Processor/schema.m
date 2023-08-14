function schema




    hCreateInPackage=findpackage('LinkTgtPkg');
    hThisClass=schema.class(hCreateInPackage,'Processor');


    hThisProp=schema.prop(hThisClass,'ProdHWDeviceType','string');
    hThisProp.FactoryValue='Specified';
