function[info,results]=highInt_sf_0002_info(modelAdvisorObject,system,prefix,fromFix)




    if(nargin==3)
        fromFix=0;
    end

    results={};
    info.bResults=true;
    info.Type='List';
    info.Obj={};

    if(info.bResults==0)
        modelAdvisorObject.setCheckResultStatus(info.bResults);
    end

    sysObj=get_param(system,'Object');
    myChart=sysObj.find('-isa','Stateflow.Chart');

    linkCharts=ModelAdvisor.Common.find_LinkChart(sysObj);
    myChart=[myChart(:);linkCharts(:)];



    myChart=modelAdvisorObject.filterResultWithExclusion(myChart);

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(0);

    if(strcmp(prefix,'ModelAdvisor:iec61508:hisf_0002_'))
        ft.setSubTitle({DAStudio.message([prefix,'StateflowTransOrder_Title'])});
        ft.setInformation({DAStudio.message([prefix,'title_CT'])});
    else
        ft.setCheckText({DAStudio.message([prefix,'title_CT'])});
    end

    if(isempty(myChart))


        ft.setSubResultStatusText(DAStudio.message([prefix,'NoChartsFound']));
        ft.setSubResultStatus('pass');
    else

        for inx=1:length(myChart)
            if(myChart(inx).UserSpecifiedStateTransitionExecutionOrder==0)
                info.Obj{end+1}=myChart(inx);
            end
        end
        if(isempty(info.Obj))
            ft.setSubResultStatusText({DAStudio.message([prefix,'ResultPass'])});
            ft.setSubResultStatus('pass');
        else
            ft.setSubResultStatusText({DAStudio.message([prefix,'ResultFail'])});
            ft.setSubResultStatus('warn');
            ft.setListObj(info.Obj(:)');
            ft.setRecAction({DAStudio.message([prefix,'RecAct'])});
            info.bResults=false;
        end
    end

    if(fromFix==0)
        results{end+1}=ft;
        modelAdvisorObject.setCheckResultStatus(info.bResults);

        if(~info.bResults)
            modelAdvisorObject.setActionEnable(true);
        end
    end
end
