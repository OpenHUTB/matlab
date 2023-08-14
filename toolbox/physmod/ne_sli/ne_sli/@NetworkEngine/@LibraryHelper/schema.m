function schema






    hCreateInPackage=findpackage('NetworkEngine');
    hThisClass=schema.class(hCreateInPackage,'LibraryHelper');

    mlock;



    p=schema.prop(hThisClass,'SourceFile','string');




    p=schema.prop(hThisClass,'Command','string');




    p=schema.prop(hThisClass,'Path','string');




    p=schema.prop(hThisClass,'IsSSCFunction','bool');

end
