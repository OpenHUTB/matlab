




function launchAdvisor(system)
    modeladvisor(system);
    ma=Simulink.ModelAdvisor.getModelAdvisor(system);

    if isempty(ma)
        DAStudio.error('Simulink:VariantAdvisorChecks:MAEmptyObjectError');
        return;
    end

    model_exp=ma.MAExplorer;
    if~isempty(model_exp)
        im_exp=DAStudio.imExplorer(model_exp);
        replaceEnvCtrlBlkCheck=ma.getTaskObj('_SYSTEM_By Product_Simulink_mathworks.design.ReplaceEnvironmentControllerBlk');
        im_exp.selectTreeViewNode(replaceEnvCtrlBlkCheck);
    end
end