function hisl_0002




    options.objectiveTypes='Hisl_0002';
    options.blockFinderFcn=@FindEntities;
    options.sldvOpts={'DetectBlockConditions','HISL_0002'};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.hism.hisl_0002',options);

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

    rec.setLicense({HighIntegrity_License,'Simulink_Design_Verifier','Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function entities=FindEntities(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    fl=inputParams{1}.Value;
    lum=inputParams{2}.Value;


    blocks=Simulink.ID.getSID(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'RegExp','on','FollowLinks',fl,'LookUnderMasks',lum,'BlockType','Math','Operator','rem|reciprocal'));
    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,fl,lum,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition','-or','-isa','Stateflow.TruthTable','-or','-isa','StateTransitionTableChart'},true);
    if~isempty(sfObjs)
        sfObjs=cellfun(@Simulink.ID.getSID,sfObjs,'UniformOutput',false);
        blocks=[blocks;sfObjs];
    end

    entities=unique(blocks);
end
