function schema




    pk=findpackage('siggui');

    c=schema.class(pk,'cmagspecs',pk.findclass('magspecs'));

    p=schema.prop(c,'ConstrainedBands','posint_vector');


