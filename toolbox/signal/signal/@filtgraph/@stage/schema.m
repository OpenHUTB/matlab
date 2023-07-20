function schema





    package=findpackage('filtgraph');

    parent=findclass(package,'dgraph');
    thisclass=schema.class(package,'stage',parent);

    findclass(package,'nodeport');
    p=schema.prop(thisclass,'prevInputPorts','filtgraph.nodeport vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'prevOutputPorts','filtgraph.nodeport vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'nextInputPorts','filtgraph.nodeport vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'nextOutputPorts','filtgraph.nodeport vector');
    p.AccessFlags.PublicSet='On';

    findclass(package,'indexparam');
    p=schema.prop(thisclass,'mainParamList','filtgraph.indexparam vector');
    p.AccessFlags.PublicSet='On';

    findclass(package,'qindexparam');
    p=schema.prop(thisclass,'qparamList','filtgraph.qindexparam vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'numStages','double');
    p.AccessFlags.PublicSet='Off';
    p.FactoryValue=1;
    p.AccessFlags.Init;
