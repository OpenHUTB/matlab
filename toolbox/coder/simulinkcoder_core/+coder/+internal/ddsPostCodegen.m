function ddsPostCodegen(modelName,buildInfo,buildDirectory,modelReferenceTargetType,...
    isSimBuild,codeWasUpToDate)





    if strcmp(modelReferenceTargetType,'NONE')&&~codeWasUpToDate...
        &&~isSimBuild&&coder.internal.isDDSApp(modelName)
        dds.internal.coder.BuildHooksImpl.postCodeGen(modelName,buildInfo,buildDirectory);
    end
end

