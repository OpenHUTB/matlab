function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqpass2',findclass(pk,'abstractfiltertypewfs'));


    p=schema.prop(c,'Fpass1','ustring');
    p.FactoryValue='9600';
    p.Description='spec';

    p=schema.prop(c,'Fpass2','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


