function transOpts=getTranslationOptions(sldvOpts,modelH)




    transOpts=sldvOpts.getCompatibilityOptions();


    if strcmp(transOpts.BlockReplacement.BlockReplacement,'off')
        transOpts=rmfield(transOpts,'BlockReplacement');
    end












    transOpts=rmfield(transOpts,'Parameters');



    if~strcmp(sldvOpts.ParameterConfiguration,'None')

        transOpts.Parameters.parameterSettings=sldvshareprivate('parameters','getall',modelH);





























        if sldvprivate('mdl_has_unsupported_items',modelH)
            transOpts.Parameters.parameterSettings=[];
            sldvshareprivate('parameters','clearCachedParams',modelH);
        end
    end


    if strcmp(transOpts.General.Mode,'TestGeneration')

        transOpts=rmfield(transOpts,'ErrorDetection');

        if strcmp(transOpts.TestGeneration.IncludeRelationalBoundary,'off')
            transOpts.TestGeneration=rmfield(transOpts.TestGeneration,{'RelativeTolerance','AbsoluteTolerance'});
        end

        if~strcmp(transOpts.TestGeneration.ModelCoverageObjectives,'EnhancedMCDC')
            transOpts.TestGeneration=rmfield(transOpts.TestGeneration,'StrictEnhancedMCDC');
        end
        if any(strcmp(transOpts.TestGeneration.ModelCoverageObjectives,{'MCDC','EnhancedMCDC'}))

            insertMcdcRelatedParamValuesToTransOpts('TestGeneration');
        end
    elseif strcmp(transOpts.General.Mode,'PropertyProving')
        transOpts=rmfield(transOpts,{'TestGeneration','ErrorDetection'});
    else
        transOpts=rmfield(transOpts,'TestGeneration');

        if strcmp(transOpts.ErrorDetection.DetectDeadLogic,'off')
            transOpts.ErrorDetection=rmfield(transOpts.ErrorDetection,{'DetectActiveLogic','DeadLogicObjectives'});
        elseif strcmp(transOpts.ErrorDetection.DeadLogicObjectives,'MCDC')

            insertMcdcRelatedParamValuesToTransOpts('ErrorDetection');
        end
    end

    function insertMcdcRelatedParamValuesToTransOpts(mode)

        transOpts.(mode).CovLogicBlockShortCircuit=get_param(modelH,'CovLogicBlockShortCircuit');
        transOpts.(mode).CovMcdcMode=get_param(modelH,'CovMcdcMode');
    end
end
