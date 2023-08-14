function hisl_0101




    options.objectiveTypes={'Condition','Decision'};
    options.objectiveStatus='Dead Logic';
    options.blockFinderFcn=@FindObjects;
    options.sldvOpts={'DetectDeadLogic','on'};

    rec=ModelAdvisor.SLDVCheck('mathworks.hism.hisl_0101',options);

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
    fl=inputParams{1}.Value;
    lum=inputParams{2}.Value;



    blocks=Simulink.ID.getSID(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',fl,'LookUnderMasks',lum));
    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,fl,lum,{},true);
    if~isempty(sfObjs)
        sfObjs=cellfun(@Simulink.ID.getSID,sfObjs,'UniformOutput',false);
        blocks=[blocks;sfObjs];
    end

    entities=unique(blocks);

end
