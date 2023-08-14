function jmaab_jc_0731

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0731');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0731_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0731';
    rec.setCallbackFcn(@checkCallBack,'none','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0731_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function checkCallBack(system,CheckObj)
    [resultData]=checkAlgo(system);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ElementResults=updateMdladvObj(mdladvObj,resultData);
    CheckObj.setResultDetails(ElementResults);
end


function ElementResults=updateMdladvObj(mdladvObj,resultData)

    if resultData.noStatesFound
        mdladvObj.setCheckResultStatus(true);
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0731_tip'),...
        'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0731_no_stateflow_chart'));
    else
        if isempty(resultData.failedBlocks)
            mdladvObj.setCheckResultStatus(true);
            ElementResults=Advisor.Utils.createResultDetailObjs('',...
            'IsViolation',false,...
            'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0731_tip'),...
            'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0731_pass'));
        else
            mdladvObj.setCheckResultStatus(false);
            ElementResults=Advisor.Utils.createResultDetailObjs(resultData.failedBlocks,...
            'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0731_tip'),...
            'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0731_fail'),...
            'RecAction',DAStudio.message('ModelAdvisor:jmaab:jc_0731_recAction'));
        end
    end
end

function[resultData]=checkAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    sfStates=Advisor.Utils.Stateflow...
    .sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,...
    {'-isa','Stateflow.State','-or','-isa','Stateflow.AtomicSubchart',...
    '-or','-isa','Stateflow.ActionState'});
    if~isempty(sfStates)
        sfStates=mdladvObj.filterResultWithExclusion(sfStates);
        flaggedStates=false(1,length(sfStates));
        for c1=1:length(sfStates)
            if checkForSlash(sfStates{c1})
                flaggedStates(c1)=true;
            end
        end
        resultData.noStatesFound=false;
        resultData.failedBlocks=sfStates(flaggedStates);
    else
        resultData.noStatesFound=true;
        resultData.failedBlocks=[];
    end
end


function flag=checkForSlash(sfState)









    stateContent=strtrim(sfState.LabelString);
    stateContentLines=strsplit(stateContent,'\n');



    stateName=strtrim(stateContentLines{1});

    if contains(stateName,'/')
        flag=true;
    else
        flag=false;
    end
end