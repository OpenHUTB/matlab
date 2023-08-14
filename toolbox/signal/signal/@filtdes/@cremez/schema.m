function schema





    pk=findpackage('filtdes');

    c=schema.class(pk,'cremez',pk.findclass('abstractSingleOrderMethod'));


    p=schema.prop(c,'DensityFactor','spt_uint32');
    set(p,'FactoryValue',25);

    if isempty(findtype('cremezSymmetryConstraint'))
        schema.EnumType('cremezSymmetryConstraint',{'Default','None','Even','Odd','Real'});
    end

    schema.prop(c,'SymmetryConstraint','cremezSymmetryConstraint');
    p=schema.prop(c,'SecondStageOptimization','on/off');
    set(p,'FactoryValue','On');

    if isempty(findtype('cremezDebugMode'))
        schema.EnumType('cremezDebugMode',{'Off','Trace','Plots','Both'});
    end

    schema.prop(c,'DebugMode','cremezDebugMode');


