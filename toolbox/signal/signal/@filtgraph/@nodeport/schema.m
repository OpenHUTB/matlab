function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'nodeport');

    p=schema.prop(thisclass,'node','double');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'port','double');
    p.AccessFlags.PublicSet='On';
