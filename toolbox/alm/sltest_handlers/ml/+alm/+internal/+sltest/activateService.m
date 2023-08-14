function activateService()






    mlock();

    persistent SimulationCompletedListener;
    persistent ExportCompletedListener;
    persistent ResultSetRemovedListener;
    persistent ResultReportCreatedListener;

    if isempty(SimulationCompletedListener)
        mgr=sltest.internal.Events.getInstance();
        SimulationCompletedListener=mgr.addlistener('SimulationCompleted',...
        @alm.internal.sltest.SimulationCompletedCallback);
    end
    if isempty(ExportCompletedListener)
        mgr=sltest.internal.Events.getInstance();
        ExportCompletedListener=mgr.addlistener('ExportCompleted',...
        @alm.internal.sltest.ExportCompletedCallback);
    end
    if isempty(ResultSetRemovedListener)
        mgr=sltest.internal.Events.getInstance();
        ResultSetRemovedListener=mgr.addlistener('ResultSetRemoved',...
        @alm.internal.sltest.ResultSetRemovedCallback);
    end
    if isempty(ResultReportCreatedListener)
        mgr=sltest.internal.Events.getInstance();
        ResultReportCreatedListener=mgr.addlistener('ResultReportCreated',...
        @alm.internal.sltest.ResultReportCreatedCallback);
    end

end
