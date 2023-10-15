function buildOptions = getBuildOptions( blockHandle )

arguments
    blockHandle
end

blockHandle = Simulink.SFunctionBuilder.internal.verifyBlockHandle( blockHandle );

AppData = Simulink.SFunctionBuilder.internal.getApplicationData( blockHandle );
buildOptions = struct(  ...
    'ShowCompileSteps', AppData.SfunWizardData.ShowCompileSteps,  ...
    'CreateDebuggableMEX', AppData.SfunWizardData.CreateDebugMex,  ...
    'GenerateWrapperTLC', AppData.SfunWizardData.GenerateTLC,  ...
    'EnableSupportForCoverage', AppData.SfunWizardData.SupportCoverage,  ...
    'EnableSupportForDesignVerifier', AppData.SfunWizardData.SupportSldv );
end

