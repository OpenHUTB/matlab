function[results]=highInt_sf_0011_fix(taskobj,checkPrefix)




    mdladvObj=taskobj.MAObj;

    system=getfullname(mdladvObj.System);

    myRoot=sfroot;
    myModel=myRoot.find('-isa','Simulink.BlockDiagram','-and','Name',bdroot(system));
    myChart=myModel.find('-isa','Stateflow.Chart');

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);
    fixStr={};


    cp=getActiveConfigSet(bdroot(system));
    overFlow=cp.get_param('IntegerOverflowMsg');
    signalRange=cp.get_param('SignalRangeChecking');
    cycle=myChart(1).Machine.Debug.RunTimeCheck.CycleDetection;

    if strcmp(overFlow,'none')||strcmp(overFlow,'warning')
        cp.set_param('IntegerOverflowMsg','error');
        fixStr{end+1}=...
        Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
        system,'IntegerOverflowMsg');
    end

    if strcmp(signalRange,'none')||strcmp(signalRange,'warning')
        cp.set_param('SignalRangeChecking','error');
        fixStr{end+1}=...
        Advisor.Utils.Simulink.getConfigSetParameterHyperlink(...
        system,'SignalRangeChecking');
    end

    if~cycle
        myChart(1).Machine.Debug.RunTimeCheck.CycleDetection=1;
        fixStr{end+1}=DAStudio.message([checkPrefix,'Info_4']);
    end

    mdladvObj.setActionEnable(false);
    ft.setCheckText({DAStudio.message([checkPrefix,'FixInfo_Results'])});
    ft.setListObj(fixStr);
    results=ft;
end

