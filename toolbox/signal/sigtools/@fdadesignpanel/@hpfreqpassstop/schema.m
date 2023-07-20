function schema





    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'hpfreqpassstop',findclass(pk,'hpfreqstop'));


    p=schema.prop(c,'Fpass','ustring');
    p.FactoryValue='12000';
    p.Description='spec';


