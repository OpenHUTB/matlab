function schema

    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'bpfreqpassstop',findclass(pk,'abstractfiltertypewfs'));

    p=schema.prop(c,'Fstop1','ustring');
    p.FactoryValue='7200';
    p.Description='spec';

    p=schema.prop(c,'Fpass1','ustring');
    p.FactoryValue='9600';
    p.Description='spec';

    p=schema.prop(c,'Fpass2','ustring');
    p.FactoryValue='12000';
    p.Description='spec';

    p=schema.prop(c,'Fstop2','ustring');
    p.FactoryValue='14400';
    p.Description='spec';


