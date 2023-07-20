function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'magtext',pk.findclass('abstract_specsframe'));
    set(c,'Description','Magnitude Specifications');


    p=schema.prop(c,'text','string vector');


