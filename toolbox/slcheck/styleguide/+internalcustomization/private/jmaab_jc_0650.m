function jmaab_jc_0650




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0650');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0650_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0650';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0650',@hCheckAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:jc_0650_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:jc_0650_tip'])];
    rec.setLicense({styleguide_license});
    rec.Value=false;

    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.SupportHighlighting=true;

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

function FailingObjs=hCheckAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    Switches=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','Switch');
    MultiSwitch=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value,'BlockType','MultiPortSwitch');
    AllSwitches=[Switches;MultiSwitch];

    AllSwitches=mdladvObj.filterResultWithExclusion(AllSwitches);

    flags=false(1,length(AllSwitches));
    for i=1:length(AllSwitches)
        swObj=get_param(AllSwitches{i},'Object');
        if isempty(swObj.CompiledPortDataTypes)
            continue;
        end
        iPortTypes=swObj.CompiledPortDataTypes.Inport;
        oPortType=swObj.CompiledPortDataTypes.Outport{1};
        if strcmp(swObj.BlockType,'Switch')

            iPortTypes=[iPortTypes(1),iPortTypes(3)];
        else

            iPortTypes=iPortTypes(2:end);
        end

        if~all(strcmp(iPortTypes,oPortType))
            flags(i)=true;
        end
    end

    FailingObjs=AllSwitches(flags);
end








