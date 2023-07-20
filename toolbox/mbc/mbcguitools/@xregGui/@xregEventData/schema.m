function schema







    hThisPackage=findpackage('xregGui');

    hParentClass=findclass(findpackage('handle'),'EventData');

    hThisClass=schema.class(hThisPackage,'xregEventData',hParentClass);


    schema.prop(hThisClass,'data','MATLAB array');