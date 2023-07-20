function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'ellipoptsframe',pk.findclass('abstractoptionsframe'));

    schema.prop(c,'MatchExactly','passstoporboth');


