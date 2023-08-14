function name=getSFunctionName(blockHandle)




    appdata=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
    name=appdata.SfunWizardData.SfunName;

end
