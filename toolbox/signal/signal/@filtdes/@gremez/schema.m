function schema






    pk=findpackage('filtdes');


    c=schema.class(pk,'gremez',findclass(pk,'abstractgremez'));

    schema.prop(c,'ErrorBands','posint_vector');


