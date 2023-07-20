function schema






    mlock;

    hCreateInPackage=findpackage('PmSli');
    hThisClass=schema.class(hCreateInPackage,'Icon');

    p=schema.prop(hThisClass,'Display','string');
    p=schema.prop(hThisClass,'Size','point');
    p=schema.prop(hThisClass,'ShowFrame','bool');
    p=schema.prop(hThisClass,'ShowName','bool');
    p=schema.prop(hThisClass,'RequiredFiles','string vector');

end
