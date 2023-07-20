function schema





    package=findpackage('filtgraph');
    parent=findclass(package,'port');
    thisclass=schema.class(package,'outport',parent);

    findclass(package,'nodeport');
    p=schema.prop(thisclass,'to','filtgraph.nodeport vector');
    p.AccessFlags.PublicSet='Off';
