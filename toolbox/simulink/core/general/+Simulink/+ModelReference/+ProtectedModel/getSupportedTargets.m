function targets=getSupportedTargets(protectedModelFile)




    import Simulink.ModelReference.ProtectedModel.*;

    protectedModelFile=Simulink.ModelReference.ProtectedModel.getCharArray(protectedModelFile);
    [opts,~]=getOptions(protectedModelFile,'runConsistencyChecksNoPlatform');
    if isempty(opts)
        DAStudio.error('Simulink:protectedModel:ModelFileNotFound',protectedModelFile);
    end
    targets=keys(opts.targetToTargetInfoMap);

end