function updateDeps=sldvLaunchVariantManager(cs,~)








    updateDeps=false;

    mdlH=cs.getModel;
    if isempty(mdlH)
        return;
    end

    modelName=get_param(mdlH,'name');


    Simulink.variant.utils.launchVariantManager('Create',modelName);
end
