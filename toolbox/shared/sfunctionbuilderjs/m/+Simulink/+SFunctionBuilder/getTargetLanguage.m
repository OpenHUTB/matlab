function language=getTargetLanguage(blockHandle)
    appdata=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
    language=appdata.SfunWizardData.LangExt;

end
