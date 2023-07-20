function schema()
















    hCreateInPackage=findpackage('SLDataClassDesign');


    hThisClass=schema.class(hCreateInPackage,'ClassDefn');


    hThisProp=schema.prop(hThisClass,'ClassName','string');

    hThisProp=schema.prop(hThisClass,'DeriveFromPackage','string');

    hThisProp=schema.prop(hThisClass,'DeriveFromClass','string');

    hThisProp=schema.prop(hThisClass,'DerivedProperties','handle vector');

    hThisProp=schema.prop(hThisClass,'LocalProperties','handle vector');

    hThisProp=schema.prop(hThisClass,'Initialization','string');

    hThisProp=schema.prop(hThisClass,'UseCSCRegFile','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(0);
