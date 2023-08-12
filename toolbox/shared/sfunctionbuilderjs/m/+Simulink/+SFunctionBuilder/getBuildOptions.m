function buildOptions = getBuildOptions( blockHandle )




R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgoi0Y_.p.
% Please follow local copyright laws when handling this file.

