function schema





    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'arbmagfreqmagc',pk.findclass('arbmagfreqmag'));

    p=schema.prop(c,'ConstrainedBands','ustring');
    set(p,'FactoryValue','[]','Description','spec');


