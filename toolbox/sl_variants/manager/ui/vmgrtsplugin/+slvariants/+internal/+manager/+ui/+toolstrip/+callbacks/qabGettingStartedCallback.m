function qabGettingStartedCallback(cbinfo)






    modelHandle=cbinfo.Context.Object.getModelHandle();
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    helpPIComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:HelpTitle').getString());

    if helpPIComp.isMinimized
        helpPIComp.restore;
    else
        helpPIComp.minimize;
    end



end
