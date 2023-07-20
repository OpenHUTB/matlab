function addCustomCodeGenFiles(modelName,customFileRecords,protectSrc)




















    if~isstruct(customFileRecords)
        DAStudio.error('Simulink:protectedModel:ProtectedModelCustomRelInvalidArgument',2);
    end
    if~isfield(customFileRecords,'sourceFile')
        DAStudio.error('Simulink:protectedModel:ProtectedModelCustomRelInvalidArgument',2);
    end
    if~isfield(customFileRecords,'destinationPath')
        DAStudio.error('Simulink:protectedModel:ProtectedModelCustomRelInvalidArgument',2);
    end
    if~islogical(protectSrc)
        DAStudio.error('Simulink:protectedModel:ProtectedModelCustomRelInvalidArgument',3);
    end

    creator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(modelName);




    if isempty(creator)
        DAStudio.error('Simulink:protectedModel:NotProtectingModel');
    end
    if~creator.supportsCodeGen()
        DAStudio.error('Simulink:protectedModel:ProtectedModelCustomRelRTWOnly');
    end

    creator.addCustomFiles(customFileRecords,protectSrc);
end


