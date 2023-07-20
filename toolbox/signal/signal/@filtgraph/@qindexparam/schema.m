function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'qindexparam');

    p=schema.prop(thisclass,'index','double');
    p.AccessFlags.PublicSet='On';

    findtype('dgQuantumParameter');
    p=schema.prop(thisclass,'params','dgQuantumParameter');
    p.AccessFlags.PublicSet='On';
