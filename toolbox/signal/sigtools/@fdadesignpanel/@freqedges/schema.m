function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqedges',findclass(pk,'freqvector'));
    c.Description='abstract';


    p=schema.prop(c,'FrequencyEdges','ustring');
    p.FactoryValue='[0 .0175 .02 .0215 .025 1]';
    p.Description='spec';


