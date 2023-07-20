function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'iirgrpdelay',pk.findclass('freqedges'));

    p=schema.prop(c,'GroupDelayVector','ustring');
    p.FactoryValue='[2 3 1]';
    p.Description='spec';

    p=schema.prop(c,'WeightVector','ustring');
    p.FactoryValue='[1 1 1]';
    p.Description='spec';


