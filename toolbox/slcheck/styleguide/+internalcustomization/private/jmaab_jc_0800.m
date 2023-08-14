function jmaab_jc_0800







    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0800');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0800_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0800';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0800',@CheckAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0800_tip');
    rec.setLicense({styleguide_license});

    rec.Value=false;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;

    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end




function failedBlocks=CheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    relationOpBlk=find_system(system,'FollowLinks',inputParams{1}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',inputParams{2}.Value,...
    'RegExp','on',...
    'BlockType','RelationalOperator',...
    'Operator','(=|~)=');

    maskedRelationOpBlk1=find_system(system,'FollowLinks',inputParams{1}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',inputParams{2}.Value,...
    'RegExp','on',...
    'BlockType','SubSystem',...
    'MaskType','Compare To Zero',...
    'relop','(=|~)=');


    maskedRelationOpBlk2=find_system(system,'FollowLinks',inputParams{1}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',inputParams{2}.Value,...
    'RegExp','on',...
    'BlockType','SubSystem',...
    'MaskType','Compare To Constant',...
    'relop','(=|~)=');


    relationOpBlk=[relationOpBlk;maskedRelationOpBlk1;maskedRelationOpBlk2];

    relationOpBlk=mdladvObj.filterResultWithExclusion(relationOpBlk);

    bFlagIndex=false(1,numel(relationOpBlk));

    for countBlk=1:length(relationOpBlk)

        portTypes=get_param(relationOpBlk{countBlk},'CompiledPortDataTypes');

        if isempty(portTypes)
            continue;
        end

        inputType=portTypes.Inport;
        inputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,inputType);

        if any(ismember(inputType,{'double','single'}))
            bFlagIndex(countBlk)=true;
        end
    end

    failedBlocks=relationOpBlk(bFlagIndex);

end



