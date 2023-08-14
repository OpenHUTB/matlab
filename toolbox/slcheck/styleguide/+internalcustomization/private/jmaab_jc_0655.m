function jmaab_jc_0655
    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0655');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0655_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0655';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0655',@hCheckAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:jmaab:jc_0655_guideline'),newline,newline,DAStudio.message('ModelAdvisor:jmaab:jc_0655_tip')];
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=false;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([4,4]);









    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end









function captureGroup=getCaptureGroup(chart)
    sfData=getFromChartObj(chart,'Stateflow.Data');
    names=cellfun(@(x)x.Name,sfData,'UniformOutput',false);
    captureGroup=strjoin(names(cellfun(@(x)strcmp(x.CompiledType,'boolean'),sfData)),'|');
end



function logicalConstantsGroup=getLogicalConstantsGroup(chart)
    sfData=getFromChartObj(chart,'Stateflow.Data');
    names=cellfun(@(x)x.Name,sfData,'UniformOutput',false);
    logicalConstantsGroup=strjoin(names(cellfun(@(x)strcmpi(x.Scope,'Constant')&&...
    (strcmpi(x.Props.InitialValue,'1')||strcmpi(x.Props.InitialValue,'0')),sfData)),'|');
    inBuiltConstants='true|false';
    if isempty(logicalConstantsGroup)
        logicalConstantsGroup=inBuiltConstants;
    else
        logicalConstantsGroup=strcat(logicalConstantsGroup,'|',inBuiltConstants);
    end

end
















function objs=getFromChartObj(chart,toGet)
    objs=cellfun(@(x)find(x,{'-isa',toGet}),{chart},'UniformOutput',false);

    objs=vertcat(cellfun(@(x)num2cell(x),objs,'UniformOutput',false));
    objs=vertcat(objs{:});
end


function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    sfCharts=mdlAdvObj.filterResultWithExclusion(...
    Advisor.Utils.Stateflow.sfFindSys(...
    system,flv.Value,lum.Value,{'-isa','Stateflow.Chart'}));

    if isempty(sfCharts)
        return;
    end



    for k=1:length(sfCharts)
        captureGroup=getCaptureGroup(sfCharts{k});
        logicalConstantGroup=getLogicalConstantsGroup(sfCharts{k});
        if isempty(captureGroup)
            continue;
        end
        captureGroupOnLeft=['(',captureGroup,')(<|>|>=|<=|<>|([!~=]=))(',logicalConstantGroup,')'];
        captureGroupOnRight=['(',logicalConstantGroup,')(<|>|>=|<=|<>|([!~=]=))(',captureGroup,')'];

        sfElements=[getFromChartObj(sfCharts{k},'Stateflow.State');...
        getFromChartObj(sfCharts{k},'Stateflow.Transition')];

        for index=1:length(sfElements)


            str=regexprep(sfElements{index}.LabelString,'\s+','');
            if isempty(str)
                continue;
            end
            if~isempty(regexp(str,captureGroupOnLeft,'once'))||...
                ~isempty(regexp(str,captureGroupOnRight,'once'))
                tempFailObj=ModelAdvisor.internal.prepareFailureObject(sfElements{index},...
                DAStudio.message('ModelAdvisor:jmaab:jc_0655_rec_action_comparison'),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0655_warn_comparison'));
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
                continue;
            end










        end
    end
end