function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'hpmagc',findclass(pk,'abstractmagc'));

    p=schema.prop(c,'Wstop','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wpass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Astop','ustring');
    p.FactoryValue='80';
    p.Description='spec';

    p=schema.prop(c,'Apass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Dstop','ustring');
    p.FactoryValue='.001';
    p.Description='spec';

    p=schema.prop(c,'Dpass','ustring');
    p.FactoryValue='.01';
    p.Description='spec';

    p=schema.prop(c,'Estop','ustring');
    p.FactoryValue='0.001';
    p.Description='spec';

    p=schema.prop(c,'Epass','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';


