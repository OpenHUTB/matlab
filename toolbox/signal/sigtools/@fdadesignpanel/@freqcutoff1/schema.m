function schema

    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'freqcutoff1',findclass(pk,'abstractfiltertypewfs'));

    p=schema.prop(c,'Fc','ustring');
    p.FactoryValue='10800';
    p.Description='spec';


