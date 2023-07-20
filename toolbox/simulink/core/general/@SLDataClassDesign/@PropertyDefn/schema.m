function schema()
















    hCreateInPackage=findpackage('SLDataClassDesign');


    hThisClass=schema.class(hCreateInPackage,'PropertyDefn');


    hThisProp=schema.prop(hThisClass,'PropertyName','string');

    hThisProp=schema.prop(hThisClass,'PropertyType','string');

    hThisProp=schema.prop(hThisClass,'FactoryValue','MATLAB array');
