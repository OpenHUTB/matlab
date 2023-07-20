function setHeatMapFeatureCB(cbInfo)
    value=cbInfo.EventData;
    machineId=sfprivate('actual_machine_referred_by',SFStudio.Utils.getChartId(cbInfo));
    machineH=sf('IdToHandle',machineId);
    Stateflow.HeatMap.HeatMapToolStripManager.switchFeatureByUser(machineH,value);
    sf('UpdateDebuggerToolbarButtonVisiblility','Simulink:DebuggerSimulationPause');
