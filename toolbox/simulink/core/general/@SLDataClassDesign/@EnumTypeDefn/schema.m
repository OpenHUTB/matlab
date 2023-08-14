function schema()
















    hCreateInPackage=findpackage('SLDataClassDesign');


    hThisClass=schema.class(hCreateInPackage,'EnumTypeDefn');


    hThisProp=schema.prop(hThisClass,'EnumTypeName','string');

    hThisProp=schema.prop(hThisClass,'EnumStrings','string vector');
