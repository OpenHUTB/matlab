function configsComp=getConfigurationsComp(modelHandle)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    configsComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:ConfigsTitle').getString());
end


