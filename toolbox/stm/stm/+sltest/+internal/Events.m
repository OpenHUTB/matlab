classdef Events<handle




    events
        SimulationCompleted;
        ExportCompleted;
        TestFileOpened;
        TestFileClosed;
        ResultSetRemoved;
        TestSpinnerLabelUpdated;
        GlobalSpinnerLabelUpdated;
        Execution_ResultsInitialized;
        Execution_InternalSimInStructCreated;
        Execution_SimInArrayCreated;
        Execution_SimMgrConfigured;
        ResultReportCreated;
    end

    methods(Access=private)
        function this=Events
        end
    end

    methods(Static)

        function this=getInstance
            mlock;
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=sltest.internal.Events;
            end
            this=localObj;
        end

        function staticNotifySimulationCompleted(rsID)
            sltest.internal.Events.getInstance.notifySimulationCompleted(rsID);
        end

        function staticNotifyExportCompleted(filePath)
            sltest.internal.Events.getInstance.notifyExportCompleted(filePath);
        end

        function staticNotifyTestFileOpened(filePath)
            sltest.internal.Events.getInstance.notifyTestFileOpened(filePath);
        end

        function staticNotifyTestFileClosed(filePaths)
            sltest.internal.Events.getInstance.notifyTestFileClosed(filePaths);
        end

        function staticNotifyResultSetRemoved(uuid)
            sltest.internal.Events.getInstance.notifyResultSetRemoved(uuid);
        end

        function staticNotifyTestSpinnerLabelUpdated(testCaseId,spinnerText)
            sltest.internal.Events.getInstance.notifyTestSpinnerLabelUpdated(testCaseId,spinnerText);
        end

        function staticNotifyInitializedResults
            sltest.internal.Events.getInstance.notifyResultsInitialized;
        end

        function staticNotifyInternalSimInStructCreated
            sltest.internal.Events.getInstance.notifyInternalSimInStructCreated;
        end
    end

    methods
        function notifySimulationCompleted(this,rsID)
            rs=sltest.testmanager.ResultSet.empty(0,1);
            if~isempty(rsID)
                rs=sltest.testmanager.TestResult.getResultFromID(rsID);
            end
            evtdata=sltest.internal.Events.SimulationCompletedEvent(rs);
            this.notify('SimulationCompleted',evtdata);
        end

        function notifyExportCompleted(this,filePath)
            evtdata=sltest.internal.Events.FilePathEvent(filePath);
            this.notify('ExportCompleted',evtdata);
        end

        function notifyTestFileOpened(this,filePath)
            evtdata=sltest.internal.Events.TestFileOpenedEvent(filePath);
            this.notify('TestFileOpened',evtdata);
        end

        function notifyTestFileClosed(this,filePaths)
            evtdata=sltest.internal.Events.TestFileClosedEvent(filePaths);
            this.notify('TestFileClosed',evtdata);
        end

        function notifyResultSetRemoved(this,uuid)
            evtdata=sltest.internal.Events.ResultSetRemovedEvent(uuid);
            this.notify('ResultSetRemoved',evtdata);
        end

        function notifyTestSpinnerLabelUpdated(this,id,text)
            evtdata=sltest.internal.Events.TestSpinnerLabelUpdatedEvent(id,text);
            this.notify('TestSpinnerLabelUpdated',evtdata);
        end

        function notifyGlobalSpinnerLabelUpdated(this,text)
            evtdata=sltest.internal.Events.GlobalSpinnerLabelUpdatedEvent(text);
            this.notify('GlobalSpinnerLabelUpdated',evtdata);
        end

        function notifyResultsInitialized(this)
            this.notify('Execution_ResultsInitialized');
        end

        function notifyInternalSimInStructCreated(this)
            this.notify('Execution_InternalSimInStructCreated');
        end

        function notifySimInArrayCreated(this)
            this.notify('Execution_SimInArrayCreated');
        end

        function notifySimMgrConfigured(this)
            this.notify('Execution_SimMgrConfigured');
        end

        function notifyResultReportCreated(this,filePath,resultObjects)
            evtdata=sltest.internal.Events.ResultReportCreatedEvent(filePath,resultObjects);
            this.notify("ResultReportCreated",evtdata);
        end
    end
end
