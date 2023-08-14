function jmaab_jc_0743

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0743');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0743_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0743';
    rec.setCallbackFcn(@checkCallBack,'none','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0743_tip');
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



function checkCallBack(system,CheckObj)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    [resultData]=checkAlgo(system,mdladvObj);
    CheckObj.setResultDetails(updateMdladvObj(mdladvObj,resultData));
end



function ElementResults=updateMdladvObj(mdladvObj,resultData)
    if resultData.noTransitionsFound
        mdladvObj.setCheckResultStatus(true);
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0743_tip'),...
        'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0743_no_stateflow_transition'));
    else
        if isempty(resultData.failedTransitions)
            mdladvObj.setCheckResultStatus(true);
            ElementResults=Advisor.Utils.createResultDetailObjs('',...
            'IsViolation',false,...
            'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0743_tip'),...
            'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0743_pass'));
        else

            mdladvObj.setCheckResultStatus(false);
            ElementResults=Advisor.Utils.createResultDetailObjs(resultData.failedTransitions,...
            'Description',DAStudio.message('ModelAdvisor:jmaab:jc_0743_tip'),...
            'Status',DAStudio.message('ModelAdvisor:jmaab:jc_0743_fail'),...
            'RecAction',DAStudio.message('ModelAdvisor:jmaab:jc_0743_recAction'));
        end
    end
end


function[resultData]=checkAlgo(system,mdlAdvObj)
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');
    sfTransitions=Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,{'-isa','Stateflow.Transition'});

    resultData.failedTransitions=[];
    if isempty(sfTransitions)
        resultData.noTransitionsFound=true;
        return;
    end

    sfTransitions=mdlAdvObj.filterResultWithExclusion(sfTransitions);
    resultData.noTransitionsFound=false;
    flaggedTransitions=false(1,length(sfTransitions));

    for k=1:length(sfTransitions)

        label=sfTransitions{k}.LabelString;
        if~isempty(label)

            str=label((strfind(label,'{')+1):(strfind(label,'}')-1));
            if~isempty(str)
                flaggedTransitions(k)=hasViolation(str);
            end
        end
    end

    resultData.failedTransitions=sfTransitions(flaggedTransitions);
end


function res=hasViolation(str)
    res=false;
    if isempty(str)
        return;
    end

    if iscell(str)
        str=str{1};
    end


    lines=splitlines(str);

    lines=lines(~cellfun('isempty',lines));

    for k=1:length(lines)

        line=strtrim(lines{k});

        if(isempty(line))
            continue;
        end






        if length(strfind(line,';'))~=1
            res=true;
            return;
        end

        if~strcmp(line(end),';')





            [tokens,~]=regexp(line,'(.*?;)(\s*[%\/]+)$','tokens','match');
            if isempty(tokens)
                res=true;
                return;
            end
        end
    end
end