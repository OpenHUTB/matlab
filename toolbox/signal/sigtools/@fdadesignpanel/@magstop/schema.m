function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'magstop',findclass(pk,'abstractmagframe'));


    p=schema.prop(c,'Astop','ustring');
    p.FactoryValue='80';
    p.Description='spec';

    p=schema.prop(c,'Dstop','ustring');
    p.FactoryValue='.001';
    p.Description='spec';

    p=schema.prop(c,'Estop','ustring');
    p.FactoryValue='.0001';
    p.Description='spec';


