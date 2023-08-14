function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'port');

    p=schema.prop(thisclass,'nodeIndex','double');
    p.AccessFlags.PublicSet='Off';
    p.FactoryValue=0;
    p.AccessFlags.Init;

    p=schema.prop(thisclass,'selfIndex','double');
    p.AccessFlags.PublicSet='Off';
    p.FactoryValue=0;
    p.AccessFlags.Init;
