function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'lpweight',findclass(pk,'abstractweight'));


    p=schema.prop(c,'Wpass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wstop','ustring');
    p.FactoryValue='1';
    p.Description='spec';


