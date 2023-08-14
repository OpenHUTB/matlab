function viewHeatMapTableCB(cbInfo)




    [~,~,chartHandle]=SFStudio.internal.extractMachineInfo(cbInfo);
    studioTag=cbInfo.studio.getStudioTag;
    Stateflow.HeatMap.HeatMapToolStripManager.toggleIsShowTableEnabled(studioTag,chartHandle.Path,cbInfo.EventData);
end
