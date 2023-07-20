function hisl_0010




    rec=getNewCheckObject('mathworks.hism.hisl_0010',false,@hCheckAlgo,'PostCompile');

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

function violations=hCheckAlgo(system)

    violations={};

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;




    allBlks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','If');
    allBlks=mdlAdvObj.filterResultWithExclusion(allBlks);


    for i=1:numel(allBlks)

        hasElseIf=~strcmp('',deblank(get_param(allBlks{i},'ElseIfExpressions')));
        doesNotHaveElse=strcmp('off',get_param(allBlks{i},'ShowElse'));
        badCon=hasElseIf&doesNotHaveElse;
        if badCon
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',allBlks{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0010_rec_action1');
            tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0010_warn1');
            violations=[violations,tempFailObj];%#ok<AGROW>
        end


        if~isConnectedToSubSys(allBlks{i})
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',allBlks{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0010_rec_action2');
            tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0010_warn2');
            violations=[violations,tempFailObj];%#ok<AGROW>
        end
    end
end

function bResult=isConnectedToSubSys(block)




    portCons=get_param(block,'PortConnectivity');
    bResult=true;
    for j=1:length(portCons)
        if~isempty(portCons(j).SrcBlock)
            continue;
        end
        if isempty(portCons(j).DstBlock)
            bResult=false;
            return;
        else

            dstBlock=get_param(portCons(j).DstBlock,'BlockType');
            if(strcmp(dstBlock,'Terminator'))
                bResult=false;
                return;
            end
        end
    end
end
