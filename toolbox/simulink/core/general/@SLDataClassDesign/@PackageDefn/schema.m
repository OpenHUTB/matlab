function schema()
















    hCreateInPackage=findpackage('SLDataClassDesign');


    hThisClass=schema.class(hCreateInPackage,'PackageDefn');


    hThisProp=schema.prop(hThisClass,'PackageName','string');

    hThisProp=schema.prop(hThisClass,'PackageDir','string');

    hThisProp=schema.prop(hThisClass,'OrigPackageDir','string');

    hThisProp=schema.prop(hThisClass,'Classes','handle vector');

    hThisProp=schema.prop(hThisClass,'OldRTWInfoClasses','handle vector');

    hThisProp=schema.prop(hThisClass,'EnumTypes','handle vector');

    hThisProp=schema.prop(hThisClass,'OldEnumTypes','handle vector');

    hThisProp=schema.prop(hThisClass,'CSCHandlingMode','SLDataClassDesign_CSCHandlingMode');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue='v1 - Manually defined';

    hThisProp=schema.prop(hThisClass,'CustomStorageClasses','handle vector');

    hThisProp=schema.prop(hThisClass,'ReadOnly','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(0);

    hThisProp=schema.prop(hThisClass,'Modified','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=logical(0);
