function schema()




    hCreateInPackage=findpackage('RTWConfiguration');

    hThisClass=schema.class(hCreateInPackage,'Dependency');


    hThisProp=schema.prop(hThisClass,'DependentProperty','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';

    hThisProp=schema.prop(hThisClass,'ActivationVector','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';

    hThisProp=schema.prop(hThisClass,'DeactivationVector','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PublicGet='off';
