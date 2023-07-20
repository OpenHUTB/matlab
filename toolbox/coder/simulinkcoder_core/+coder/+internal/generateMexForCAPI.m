function generateMexForCAPI(codeWasUpToDate,modelName,lBuildInfo,...
    lModelReferenceTargetType,lTopOfBuildModel,lMdlRefsUpdated)






























    if Simulink.ModelReference.ProtectedModel.protectingModel(modelName)&&...
        coder.internal.ModelCAPIMgr.isCAPIEnabled(modelName)

        modelCAPISource=fullfile(pwd,[modelName,'_capi.c']);
        modelHostCAPIHeader=fullfile(pwd,[modelName,'_capi_host.h']);
        modelHostCAPISource=fullfile(pwd,[modelName,'_capi_host.c']);




        if isfile(modelCAPISource)&&isfile(modelHostCAPIHeader)



            copyfile(modelCAPISource,modelHostCAPISource);

            incDirs=cellfun(@(x)({['-I',x]}),lBuildInfo.getIncludePaths(true));


            mex('-c',...
            '-silent',...
            '-DHOST_CAPI_BUILD',...
            incDirs{:},...
            modelHostCAPISource);
        end
    end

    if strcmp(lModelReferenceTargetType,'NONE')&&...
        strcmp(lTopOfBuildModel,modelName)

        hostCAPIRequired=...
        coder.internal.ModelCAPIMgr.isHostBasedCAPIRequired(modelName);
        codeWasGenerated=...
        ~codeWasUpToDate||...
        lMdlRefsUpdated;

        if hostCAPIRequired&&codeWasGenerated
            coder.internal.buildHostCAPI(lBuildInfo);
        end
    end

end
