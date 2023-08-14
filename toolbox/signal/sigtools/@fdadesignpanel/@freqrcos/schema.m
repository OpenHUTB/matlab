function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqrcos',findclass(pk,'freqwtransition'));


    p=schema.prop(c,'Fc','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


