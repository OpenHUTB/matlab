function[comparisonRunID,result,isIntersectionUsed]=compareRuns(run1,run2)







    Simulink.sdi.internal.moveRunToApp(run1,'stm');


    Simulink.sdi.internal.ConnectorAPI.disableEventCallback('compareRunsEvent');
    ocSys=onCleanup(...
    @()Simulink.sdi.internal.ConnectorAPI.enableEventCallback('compareRunsEvent'));

    algorithms=[Simulink.sdi.AlignType.DataSource
    Simulink.sdi.AlignType.BlockPath
    Simulink.sdi.AlignType.SID
    Simulink.sdi.AlignType.SignalName];




    opts={'KeepExpanded',true};


    drr=Simulink.sdi.compareRuns(run1,run2,algorithms,opts{:});
    comparisonRunID=drr.comparisonRunID;


    run=Simulink.sdi.getRun(drr.RunID1);
    signals=run.getAllSignals;
    isIntersectionUsed=any({signals.SyncMethod}=="intersection");


    result=drr.Count==drr.Summary.WithinTolerance+drr.Summary.Empty;
end
