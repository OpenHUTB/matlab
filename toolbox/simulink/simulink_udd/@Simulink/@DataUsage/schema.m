function schema()






mlock



    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'DataUsage');


    hThisProp=schema.prop(hThisClass,'IsParameter','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(1);

    hThisProp=schema.prop(hThisClass,'IsSignal','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(1);



