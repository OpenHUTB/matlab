function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'bpmag',findclass(pk,'abstractmagframe'));


    p=schema.prop(c,'Astop1','ustring');
    p.FactoryValue='60';
    p.Description='spec';

    p=schema.prop(c,'Apass','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Astop2','ustring');
    p.FactoryValue='80';
    p.Description='spec';

    p=schema.prop(c,'Dstop1','ustring');
    p.FactoryValue='0.001';
    p.Description='spec';

    p=schema.prop(c,'Dpass','ustring');
    p.FactoryValue='0.1';
    p.Description='spec';

    p=schema.prop(c,'Dstop2','ustring');
    p.FactoryValue='0.001';
    p.Description='spec';

    p=schema.prop(c,'Estop1','ustring');
    p.FactoryValue='0.0001';
    p.Description='spec';

    p=schema.prop(c,'Epass','ustring');
    p.FactoryValue='0.9';
    p.Description='spec';

    p=schema.prop(c,'Estop2','ustring');
    p.FactoryValue='0.0001';
    p.Description='spec';


