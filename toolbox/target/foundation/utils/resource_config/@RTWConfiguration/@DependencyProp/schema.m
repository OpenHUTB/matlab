function schema()





    hDeriveFromPackage=findpackage('schema');

    hDeriveFromClass=findclass(hDeriveFromPackage,'prop');


    hThisPackage=findpackage('RTWConfiguration');

    hThisClass=schema.class(hThisPackage,'DependencyProp',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'ActivateValue','string');
    hThisProp.AccessFlags.Init='on';


    hThisProp=schema.prop(hThisClass,'Dependencies','handle vector');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
