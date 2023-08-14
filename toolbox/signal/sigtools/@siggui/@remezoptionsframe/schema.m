function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'remezoptionsframe',pk.findclass('abstractoptionsframe'));


    p=schema.prop(c,'DensityFactor','ustring');
    p.FactoryValue='20';


