function[bResultStatus,ResultDescription]=...
    loc_CheckForBusToVectorConversion(system,model,encodedModelName,strictOnly)
















    sl('busUtils','SetUpgradeStatus',model,'on');
    c=onCleanup(@()sl('busUtils','SetUpgradeStatus',model,'off'));

    bResultStatus=false;%#ok
    ResultDescription={};
    strictBusMsg=get_param(model,'StrictBusMsg');

    xlateTagPrefix='ModelAdvisor:engine:';

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);

    if strcmpi(strictBusMsg,'ErrorOnBusTreatedAsVector')

        bResultStatus=true;
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusToVecUsagePass']));
        ResultDescription{end+1}=ft;
    elseif get_param(bdroot(system),'handle')~=get_param(system,'handle')

        bResultStatus=false;
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMAUnableToRunCheckForProperBusOnSubsystem']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'CommonMAResultUnableToRunCheckForProperBusOnSubsystem']));
        ResultDescription{end+1}=ft;
    else


        if(strictOnly)
            ports=get_param(model,'BusInputIntoStrictlyForbiddenNonBusBlock');
        else
            ports=get_param(model,'BusInputIntoNonBusBlock');
        end









        if~strictOnly
            isMixedAttrib=logical([ports.MixedAttributes]');
            ports=ports(~isMixedAttrib);
        end

        ft=ModelAdvisor.FormatTemplate('ListTemplate');

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};





        if strictOnly
            if~isempty(ports)
                sameAttriPorts=ports([ports.MixedAttributes]==0);
            end


            if isempty(ports)||isempty(sameAttriPorts)
                currentCheckObj.Action.Enable=false;
            else

                currentCheckObj.Action.Enable=true;
            end
        else
            currentCheckObj.Action.Enable=true;
        end


        if~isempty(ports)

            bResultStatus=false;
            ft.setSubResultStatus('Warn');



            if~strictOnly
                ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusToVectorErrorMsg4']));
            else
                ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusToVectorErrorMsg4Upgrade'],length(ports)));
            end
            ft.setSubBar(0);
            ResultDescription{end+1}=ft;



            mixedAttriPorts=ports([ports.MixedAttributes]==1);
            sameAttriPorts=ports([ports.MixedAttributes]==0);



            if~strictOnly
                for idx=1:length(ports)
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');

                    bustoVectorstr=DAStudio.message([xlateTagPrefix,'CommonMABusToVectorMsg'],ports(idx).InputPort);
                    ft.setSubResultStatusText(bustoVectorstr);
                    ft.setListObj(get_param(ports(idx).BlockPath,'handle'));
                    ft.setSubBar(0);
                    ResultDescription{end+1}=ft;%#ok
                end
            else
                if~isempty(sameAttriPorts)
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageMsgSameAttrPromptUpgrade']));
                    ft.setSubBar(0);
                    ResultDescription{end+1}=ft;

                    for idx=1:length(sameAttriPorts)
                        ft=ModelAdvisor.FormatTemplate('ListTemplate');
                        htmlBlockPath=modeladvisorprivate('HTMLjsencode',sameAttriPorts(idx).BlockPath,'encode');
                        htmlBlockPath=[htmlBlockPath{:}];
                        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusUsageUpgradeInportList'],sameAttriPorts(idx).InputPort,...
                        htmlBlockPath,sameAttriPorts(idx).BlockPath,idx));
                        ft.setSubBar(0);
                        ResultDescription{end+1}=ft;%#ok
                    end
                end

                if~isempty(mixedAttriPorts)
                    ft=ModelAdvisor.FormatTemplate('ListTemplate');
                    ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageMsgMixedAttrPromptUpgrade']));
                    ft.setSubBar(0);
                    ResultDescription{end+1}=ft;

                    for idx=1:length(mixedAttriPorts)
                        ft=ModelAdvisor.FormatTemplate('ListTemplate');
                        htmlBlockPath=modeladvisorprivate('HTMLjsencode',mixedAttriPorts(idx).BlockPath,'encode');
                        htmlBlockPath=[htmlBlockPath{:}];
                        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusUsageUpgradeInportList'],mixedAttriPorts(idx).InputPort,...
                        htmlBlockPath,mixedAttriPorts(idx).BlockPath,idx));
                        ft.setSubBar(0);
                        ResultDescription{end+1}=ft;%#ok
                    end
                end
            end




            if~strictOnly
                desc1=DAStudio.message([xlateTagPrefix,'CommonMABusToVectorErrorMsg1']);
            else
                if isempty(sameAttriPorts)
                    desc1=DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageUpgradeRecMixed']);
                elseif isempty(mixedAttriPorts)
                    desc1=DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageUpgradeRecSame']);
                else
                    desc1=DAStudio.message([xlateTagPrefix,'CommonMAVirtualBusUsageUpgradeRecBoth']);
                end
            end
            ResultDescription{end}.setRecAction(desc1);

        else
            if~strictOnly
                assert(strcmp(strictBusMsg,'ErrorLevel1')||...
                strcmp(strictBusMsg,'WarnOnBusTreatedAsVector'));

                bResultStatus=false;
                ft.setSubResultStatus('Warn');
                ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusToVectorErrorMsg3']));
                configPrmDlg=loc_CreateConfigSetHref(DAStudio.message([xlateTagPrefix,'CommonMABusToVectorConfigLink']),...
                'StrictBusMsg',encodedModelName);

                desc=[ModelAdvisor.Text(DAStudio.message([xlateTagPrefix,'CommonMABusToVectorErrorMsg5']))...
                ,configPrmDlg];
                ft.setRecAction(desc);




            else
                bResultStatus=true;
                ft.setSubResultStatus('Pass');
                ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'CommonMABusToVecUsagePassUpgrade']));
            end
            ResultDescription{end+1}=ft;
        end
    end



    if strictOnly
        ResultDescription{1}.setSubTitle(DAStudio.message([xlateTagPrefix,'CommonMABusUsageDescHeaderSubCheck2Upgrade']));
        ResultDescription{1}.setInformation(DAStudio.message([xlateTagPrefix,'CommonMABusUsageDescriptionSubCheck2Upgrade']));
    else
        ResultDescription{1}.setSubTitle(DAStudio.message([xlateTagPrefix,'CommonMABusUsageDescHeaderSubCheck2']));
        ResultDescription{1}.setInformation(DAStudio.message([xlateTagPrefix,'CommonMABusUsageDescriptionSubCheck2']));
    end
    ResultDescription{1}.setSubBar(0);
end

