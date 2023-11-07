function schema

    pk=findpackage('xregGui');
    c=schema.class(pk,'PointerRepository');

    p=schema.prop(c,'Pointers','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
