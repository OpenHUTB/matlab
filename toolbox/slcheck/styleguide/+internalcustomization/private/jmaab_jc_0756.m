function jmaab_jc_0756

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0756');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0756_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0756';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0756',@hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0756_tip');
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
    mdladvRoot.publish(rec,sg_jmaab_group);
end



function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    sfElements=Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'});

    if isempty(sfElements)
        return;
    end

    sfData=Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,...
    {'-isa','Stateflow.Data'});
    if~isempty(sfData)
        sfData=cellfun(@(x)x.Name,sfData,'UniformOutput',false);
    end

    sfElements=mdlAdvObj.filterResultWithExclusion(sfElements);
    flaggedElements=false(1,length(sfElements));

    for k=1:length(sfElements)

        if isempty(sfElements{k}.LabelString)
            continue;
        end



        if ModelAdvisor.internal.operationsArrayIndices(sfElements{k}.LabelString)
            flaggedElements(k)=true;
            continue;
        end





        if Advisor.Utils.Stateflow.isActionLanguageC(sfElements{k})
            if~isempty(regexp(sfElements{k}.LabelString,...
                '\[\s*\w*\s*\(.*\)\s*\]','once'))
                flaggedElements(k)=true;
                continue;
            end
        end







        if Advisor.Utils.Stateflow.isActionLanguageM(sfElements{k})
            tokens=regexp(sfElements{k}.LabelString,'(\w+)\s*\(','tokens');
            tokens=cellfun(@(x)x{:},tokens,'UniformOutput',false);

            if isempty(tokens)
                continue;
            end
            tokens=tokens';


            if~isempty(setdiff(tokens,sfData))
                flaggedElements(k)=true;
                break;
            end
        end
    end

    FailingObjs=sfElements(flaggedElements);
end
