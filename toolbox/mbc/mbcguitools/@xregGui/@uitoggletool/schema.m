function schema





    pk=findpackage('xregGui');
    c=schema.class(pk,'uitoggletool',pk.findclass('uipushtool'));


    p=schema.prop(c,'State','on/off');
    p.AccessFlags.Init='on';
    p.FactoryValue='off';

    p=schema.prop(c,'OnCallback','MATLAB callback');

    p=schema.prop(c,'OffCallback','MATLAB callback');



    p=schema.prop(c,'toggletoolListener','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'OnEventListener','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'OffEventListener','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'BooleanState','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';


    e=schema.event(c,'OnCallback');
    e=schema.event(c,'OffCallback');
