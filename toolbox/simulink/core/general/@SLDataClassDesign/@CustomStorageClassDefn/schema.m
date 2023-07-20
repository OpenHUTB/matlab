function schema()
















    hCreateInPackage=findpackage('SLDataClassDesign');


    hThisClass=schema.class(hCreateInPackage,'CustomStorageClassDefn');


    hThisProp=schema.prop(hThisClass,'CustomStorageClassName','string');

    hThisProp=schema.prop(hThisClass,'TLCFileToUse','string');

    hThisProp=schema.prop(hThisClass,'AttributesClass','string');
