function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'bsmag',findclass(pk,'abstractmagframe'));


    p=schema.prop(c,'Apass1','ustring');
    p.FactoryValue='.5';
    p.Description='spec';

    p=schema.prop(c,'Astop','ustring');
    p.FactoryValue='60';
    p.Description='spec';

    p=schema.prop(c,'Apass2','ustring');
    p.FactoryValue='1';
    p.Description='spec';

    p=schema.prop(c,'Dpass1','ustring');
    p.FactoryValue='0.1';
    p.Description='spec';

    p=schema.prop(c,'Dstop','ustring');
    p.FactoryValue='0.0001';
    p.Description='spec';

    p=schema.prop(c,'Dpass2','ustring');
    p.FactoryValue='0.1';
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


