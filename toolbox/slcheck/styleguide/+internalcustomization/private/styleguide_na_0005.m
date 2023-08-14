function[rec]=styleguide_na_0005








    rec=ModelAdvisor.Check('mathworks.maab.na_0005');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:na0005Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:na0005Tip');
    rec.setCallbackFcn(@na_0005_StyleOneCallback,'None','StyleOne');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='na0005Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    inputParam1=ModelAdvisor.InputParameter;
    inputParam1.Name=DAStudio.message('ModelAdvisor:styleguide:na0005InputTitle');
    inputParam1.Type='Bool';
    inputParam1.Value=true;

    rec.setInputParameters({inputParam1});
    rec.setInputParametersLayoutGrid([1,1]);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end

function[ResultDescription]=na_0005_StyleOneCallback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};

    errStrArr=[];



    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    ip=modelAdvisorObject.getInputParameters();







    result=true;
    deviantSystems={};

    if(sLSGIsModelReference(system)==true)

        modelAdvisorObject.setCheckResultStatus(true);
        ResultDescription{end+1}=ModelAdvisor.Text(...
        DAStudio.message('ModelAdvisor:styleguide:PassedMsg'),{'pass'});
        return;
    end



    blksPorts=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off',...
    'LookUnderMasks',styleguide_look_under_masks('na_0005'),...
    'RegExp','on',...
    'BlockType','\<Inport\>|\<InportShadow\>|\<Outport\>',...
    'MaskType',regexp('','emptymatch'));




    showNames=ip{1}.Value;

    showNameOff=strcmp(get_param(blksPorts,'ShowName'),'off')|strcmp(get_param(blksPorts,'HideAutomaticName'),'on');

    if showNames

        deviantSystems=blksPorts(find(showNameOff));%#ok<FNDSB>
    else

        deviantSystems=blksPorts(find(~showNameOff));%#ok<FNDSB>
    end

    deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': na_0005'];
    ft.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0005_Info'));


    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
    ft1.setInformation({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOffMsg_Info')});
    ft1.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOffMsg_Info_Title')})

    if~isempty(deviantSystems)

        modelAdvisorObject.setCheckResultStatus(false);
        if showNames
            ft1.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005FailShowNameOffMsg')});

            ft1.setRecAction({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOnMsg_RecAct')});

        else

            ft1.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005FailShowNameOnMsg')});

            ft1.setRecAction({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOffnMsg_RecAct')});
        end
        objs=get_param(deviantSystems,'handle');

        ft1.setSubResultStatus('warn');

        ft1.setListObj(objs(:)');
        result=false;
    else

        ft1.setSubResultStatus('pass');
        ft1.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOffMsg_Pass')});
    end


    deviantSystems={};




    blksSubSys=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off',...
    'LookUnderMasks',styleguide_look_under_masks('na_0005'),...
    'BlockType','SubSystem',...
    'LinkStatus','none',...
    'Mask','off');


    showPortLabels=get_param(blksSubSys,'ShowPortLabels');
    showNameOff=strcmp(showPortLabels,'none');

    ft2=ModelAdvisor.FormatTemplate('ListTemplate');
    ft2.setInformation({DAStudio.message('ModelAdvisor:styleguide:na0005_SubSysShowNameOffMsg_Info')});
    ft2.setSubTitle({DAStudio.message('ModelAdvisor:styleguide:na0005_SubSysShowNameOffMsg_Info_Title')})

    if showNames

        deviantSystems=blksSubSys(find(showNameOff));%#ok<FNDSB>
    else


        deviantSystems=blksSubSys(find(~showNameOff));%#ok<FNDSB>
    end

    deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);

    if~isempty(deviantSystems)

        modelAdvisorObject.setCheckResultStatus(false);
        if showNames

            ft2.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005FailSubSysShowNameOffMsg')});

            ft2.setRecAction({DAStudio.message('ModelAdvisor:styleguide:na0005FailSubSysShowNameOnMsg_RecAct')});
        else

            ft2.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005FailSubSysShowNameOnMsg')});

            ft2.setRecAction({DAStudio.message('ModelAdvisor:styleguide:na0005FailSubSysShowNameOffMsg_RecAct')});
        end
        objs=get_param(deviantSystems,'handle');
        ft2.setSubResultStatus('warn');
        ft2.setListObj(objs(:)');
        result=false;
    else

        ft2.setSubResultStatus('pass');
        ft2.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:na0005_ShowNameOffMsg_Pass')});
    end

    if result
        modelAdvisorObject.setCheckResultStatus(true);
    end


    ResultDescription{end+1}=ft;
    ResultDescription{end+1}=ft1;
    ft2.setSubBar(0);
    ResultDescription{end+1}=ft2;
    modelAdvisorObject.setCheckResultStatus(result);

end


