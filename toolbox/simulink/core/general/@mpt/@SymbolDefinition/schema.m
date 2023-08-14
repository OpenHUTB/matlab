function schema()




    mlock;



    hCreateInPackage=findpackage('mpt');


    hThisClass=schema.class(hCreateInPackage,'SymbolDefinition');


    hThisProp=schema.prop(hThisClass,'Name','string');
    hThisProp.Visible='off';

    hThisProp=schema.prop(hThisClass,'Property','MATLAB array');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.AccessFlags.PrivateSet='on';
    hThisProp.AccessFlags.PublicGet='off';
    hThisProp.AccessFlags.PrivateGet='on';
    hThisProp.FactoryValue={};


