












function[bResultStatus,ResultDescription]=modelAdvisorCheck_UnconnectedObjects(system,xlateTagPrefix)






    ResultDescription={};
    bResultStatus=false;

    isSubsystem=false;
    if strcmp(bdroot(system),system)==false
        isSubsystem=true;
    end

    hScope=get_param(system,'Handle');

    if isSubsystem
        checkDescStr=DAStudio.message([xlateTagPrefix,'UnconnectedObjectsCheckDescSubsystem']);
    else
        checkDescStr=DAStudio.message([xlateTagPrefix,'UnconnectedObjectsCheckDesc']);
    end

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setCheckText(checkDescStr);
    ft.setSubBar(0);




    uLines=find_system(hScope,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Findall','on',...
    'LookUnderMasks','on',...
    'Type','line',...
    'Connected','off');
    uPorts=find_system(hScope,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Findall','on',...
    'LookUnderMasks','on',...
    'Type','port',...
    'Line',-1);



    if~isempty(uPorts)
        for i=1:length(uPorts)
            uPorts(i)=get_param(get_param(uPorts(i),'Parent'),'Handle');
        end
    end




    simulinkFcns=find_system(hScope,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'BlockType','TriggerPort',...
    'IsSimulinkFunction','on');
    simulinkFcns=get_param(simulinkFcns,'Parent');
    simulinkFcns=get_param(simulinkFcns,'Handle');

    if iscell(simulinkFcns)
        slFcns=zeros(size(simulinkFcns,1),1);
        for i=1:length(simulinkFcns)
            slFcns(i)=simulinkFcns{i};
        end
    else
        slFcns=simulinkFcns;
    end
    uPorts=setdiff(uPorts,slFcns);




    uPorts=uPorts(arrayfun(@(x)~(strcmp(get_param(x,'BlockType'),'SubSystem')&&Stateflow.SLUtils.isChildOfStateflowBlock(x)),uPorts));


    modelObj={};
    searchResult=union(uLines,uPorts);


    ignorePortsInVariantBlock=[];
    for i=1:length(searchResult)
        parent=get_param(searchResult(i),'Parent');
        objParams=get_param(parent,'ObjectParameters');
        if(isfield(objParams,'BlockType')&&strcmpi(get_param(parent,'BlockType'),'SubSystem')&&strcmpi(get_param(parent,'Variant'),'on'))
            ignorePortsInVariantBlock=[ignorePortsInVariantBlock,i];%#ok<AGROW>
        end
    end

    if~isempty(ignorePortsInVariantBlock)
        searchResult(ignorePortsInVariantBlock)=[];
    end

    for i=1:length(searchResult)
        modelObj{i}=searchResult(i);%#ok<AGROW>
    end

    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(mdladvObj)
        modelObj=mdladvObj.filterResultWithExclusion(modelObj);
    end
    if isempty(modelObj);
        ft.setSubResultStatus('Pass');
        if isSubsystem
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ReportNoUnconnectedObjectsSubsystem']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'ReportNoUnconnectedObjects']));
        end

        ResultDescription{end+1}=ft;
        bResultStatus=true;
    else
        ft.setSubResultStatus('Warn');
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'ReportUnconnectedObjectsRecActionText']));
        if~isSubsystem
            ft.setSubResultStatusText([DAStudio.message([xlateTagPrefix,'ReportUnconnectedObjectsWarningText']),' ',system]);
        else
            ft.setSubResultStatusText([DAStudio.message([xlateTagPrefix,'ReportUnconnectedObjectsWarningTextSubsystem']),' ',system]);
        end
        ft.setListObj(modelObj);
        ResultDescription{end+1}=ft;
        bResultStatus=false;
    end;




