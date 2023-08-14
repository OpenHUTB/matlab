function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'lpnorm',pk.findclass('freqedges'));

    p=schema.prop(c,'MagnitudeVector','ustring');
    p.FactoryValue='[1 1 0 0 1 1]';
    p.Description='spec';

    p=schema.prop(c,'WeightVector','ustring');
    p.FactoryValue='ones(1,6)';
    p.Description='spec';


