function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqcutoff2',findclass(pk,'abstractfiltertypewfs'));


    p=schema.prop(c,'Fc1','ustring');
    p.FactoryValue='8400';
    p.Description='spec';

    p=schema.prop(c,'Fc2','ustring');
    p.FactoryValue='13200';
    p.Description='spec';


