function schema





    package=findpackage('filtgraph');
    parent=findclass(package,'port');
    thisclass=schema.class(package,'inport',parent);

    findclass(package,'nodeport');
    p=schema.prop(thisclass,'from','filtgraph.nodeport');
    p.AccessFlags.PublicSet='Off';
