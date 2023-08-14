function schema






    mlock;
    hCreateInPackage=findpackage('PmSli');
    hThisClass=schema.class(hCreateInPackage,'LibraryEntry');




    p=schema.prop(hThisClass,'Name','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';




    p=schema.prop(hThisClass,'File','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';




    p=schema.prop(hThisClass,'Product','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';







    p=schema.prop(hThisClass,'Context','string');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';







    p=schema.prop(hThisClass,'IsValid','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='on';





    p=schema.prop(hThisClass,'Descriptor','string');





    p=schema.prop(hThisClass,'RegistrationFile','string');




    icon=PmSli.Icon;
    p=schema.prop(hThisClass,'Icon',class(icon));






    p=schema.prop(hThisClass,'DocumentationFcn','MATLAB callback');





    p=schema.prop(hThisClass,'EditingModeFcn','string');




    schema.method(hThisClass,'defaultDocumentationFcn','static');

end
