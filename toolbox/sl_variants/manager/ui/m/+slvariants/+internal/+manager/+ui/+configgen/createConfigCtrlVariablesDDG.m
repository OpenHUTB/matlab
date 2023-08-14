function configureCtrlVarDDGComp=createConfigCtrlVariablesDDG(modelHandle)




    modelName=getfullname(modelHandle);
    configureCtrlVarDDGComp=GLUE2.DDGComponent(message('Simulink:VariantManagerUI:AutoGenConfigureControlVariablesDDG').getString());
    configureCtrlVarDDGComp.Title=message('Simulink:VariantManagerUI:AutoGenConfigureControlVariablesTitle').getString();
    configureCtrlVarDDGComp.UserFloatable=false;
    newDialogSource=slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesDialogSchema({},modelName);
    configureCtrlVarDDGComp.updateSource(newDialogSource);
    studioContainer=slvariants.internal.manager.core.getStudioContainer(modelHandle);
    studioContainer.addComponent(configureCtrlVarDDGComp,'left','tabbed');
end
