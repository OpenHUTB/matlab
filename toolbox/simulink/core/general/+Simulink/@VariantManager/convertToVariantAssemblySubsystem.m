function convertToVariantAssemblySubsystem(vssBlkPathOrHandle,folderPathToKeepNewSSFiles)


















































    if nargin==1
        err=Simulink.variant.vas.VSSToVASConverter.convertToVariantAssemblyInternal(...
        vssBlkPathOrHandle);
    else
        err=Simulink.variant.vas.VSSToVASConverter.convertToVariantAssemblyInternal(...
        vssBlkPathOrHandle,folderPathToKeepNewSSFiles);
    end

    if~isempty(err)
        err.throwAsCaller();
    end
end


