








function[customCodeInfo,userIncludes,userSources]=getMergedCustomCodeInfo(modelName)
    hasReferencedCode=false;



    referencedModels=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    depInfo={};

    for ii=1:numel(referencedModels)
        currentInfo=slccprivate('getAllCCDependencyInfoFromModel',referencedModels{ii});
        depInfo=[depInfo(:);currentInfo(:)];
    end

    customCodeInfo=CGXE.CustomCode.CustomCodeSettings();
    userIncludes={};
    userSources={};
    userLibraries={};

    isFirstCustomCodeInfo=true;

    handledChecksums=containers.Map('KeyType','char','ValueType','char');
    for index=1:numel(depInfo)
        if~isempty(depInfo{index})&&~handledChecksums.isKey(depInfo{index}.fullCheckSum)


            checksum=depInfo{index}.fullCheckSum;
            handledChecksums(checksum)=checksum;

            ccInfo=depInfo{index}.ccInfo;

            mdlCustomCodeInfo=ccInfo.customCodeSettings;

            if mdlCustomCodeInfo.hasCustomCode()
                hasReferencedCode=true;

                if mdlCustomCodeInfo.isCpp
                    customCodeInfo.isCpp=true;
                end

                mdlIncludes=mdlCustomCodeInfo.userIncludeDirs;
                mdlSources=mdlCustomCodeInfo.userSources;
                mdlDefines=mdlCustomCodeInfo.customUserDefines;
                mdlLibs=mdlCustomCodeInfo.userLibraries;

                if~isempty(mdlIncludes)
                    userIncludes=[userIncludes(:);mdlIncludes(:)];
                end

                if~isempty(mdlSources)
                    userSources=[userSources(:);mdlSources(:)];
                end

                if~isempty(mdlDefines)
                    customCodeInfo.customUserDefines=sprintf('%s %s',customCodeInfo.customUserDefines,mdlDefines);
                end

                if~isempty(mdlLibs)
                    userLibraries=[userLibraries(:);mdlLibs(:)];
                end

                if~isempty(mdlCustomCodeInfo.customCode)
                    customCodeInfo.customCode=sprintf('%s\n\n/* Custom code */\n%s\n',...
                    customCodeInfo.customCode,...
                    mdlCustomCodeInfo.customCode);
                end

                if~isempty(mdlCustomCodeInfo.customSourceCode)
                    customCodeInfo.customSourceCode=sprintf('%s\n\n/* Custom source code */\n%s\n',...
                    customCodeInfo.customSourceCode,...
                    mdlCustomCodeInfo.customSourceCode);
                end

                if~isempty(mdlCustomCodeInfo.customInitializer)
                    customCodeInfo.customInitializer=sprintf('%s\n\n/* Custom initializer */\n%s\n',...
                    customCodeInfo.customInitializer,...
                    mdlCustomCodeInfo.customInitializer);
                end

                if~isempty(mdlCustomCodeInfo.customTerminator)
                    customCodeInfo.customTerminator=sprintf('%s\n\n/* Custom terminator */\n%s\n',...
                    customCodeInfo.customTerminator,...
                    mdlCustomCodeInfo.customTerminator);
                end

                if mdlCustomCodeInfo.parseCC
                    customCodeInfo.parseCC=true;
                end

                if mdlCustomCodeInfo.analyzeCC
                    customCodeInfo.analyzeCC=true;
                end

                if isempty(customCodeInfo.defaultFunctionArrayLayout)
                    customCodeInfo.defaultFunctionArrayLayout=mdlCustomCodeInfo.defaultFunctionArrayLayout;
                elseif~isempty(mdlCustomCodeInfo.defaultFunctionArrayLayout)&&...
                    ~strcmp(mdlCustomCodeInfo.defaultFunctionArrayLayout,'NotSpecified')
                    if strcmp(customCodeInfo.defaultFunctionArrayLayout,'Any')
                        customCodeInfo.defaultFunctionArrayLayout=mdlCustomCodeInfo.defaultFunctionArrayLayout;
                    elseif~strcmp(customCodeInfo.defaultFunctionArrayLayout,mdlCustomCodeInfo.defaultFunctionArrayLayout)&&...
                        ~strcmp(mdlCustomCodeInfo.defaultFunctionArrayLayout,'Any')
                        error(message('sldv_sfcn:sldv_slcc:differentCustomCodeArrayLayout'));
                    end
                end

                if isFirstCustomCodeInfo
                    customCodeInfo.functionNameToArrayLayout=mdlCustomCodeInfo.functionNameToArrayLayout;
                    isFirstCustomCodeInfo=false;
                elseif~isempty(customCodeInfo.functionNameToArrayLayout)||...
                    ~isempty(mdlCustomCodeInfo.functionNameToArrayLayout)
                    error(message('sldv_sfcn:sldv_slcc:modelReferenceWithFunctionLayout'));
                end
            end
        end
    end


    if hasReferencedCode
        userIncludes=unique(userIncludes,'stable');
        userSources=unique(userSources,'stable');
        userLibraries=unique(userLibraries,'stable');
    end

    customCodeInfo.setUserIncludeDirs(userIncludes);
    customCodeInfo.setUserSources(userSources);
    customCodeInfo.setUserLibraries(userLibraries);


