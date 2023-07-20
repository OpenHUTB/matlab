function setUserCode(blockHandle,block,code)




    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();

    cliView=struct('publishChannel','cli');
    sfcnmodel.registerView(blockHandle,cliView);
    AppData=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);

    switch(block)
    case 'includes'
        AppData.SfunWizardData.IncludeHeadersText=code;
    case 'externs'
        AppData.SfunWizardData.ExternalDeclaration=code;
    case 'start'
        AppData.SfunWizardData.UserCodeTextmdlStart=code;
    case 'output'
        AppData.SfunWizardData.UserCodeText=code;
    case 'update'
        AppData.SfunWizardData.UserCodeTextmdlUpdate=code;
    case 'derivatives'
        AppData.SfunWizardData.UserCodeTextmdlDerivative=code;
    case 'terminate'
        AppData.SfunWizardData.UserCodeTextmdlTerminate=code;
    end

    sfbController.updateUserCode(blockHandle,AppData.SfunWizardData,true);


    sfcnmodel.unregisterView(blockHandle,cliView);
end
