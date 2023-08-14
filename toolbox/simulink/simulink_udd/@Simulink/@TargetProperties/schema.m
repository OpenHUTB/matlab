function schema()






    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'TargetProperties');


    hThisProp=schema.prop(hThisClass,'PropertiesName','string');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='UnNamed';
