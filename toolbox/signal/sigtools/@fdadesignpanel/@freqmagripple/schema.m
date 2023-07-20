function schema




    pk=findpackage('fdadesignpanel');


    c=schema.class(pk,'freqmagripple',findclass(pk,'freqvector'));

    schema.prop(c,'MagnitudeVector','ustring');

    schema.prop(c,'RippleVector','ustring');


