function jmaab_jc_0752

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0752');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0752_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0752';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0752',@hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0752_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
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



function FailedObjs=hCheckAlgo(system)
    FailedObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    sfTransitions=mdlAdvObj.filterResultWithExclusion(...
    Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,...
    {'-isa','Stateflow.Transition'}));

    if isempty(sfTransitions)
        return;
    end

    sfTransitions=mdlAdvObj.filterResultWithExclusion(sfTransitions);
    flaggedTransitions=false(1,length(sfTransitions));

    for k=1:length(sfTransitions)
        if ModelAdvisor.internal.styleguide_jmaab_0752(sfTransitions{k}.LabelString)
            flaggedTransitions(k)=true;
        end
    end
    FailedObjs=sfTransitions(flaggedTransitions);
end
