

















function modelInfo=getModelInfo(modelH)
    modelInfo=struct('SettingsChecksum','',...
    'FullChecksum','',...
    'LibPath','',...
    'SupportSldv','');


    allModels=find_mdlrefs(modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    modelInfo(numel(allModels)).Handle=-1.0;


    for modelIndex=1:numel(allModels)
        [ccSettingsChecksum,~,fullChecksum,ccLib]=cgxeprivate('computeCCChecksumFromModel',allModels{modelIndex});

        modelInfo(modelIndex).SettingsChecksum=ccSettingsChecksum;
        modelInfo(modelIndex).FullChecksum=fullChecksum;
        modelInfo(modelIndex).LibPath=ccLib;
        modelInfo(modelIndex).SupportSldv=isSldvCompatible(ccLib);
    end


    for modelIndex=1:numel(allModels)
        modelHandle=get_param(allModels{modelIndex},'Handle');
        libraryCCDeps=slcc('getCachedCustomCodeDependencies',modelHandle);
        if~isempty(libraryCCDeps)

            libraryCCDeps=libraryCCDeps(~strcmp(modelInfo(modelIndex).FullChecksum,{libraryCCDeps.FullChecksum}));
        end

        if~isempty(libraryCCDeps)
            startLibIndex=numel(modelInfo);
            modelInfo(end+numel(libraryCCDeps)).Handle=-1.0;
            for ii=1:numel(libraryCCDeps)

                libIndex=startLibIndex+ii;

                modelInfo(libIndex).SettingsChecksum=libraryCCDeps(ii).SettingsChecksum;
                modelInfo(libIndex).FullChecksum=libraryCCDeps(ii).FullChecksum;
                modelInfo(libIndex).LibPath=libraryCCDeps(ii).CustomCodeLibPath;
                modelInfo(libIndex).SupportSldv=isSldvCompatible(libraryCCDeps(ii).CustomCodeLibPath);
            end
        end
    end

    function isCompatible=isSldvCompatible(libPath)


        isCompatible=~isempty(libPath)&&...
        internal.slcc.cov.LibUtils.isCoverageCompatible(libPath);
