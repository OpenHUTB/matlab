function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'textfreqspecs',pk.findclass('freqframe'));
    set(c,'Description','Frequency Specifications');


    p=schema.prop(c,'Text','string vector');


