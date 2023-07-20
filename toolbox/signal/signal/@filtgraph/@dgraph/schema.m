function schema





    package=findpackage('filtgraph');

    thisclass=schema.class(package,'dgraph');
    thisclass.Description='abstract';

    findclass(package,'nodelist');
    p=schema.prop(thisclass,'nodeList','filtgraph.nodelist');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'numNodes','double');
    p.AccessFlags.PublicSet='On';

