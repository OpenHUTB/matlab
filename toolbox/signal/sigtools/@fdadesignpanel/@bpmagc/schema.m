function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'bpmagc',findclass(pk,'abstractmagc'));

    p=schema.prop(c,'Wstop1','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wpass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Wstop2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Astop1','ustring');
    p.FactoryValue='80';
    p.Description='spec';

    p=schema.prop(c,'Apass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Astop2','ustring');
    p.FactoryValue='60';
    p.Description='spec';

    p=schema.prop(c,'Dstop1','ustring');
    p.FactoryValue='.001';
    p.Description='spec';

    p=schema.prop(c,'Dpass','ustring');
    p.FactoryValue='.01';
    p.Description='spec';

    p=schema.prop(c,'Dstop2','ustring');
    p.FactoryValue='.01';
    p.Description='spec';

    p=schema.prop(c,'Estop1','ustring');
    p.FactoryValue='0.001';
    p.Description='spec';

    p=schema.prop(c,'Epass','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';

    p=schema.prop(c,'Estop2','ustring');
    p.FactoryValue='0.01';
    p.Description='spec';


