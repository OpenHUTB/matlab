function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqstop2',findclass(pk,'abstractfiltertypewfs'));


    p=schema.prop(c,'Fstop1','ustring');
    p.FactoryValue='9600';
    p.Description='spec';

    p=schema.prop(c,'Fstop2','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


