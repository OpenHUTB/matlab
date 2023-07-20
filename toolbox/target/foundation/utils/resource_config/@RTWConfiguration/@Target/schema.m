function schema()





    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'Target');


    hThisMethod=schema.method(hThisClass,'acquireResourceForBlock','static');
    hThisMethod=schema.method(hThisClass,'acquireSharedResource','static');



    hThisProp=schema.prop(hThisClass,'activeList','handle');
    hThisProp=schema.prop(hThisClass,'inactiveList','handle');
    hThisProp.AccessFlags.Serialize='off';






    hThisProp=schema.prop(hThisClass,'implicitLibs','string vector');


    hThisProp=schema.prop(hThisClass,'errors','string vector');





    hThisProp=schema.prop(hThisClass,'registered_blocks','string vector');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.Serialize='off';


    hThisProp=schema.prop(hThisClass,'block','string');
