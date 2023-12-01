function schema

    pk=findpackage('xregGui');
    c=schema.class(pk,'ButtonUpManager');

    p=schema.prop(c,'Figure','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'WBUFListener','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'OneTimeCallbacks','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Listener='off';

    schema.event(c,'ButtonUp');
