function schema()







    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'Allocation');




    hThisProp=schema.prop(hThisClass,'realloc_callback','MATLAB array');


    hThisProp=schema.prop(hThisClass,'host_object','MATLAB array');


    hThisProp=schema.prop(hThisClass,'host_type','AllocationHostType');


    hThisProp=schema.prop(hThisClass,'value','string vector');


    hThisProp=schema.prop(hThisClass,'auto','bool');


