function jmaab_jc_0794




    options.objectiveTypes='Division by zero';
    options.blockFinderFcn=@FindBlocks;
    options.sldvOpts={'DetectDivisionByZero','on'};

    rec=ModelAdvisor.SLDVCheck('mathworks.jmaab.jc_0794',options);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license,'Simulink_Design_Verifier'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_jmaab_group,sg_maab_group});
end

function blocks=FindBlocks(system)

    mObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mObj.getInputParameters;



    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'type','block');
    blocks=Simulink.ID.getSID(blocks(cellfun(@(x)~Stateflow.SLUtils.isStateflowBlock(x),blocks)));

end
