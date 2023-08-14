function schema






    mlock;

    pkg=findpackage('propset');
    h=schema.class(pkg,'abstractset');






    p=schema.prop(h,'prop_set_names','string vector');
    p.AccessFlags.PublicSet='off';






    p=schema.prop(h,'prop_sets','MATLAB array');
    p.AccessFlags.PublicSet='off';


    p=schema.prop(h,'prop_set_enables','MATLAB array');
    p.AccessFlags.PublicSet='off';


