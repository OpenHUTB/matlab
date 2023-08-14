function IdentRecursiveEstimationBlocks(this)






    rlsBlocks=this.findLibraryLinksTo('slident/Estimators/Recursive Least Squares Estimator');




    rlsBlocks=vertcat(...
    rlsBlocks,...
    find_system(this.modelName,...
    'LookUnderMasks','all','IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','ctrlSharedLib/Recursive Least Squares Estimator')...
    );
    rpolyBlocks=find_system(this.modelName,...
    'LookUnderMasks','all','IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'ReferenceBlock','slident/Estimators/Recursive Polynomial Model Estimator');

    if isR2017aOrEarlier(this.ver)



        local2017aOrEarlierWarnings(rlsBlocks,this.modelName,this.origModelName);
        local2017aOrEarlierWarnings(rpolyBlocks,this.modelName,this.origModelName);
    end

    if isR2015aOrEarlier(this.ver)






        local2015aOrEarlierWarnings(rlsBlocks,this.modelName,this.origModelName);
        local2015aOrEarlierWarnings(rpolyBlocks,this.modelName,this.origModelName);
    end

    if isR2014aOrEarlier(this.ver)



        for kk=1:numel(rpolyBlocks)
            modelStructure=get_param(rpolyBlocks{kk},'ModelStructure');
            if ismember(modelStructure,...
                {getString(message('Ident:simulink:recursiveEstimationMaskAR')),...
                getString(message('Ident:simulink:recursiveEstimationMaskARMA')),...
                getString(message('Ident:simulink:recursiveEstimationMaskOE')),...
                getString(message('Ident:simulink:recursiveEstimationMaskBJ'))})

                blockPath=strrep(rpolyBlocks{kk},this.modelName,this.origModelName);
                MSLDiagnostic('Controllib:blocks:recursiveEstimationExportToPreviousVersionUnsupportedModelStructure',modelStructure,blockPath).reportAsWarning;
                set_param(rpolyBlocks{kk},'ModelStructure',getString(message('Ident:simulink:recursiveEstimationMaskARX')));
            end
        end
    end
end

function local2015aOrEarlierWarnings(blockList,tempModelName,originalModelName)

    for kk=1:numel(blockList)
        val=get_param(blockList{kk},'NormalizationBias');
        if~strcmp(val,'eps')
            blockPath=strrep(blockList{kk},tempModelName,originalModelName);
            MSLDiagnostic('Controllib:blocks:recursiveEstimationExportToPreviousVersionNormalizationBias',blockPath).reportAsWarning;
        end
    end
end

function local2017aOrEarlierWarnings(blockList,tempModelName,originalModelName)

    for kk=1:numel(blockList)
        val=get_param(blockList{kk},'HasTimeVaryingAdaptationParameter');
        if~strcmp(val,'off')
            blockPath=strrep(blockList{kk},tempModelName,originalModelName);
            MSLDiagnostic('Controllib:blocks:recursiveEstimationExportToPreviousVersionHasTimeVaryingAdaptationParameter',blockPath).reportAsWarning;
        end
    end
end
