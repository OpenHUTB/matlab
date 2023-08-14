function out=doesProtectedModelHaveEncryptedContents(model)




    [opts,~]=Simulink.ModelReference.ProtectedModel.getOptions(model,'runConsistencyChecksNoPlatform');
    out=opts.isSimEncrypted||opts.isRTWEncrypted||opts.isViewEncrypted||opts.isHDLEncrypted;
end

