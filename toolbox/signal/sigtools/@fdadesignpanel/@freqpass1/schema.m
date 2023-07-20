function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqpass1',findclass(pk,'abstractfiltertypewfs'));


    p=schema.prop(c,'Fpass','ustring');
    p.FactoryValue='9600';
    p.Description='spec';


