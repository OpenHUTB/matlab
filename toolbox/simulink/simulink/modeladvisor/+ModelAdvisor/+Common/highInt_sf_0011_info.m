function[results,info]=highInt_sf_0011_info(modelAdvisorObject,checkPrefix,system)





    results={};

    info.bResults=true;
    modelAdvisorObject.setCheckResultStatus(info.bResults);

    myRoot=sfroot;
    myModelName=bdroot(system);
    myModel=myRoot.find('-isa','Simulink.BlockDiagram','-and','Name',myModelName);
    myChart=myModel.find('-isa','Stateflow.Chart');

    myChart=modelAdvisorObject.filterResultWithExclusion(myChart);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    if(strcmp(checkPrefix,'ModelAdvisor:iec61508:hisf_0011_'))
        ft.setSubTitle({DAStudio.message([checkPrefix,'StateflowDebugSettings_Title'])});
        ft.setInformation({DAStudio.message([checkPrefix,'title_CT'])});
    else
        ft.setCheckText({DAStudio.message([checkPrefix,'title_CT'])});
    end


    ft.setSubResultStatusText({DAStudio.message([checkPrefix,'ResultPass'])});
    ft.setSubResultStatus('pass');

    if(isempty(myChart))


        ft.setSubResultStatusText(DAStudio.message([checkPrefix,'NoChartsFound']));
    else
        ft.setColTitles({DAStudio.message([checkPrefix,'Col_1']),...
        DAStudio.message([checkPrefix,'Col_2']),...
        DAStudio.message([checkPrefix,'Col_3'])});



        cp=getActiveConfigSet(bdroot(system));
        overFlow=cp.get_param('IntegerOverflowMsg');
        signalRange=cp.get_param('SignalRangeChecking');
        cycle=myChart(1).Machine.Debug.RunTimeCheck.CycleDetection;

        if strcmp(overFlow,'none')||strcmp(overFlow,'warning')
            info.bResults=false;
            link=Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
            system,'IntegerOverflowMsg');
            ft.addRow({{link},{'error'},{overFlow}});
        end

        if strcmp(signalRange,'none')||strcmp(signalRange,'warning')
            info.bResults=false;
            link=Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
            system,'SignalRangeChecking');
            ft.addRow({{link},{'error'},{signalRange}});
        end

        if(~cycle)
            info.bResults=false;
            ft.addRow({{DAStudio.message([checkPrefix,'Info_4'])},...
            {DAStudio.message([checkPrefix,'Selected'])},...
            {DAStudio.message([checkPrefix,'Cleared'])}});
        end


        if(info.bResults==true)

            link=Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
            system,'IntegerOverflowMsg');
            ft.addRow({{link},{'error'},{'error'}});

            link=Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
            system,'SignalRangeChecking');
            ft.addRow({{link},{'error'},{'error'}});

            ft.addRow({{DAStudio.message([checkPrefix,'Info_4'])},...
            {DAStudio.message([checkPrefix,'Selected'])},...
            {DAStudio.message([checkPrefix,'Selected'])}});

        end
    end
    modelAdvisorObject.setCheckResultStatus(info.bResults);


    if(~info.bResults)
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText({DAStudio.message([checkPrefix,'ResultFail'])});
        ft.setRecAction({DAStudio.message([checkPrefix,'RecAct'])});
        modelAdvisorObject.setActionEnable(true);
    else
        modelAdvisorObject.setActionEnable(false);
    end
    ft.setSubBar(0);
    results{end+1}=ft;

end
