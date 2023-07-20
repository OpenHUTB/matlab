function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqvector',findclass(pk,'abstractfiltertypewfs'));
    c.Description='abstract';


    p=schema.prop(c,'FrequencyVector','ustring');
    p.FactoryValue='[0:.05:.55 .6 1]';
    p.Description='spec';


