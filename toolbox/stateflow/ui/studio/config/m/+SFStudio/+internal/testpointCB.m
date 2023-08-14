function testpointCB(cbinfo,varargin)
    chartId=SFStudio.Utils.getChartId(cbinfo);

    if Stateflow.STT.StateEventTableMan.isStateTransitionTable(chartId)
        sttman=Stateflow.STT.StateEventTableMan(chartId);
        si=sttman.viewManager.CurrentSelectionInfo;
        stateCell=si.SelectedObject;
        stateUddH=stateCell.stateUddH;
        stateUddH.TestPoint=~stateUddH.TestPoint;
        stateCell.hasTestPoint=stateUddH.TestPoint;
        stateCell.refreshObservableProps(stateCell.SelectionInfo);
    end

end