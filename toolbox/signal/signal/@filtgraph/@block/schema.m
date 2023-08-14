function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'block');

    p=schema.prop(thisclass,'nodeIndex','double');
    p.AccessFlags.PublicSet='Off';

    p=schema.prop(thisclass,'blocktype','BlockType');
    p.AccessFlags.PublicSet='Off';

    c=package.findclass('inport');
    p=schema.prop(thisclass,'inport','filtgraph.inport vector');

    c=package.findclass('outport');
    p=schema.prop(thisclass,'outport','filtgraph.outport vector');

    p=schema.prop(thisclass,'label','ustring');
    p.AccessFlags.PublicSet='On';
    p.FactoryValue='';
    p.AccessFlags.Init;

    p=schema.prop(thisclass,'mainParam','ustring');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'paramList','string vector');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'orientation','Orientation');
    p.AccessFlags.PublicSet='On';

    p=schema.prop(thisclass,'CoeffNames','mxArray');
    p.AccessFlags.PublicSet='On';
