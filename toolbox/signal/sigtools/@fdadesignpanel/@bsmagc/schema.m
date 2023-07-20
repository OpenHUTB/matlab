function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'bsmagc',findclass(pk,'abstractmagc'));

    p=schema.prop(c,'Wpass1','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wstop','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wpass2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Apass1','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Astop','ustring');
    p.FactoryValue='80';
    p.Description='spec';

    p=schema.prop(c,'Apass2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Dpass1','ustring');
    p.FactoryValue='.01';
    p.Description='spec';

    p=schema.prop(c,'Dstop','ustring');
    p.FactoryValue='.001';
    p.Description='spec';

    p=schema.prop(c,'Dpass2','ustring');
    p.FactoryValue='.01';
    p.Description='spec';

    p=schema.prop(c,'Epass1','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';

    p=schema.prop(c,'Estop','ustring');
    p.FactoryValue='0.001';
    p.Description='spec';

    p=schema.prop(c,'Epass2','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';


