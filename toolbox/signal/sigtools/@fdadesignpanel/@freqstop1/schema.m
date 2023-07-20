function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqstop1',findclass(pk,'abstractfiltertypewfs'));


    p=schema.prop(c,'Fstop','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


