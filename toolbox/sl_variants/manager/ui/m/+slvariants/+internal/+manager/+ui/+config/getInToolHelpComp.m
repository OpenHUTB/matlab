function helpComp=getInToolHelpComp(modelHandle)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    helpComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:HelpTitle').getString());
end
