function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'magpass',findclass(pk,'abstractmagframe'));

    p=schema.prop(c,'Apass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Dpass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Epass','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';


