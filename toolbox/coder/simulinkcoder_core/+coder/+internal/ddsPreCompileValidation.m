function ddsPreCompileValidation(modelName,modelReferenceTargetType,isSimBuild)





    if strcmp(modelReferenceTargetType,'NONE')&&~isSimBuild&&coder.internal.isDDSApp(modelName)
        dds.internal.coder.Validation.preCompileValidate(modelName);
    end
end

