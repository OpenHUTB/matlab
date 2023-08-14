function hisl_0067




    options.objectiveTypes='Division by zero';
    options.blockFinderFcn=@FindObjects;
    options.sldvOpts={'DetectDivisionByZero','on'};

    rec=ModelAdvisor.SLDVCheck('mathworks.hism.hisl_0067',options);

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

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setLicense({HighIntegrity_License,'Simulink_Design_Verifier'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function entities=FindObjects(system)

    mObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mObj.getInputParameters;



    blocks=Simulink.ID.getSID(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value));
    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{},true);
    if~isempty(sfObjs)
        sfObjs=cellfun(@Simulink.ID.getSID,sfObjs,'UniformOutput',false);
        blocks=[blocks;sfObjs];
    end

    entities=unique(blocks);

end
