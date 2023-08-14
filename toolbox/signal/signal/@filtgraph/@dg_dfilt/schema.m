function schema





    package=findpackage('filtgraph');

    thisclass=schema.class(package,'dg_dfilt');

    p=schema.prop(thisclass,'label','ustring');
    p.FactoryValue='dfilt';
    p.AccessFlags.Init;

    p=schema.prop(thisclass,'expandOrientation','ExpansionOrientation');
    p.FactoryValue='ud';

    findclass(package,'stage');
    p=schema.prop(thisclass,'stage','filtgraph.stage vector');
    p.AccessFlags.PublicSet='Off';

    p=schema.prop(thisclass,'gridGrowingFactor','double_vector');
    p.FactoryValue=[1,1];

    p=schema.prop(thisclass,'stageGridNumber','double_vector');
    p.FactoryValue=[1,1];

