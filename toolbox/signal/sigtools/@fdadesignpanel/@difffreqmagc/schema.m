function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'difffreqmagc',pk.findclass('difffreqmag'));

    p=schema.prop(c,'ConstrainedBands','ustring');
    set(p,'FactoryValue','[]','Description','spec');

