function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'cremezinvsincoptsframe',pk.findclass('cremezoptsframe'));

    p=schema.prop(c,'invSincFreqFactor','ustring');
    set(p,'FactoryValue','1');


