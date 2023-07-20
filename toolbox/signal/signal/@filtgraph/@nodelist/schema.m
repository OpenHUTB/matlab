function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'nodelist');

    findclass(package,'node');
    p=schema.prop(thisclass,'nodes','filtgraph.node vector');
    p.AccessFlags.PublicSet='Off';
    p.AccessFlags.PublicGet='On';

    p=schema.prop(thisclass,'nodeCount','double');
    p.AccessFlags.PublicSet='Off';
    p.AccessFlags.PublicGet='Off';

