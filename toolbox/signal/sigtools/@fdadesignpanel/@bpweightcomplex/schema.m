function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'bpweightcomplex',findclass(pk,'abstractweight'));


    p=schema.prop(c,'Wstop1','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wpass1','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wstop2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wpass2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wstop3','ustring');
    p.FactoryValue='1';
    p.Description='spec';


