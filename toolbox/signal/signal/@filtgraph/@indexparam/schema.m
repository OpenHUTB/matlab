function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'indexparam');

    p=schema.prop(thisclass,'index','double');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'params','string vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'gainlabels','string vector');
    p.AccessFlags.PublicSet='On';
