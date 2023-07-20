function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'lpfreqpassstop',findclass(pk,'lpfreqpass'));

    p=schema.prop(c,'Fstop','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


