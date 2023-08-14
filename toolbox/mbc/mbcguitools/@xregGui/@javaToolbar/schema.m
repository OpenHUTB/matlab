function schema





    pk=findpackage('xregGui');
    c=schema.class(pk,'javaToolbar',pk.findclass('MBCToolbar'));


    p=schema.prop(c,'hJavaImage','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';


    p=schema.prop(c,'PositionCache','rect');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=[0,0,1,1];


    p=schema.prop(c,'MousePressed','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';




    p=schema.prop(c,'MousePressedAndOverButton','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';


    p=schema.prop(c,'JTList','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';
