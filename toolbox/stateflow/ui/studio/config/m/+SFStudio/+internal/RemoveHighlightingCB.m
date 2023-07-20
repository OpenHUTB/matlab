function RemoveHighlightingCB(cbInfo)




    machineId=sfprivate('actual_machine_referred_by',SFStudio.Utils.getChartId(cbInfo));
    modelName=sf('get',machineId,'machine.name');
    slprivate('remove_hilite',modelName);


    SLStudio.Utils.RemoveHighlighting(sf('get',machineId,'.simulinkModel'));

    if sf('feature','HeatMap')
        Stateflow.HeatMap.HeatMapUIManager.clearHighlighting(machineId);
    end
end
