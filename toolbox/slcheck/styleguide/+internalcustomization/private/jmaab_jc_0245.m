function jmaab_jc_0245







    checkID='jc_0245';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0245');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;

    rec.setLicense({styleguide_license});

    [inputParamList,gridLayout]=Advisor.Utils.Naming.getLengthRestrictionInputParams('JMAAB');
    rec.setInputParametersLayoutGrid(gridLayout);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@Advisor.Utils.Naming.inputParam_NameLength);


    rec.setCallbackFcn(@checkCallBack,'None','StyleOne');

    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function[ResultDescription]=checkCallBack(system)
    ResultDescription={};
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    subtitle=DAStudio.message('ModelAdvisor:jmaab:jc_0245_subtitle');
    ft.setInformation(subtitle);
    ft.setSubBar(false);
    bResult=true;

    [FailingNames,minLength,maxLength]=checkAlgo(mdlAdvObj,system);


    if isempty(FailingNames)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0245_pass'));
        ResultDescription{end+1}=ft;
    elseif~isempty(FailingNames)
        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        ft.setColTitles({DAStudio.message('ModelAdvisor:jmaab:NamingCheck_ColumnHeader_Signal')...
        ,DAStudio.message('ModelAdvisor:jmaab:NamingCheck_ColumnHeader_Name')});
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:jmaab:jc_0245_fail'));
        ft.setTableInfo(FailingNames);
        ft.setRecAction(DAStudio.message('ModelAdvisor:jmaab:jc_0245_recAction',...
        num2str(minLength),num2str(maxLength)));
        bResult=bResult&&false;
        ft.setSubBar(true);
        ResultDescription{end+1}=ft;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(bResult);

end


function[FailingNames,minLength,maxLength]=checkAlgo(mdlAdvObj,system)


    FailingNames={};


    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');
    inputParams=mdlAdvObj.getInputParameters;
    [minLength,maxLength]=Advisor.Utils.Naming.validateInputParam_Length(inputParams,'JMAAB');



    allSignals=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on',...
    'FollowLinks',FollowLinks.Value,...
    'LookUnderMasks',LookUnderMasks.Value,...
    'Type','line');

    allSignals=mdlAdvObj.filterResultWithExclusion(allSignals);

    for i=1:numel(allSignals)
        signal=allSignals(i);
        Failures={};
        if Advisor.Utils.Naming.verifySignal(signal)
            signalName=get_param(signal,'Name');
            if length(signalName)<minLength||length(signalName)>maxLength
                Failures{1}=signal;
                Failures{2}=signalName;
            end
        end
        FailingNames=[FailingNames;Failures];%#ok<*AGROW>
    end


    if~isempty(FailingNames)
        srcHandles=get_param([FailingNames{:,1}],'SrcBlockHandle');


        if iscell(srcHandles)
            srcHandles=[srcHandles{:}];
        end
        [~,index]=unique(srcHandles);
        FailingNames=FailingNames(index,:);
    end
end

