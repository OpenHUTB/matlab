function AnalyticalInputUnits(model)






    modelWorkspace=get_param(model,'ModelWorkspace');
    blockName=[model,'/',modelWorkspace.getVariable('newTestBlockName')];


    analyticalMethodInput=[model,'/Analytical parameterization'];


    pressureUnit=get_param(blockName,'pr_nominal_unit');
    omegaUnit=get_param(blockName,'w_nominal_unit');


    maskPrompts={['Pressure difference vector (',pressureUnit,')'],...
    ['Angular velocity vector (',omegaUnit,')']};
    set_param(analyticalMethodInput,'MaskPrompts',maskPrompts);

    open_system(analyticalMethodInput);

end


