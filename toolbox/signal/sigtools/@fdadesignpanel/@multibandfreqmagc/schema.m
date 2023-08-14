function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'multibandfreqmagc',pk.findclass('multibandfreqmag'));

    p=schema.prop(c,'ConstrainedBands','ustring');
    set(p,'FactoryValue','[]','Description','spec');

