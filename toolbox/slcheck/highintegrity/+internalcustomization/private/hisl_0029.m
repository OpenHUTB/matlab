function hisl_0029




    rec=getNewCheckObject('mathworks.hism.hisl_0029',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';


    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)

    violations=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    allBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Assignment');
    allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);

    for i=1:numel(allBlocks)

        indexOptions=get_param(allBlocks{i},'IndexOptionArray');
        for dimensionIndex=1:length(indexOptions)
            if~(strcmp(indexOptions{dimensionIndex},'Index vector (port)')||strcmp(indexOptions{dimensionIndex},'Starting index (port)'))
                continue;
            end

            outputInitialize=get_param(allBlocks{i},'OutputInitialize');
            if strcmp(outputInitialize,'Specify size for each dimension in table')
                diagnosticProperty=get_param(allBlocks{i},'DiagnosticForDimensions');
                if isWithinForWhileIterator(allBlocks{i})
                    if strcmp(diagnosticProperty,'None')

                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'Block',allBlocks{i},'Parameter','DiagnosticForDimensions','CurrentValue',diagnosticProperty,'RecommendedValue','Warning');
                        violations=[violations;vObj];%#ok<AGROW>
                        break;
                    end
                else
                    if~strcmp(diagnosticProperty,'Error')

                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'Block',allBlocks{i},'Parameter','DiagnosticForDimensions','CurrentValue',diagnosticProperty,'RecommendedValue','Error');
                        violations=[violations;vObj];%#ok<AGROW>
                        break;
                    end
                end
            end
        end
    end

end

function result=isWithinForWhileIterator(thisBlock)
    root=bdroot(thisBlock);
    parent=get_param(thisBlock,'Parent');
    result=false;
    while~strcmp(parent,root)
        whileIterators=find_system(parent,...
        'SearchDepth',1,...
        'Type','Block',...
        'BlockType','WhileIterator');
        forIterators=find_system(parent,...
        'SearchDepth',1,...
        'Type','Block',...
        'BlockType','ForIterator');
        if~isempty(whileIterators)||~isempty(forIterators)
            result=true;
            break;
        end
        parent=get_param(parent,'Parent');
    end
end
