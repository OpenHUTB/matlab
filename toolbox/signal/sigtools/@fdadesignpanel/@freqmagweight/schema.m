function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqmagweight',findclass(pk,'freqvector'));


    p=schema.prop(c,'MagnitudeVector','ustring');
    p.FactoryValue='[1./sinc(0:.05:.55) 0 0]';
    p.Description='spec';

    p=schema.prop(c,'WeightVector','ustring');
    p.FactoryValue='[ones(1,7)]';
    p.Description='spec';


