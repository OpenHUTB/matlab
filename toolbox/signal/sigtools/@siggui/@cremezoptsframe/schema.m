function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'cremezoptsframe',pk.findclass('remezoptionsframe'));



    findclass(findpackage('filtdes'),'cremez');

    schema.prop(c,'SymmetryConstraint','cremezSymmetryConstraint');
    p=schema.prop(c,'SecondStageOptimization','on/off');
    set(p,'FactoryValue','On');


