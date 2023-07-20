function hisl_0033




    rec=getNewCheckObject('mathworks.hism.hisl_0033',false,@hCheckAlgo,'None');
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

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    modifyAction=ModelAdvisor.Action;
    modifyAction.setCallbackFcn(@ModifyLookupTableBlocksCallback);
    modifyAction.Name=DAStudio.message('Advisor:engine:CCModifyButton');
    modifyAction.Description=DAStudio.message('ModelAdvisor:hism:hisl_0033_action_description');
    modifyAction.Enable=true;
    rec.setAction(modifyAction);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function violations=hCheckAlgo(system)

    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;





    commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{1}.Value,...
    'LookUnderMasks',inputParams{2}.Value};

    ndBlks=find_system(system,commonArgs{:},'BlockType','Lookup_n-D');
    plBlks=find_system(system,commonArgs{:},'BlockType','PreLookup');
    ipBlks=find_system(system,commonArgs{:},'BlockType','Interpolation_n-D');
    allBlocks=[ndBlks;plBlks;ipBlks];
    allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);

    for i=1:length(allBlocks)
        if strcmp(get_param(allBlocks{i},'BlockType'),'Interpolation_n-D')
            param='RemoveProtectionIndex';
        else
            param='RemoveProtectionInput';
        end

        if strcmp(get_param(allBlocks{i},param),'on')
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Block',allBlocks{i},'Parameter',param,'CurrentValue',get_param(allBlocks{i},param),'RecommendedValue','off');
            violations=[violations;vObj];%#ok<AGROW>
        end
    end

end



function result=ModifyLookupTableBlocksCallback(taskobj)

    mdladvObj=taskobj.MAObj;
    mdladvObj.setActionEnable(false);
    ch_result=mdladvObj.getCheckResult(taskobj.MAC);
    allBlocks=ch_result{1}.TableInfo(:,1);

    for i=1:length(allBlocks)
        if strcmp(get_param(allBlocks{i},'BlockType'),'Interpolation_n-D')
            param='RemoveProtectionIndex';
        else
            param='RemoveProtectionInput';
        end
        set_param(allBlocks{i},param,'off');
    end


    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);
    ft.setInformation(DAStudio.message('ModelAdvisor:hism:hisl_0033_action_pass'));
    ft.setListObj(allBlocks);
    result=ft;

end
