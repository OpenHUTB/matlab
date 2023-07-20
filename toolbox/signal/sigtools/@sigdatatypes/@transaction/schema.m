function schema





    pk=findpackage('sigdatatypes');
    hpk=findpackage('handle');


    c=schema.class(pk,'transaction',hpk.findclass('transaction'));

    p=schema.prop(c,'PropertyListeners','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'Object','handle');
    p=schema.prop(c,'Property','MATLAB array');
    p=schema.prop(c,'OldValue','MATLAB array');
    p=schema.prop(c,'NewValue','MATLAB array');


