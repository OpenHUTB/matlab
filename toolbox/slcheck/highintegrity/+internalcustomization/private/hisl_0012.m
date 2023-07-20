function hisl_0012




    rec=getNewCheckObject('mathworks.hism.hisl_0012',false,@hCheckAlgo,'PostCompile');

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


    act=ModelAdvisor.Action;
    act.setCallbackFcn(@checkActionCallBack);
    act.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    act.Description=DAStudio.message('ModelAdvisor:hism:hisl_0012_action_description');
    act.Enable=false;
    rec.setAction(act);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    violations=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    allSubSys=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','SubSystem');
    allSubSys=mdladvObj.filterResultWithExclusion(allSubSys);


    for i=1:length(allSubSys)
        if~isConditionalSubsys(allSubSys{i})
            continue;
        end






        allBlocks=find_system(allSubSys{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'type','block');

        for j=1:length(allBlocks)

            blocktype=get_param(allBlocks{j},'BlockType');
            if ismember(blocktype,{'EnablePort','TriggerPort','ActionPort'})
                continue;
            end

            try

                sampleTime=Advisor.Utils.Simulink.evalSimulinkBlockParameters(allBlocks{j},'SampleTime');
                if strcmp(blocktype,'Constant')||strcmp(get_param(allBlocks{j},'MaskType'),'Enumerated Constant')
                    if all(sampleTime{1}~=-1)&&all(~isinf(sampleTime{1}))
                        tempObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(tempObj,'SID',allBlocks{j});
                        tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0012_rec_action1');
                        tempObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0012_warn1');
                        violations=[violations;tempObj];%#ok<AGROW>
                    end

                else
                    if sampleTime{1}~=-1
                        tempObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(tempObj,'SID',allBlocks{j});
                        tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0012_rec_action2');
                        tempObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0012_warn1');
                        violations=[violations;tempObj];%#ok<AGROW>
                    end
                end
            catch

            end


            if isSTIBlockAsync(allBlocks{j})
                tempObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(tempObj,'SID',allBlocks{j});
                tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0012_rec_action2');
                tempObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0012_warn2');
                violations=[violations;tempObj];%#ok<AGROW>
            end
        end
    end
end

function bResult=isConditionalSubsys(block)
    pH=get_param(block,'PortHandles');
    if~isempty(pH.Enable)||~isempty(pH.Trigger)||~isempty(pH.Ifaction)
        bResult=true;
        return;
    end
    bResult=false;
end

function bResult=isSTIBlockAsync(block)
    bResult=false;

    STDBlocks=ModelAdvisor.Common.getSampleTimeDependentBlocks;

    if any(cellfun(@(x)all(strcmp({get_param(block,'BlockType'),get_param(block,'MaskType')},x)),num2cell(STDBlocks,2)))
        compiledSampleTime=get_param(block,'CompiledSampleTime');
        if iscell(compiledSampleTime)
            bResult=all(cellfun(@(x)x(1)==-1&&x(2)<=-1,compiledSampleTime));
        else
            bResult=compiledSampleTime(1)==-1&&compiledSampleTime(2)<=-1;
        end
    end
end

function result=checkActionCallBack(~)
    result=ModelAdvisor.Paragraph;
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
    mdladvObj.setActionEnable(false);
    ch_result=mdladvObj.getCheckResult('mathworks.hism.hisl_0012');
    FailingObjs=ch_result{1}.ListObj;

    flag=true(1,numel(FailingObjs));
    for i=1:length(FailingObjs)
        if isSTIBlockAsync(FailingObjs{i})
            flag(i)=false;
            continue;
        end
        try
            set_param(FailingObjs{i},'SampleTime','-1');
        catch
            flag(i)=false;
        end
    end

    if any(flag==true)
        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubBar(any(flag==false));
        ft.setInformation(DAStudio.message('ModelAdvisor:hism:hisl_0012_action_info'));
        ft.setListObj(FailingObjs(flag));
        result.addItem(ft.emitContent);
    end
    if any(flag==false)
        ft1=ModelAdvisor.FormatTemplate('ListTemplate');
        ft1.setSubBar(0);
        ft1.setInformation(DAStudio.message('ModelAdvisor:hism:hisl_0012_action_unmodified'));
        ft1.setListObj(FailingObjs(~flag));
        result.addItem(ft1.emitContent);
    end

end
