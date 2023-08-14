function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'ifiroptsframe',pk.findclass('abstractoptionsframe'));

    p=schema.prop(c,'InterpolationFactor','ustring');
    set(p,'FactoryValue','5');


    findclass(findpackage('filtdes'),'ifir');

    p=schema.prop(c,'Optimization','ifirOptimization');
    set(p,'FactoryValue','intermediate');


