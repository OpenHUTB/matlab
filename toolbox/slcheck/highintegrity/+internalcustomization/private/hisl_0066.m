function hisl_0066




    rec=getNewCheckObject('mathworks.hism.hisl_0066',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    gainBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Gain');
    gainBlocks=mdladvObj.filterResultWithExclusion(gainBlocks);
    flags=false(1,length(gainBlocks));


    for i=1:length(gainBlocks)
        try
            gainObj=get_param(gainBlocks{i},'Object');
            resGain=Advisor.Utils.Simulink.evalSimulinkBlockParameters(gainObj,'Gain');

            if~isempty(resGain)
                gainValueSize=size(resGain{1});


                if isscalar(resGain{1})&&resGain{1}==1
                    flags(i)=true;




                elseif~isscalar(resGain{1})

                    if isequal(resGain{1},eye(gainValueSize(1)))
                        flags(i)=true;
                    end

                    if isequal(resGain{1},ones(gainValueSize))
                        flags(i)=true;
                    end


                end
            end
        catch ME %#ok<NASGU>


        end
    end

    flags2=cellfun(@isBlockValid,gainBlocks);
    if size(flags2,1)~=1
        flags2=flags2';
    end

    FailingObjs=gainBlocks(flags&flags2);
end

function bResult=isBlockValid(block)
    bResult=true;
    try
        get_param(block,'handle');
    catch
        bResult=false;
        return;
    end
end
