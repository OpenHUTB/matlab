function constrsComp=getConstraintsComp(modelHandle)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    constrsComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:ConstraintsTitle').getString());
end