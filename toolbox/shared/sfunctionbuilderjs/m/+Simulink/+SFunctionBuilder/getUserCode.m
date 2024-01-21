function code=getUserCode(blockHandle,block)
    AppData=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
    switch(block)
    case 'includes'
        code=AppData.SfunWizardData.IncludeHeadersText;
    case 'externs'
        code=AppData.SfunWizardData.ExternalDeclaration;
    case 'start'
        code=AppData.SfunWizardData.UserCodeTextmdlStart;
    case 'output'
        code=AppData.SfunWizardData.UserCodeText;
    case 'update'
        code=AppData.SfunWizardData.UserCodeTextmdlUpdate;
    case 'derivatives'
        code=AppData.SfunWizardData.UserCodeTextmdlDerivative;
    case 'terminate'
        code=AppData.SfunWizardData.UserCodeTextmdlTerminate;
    end
end

