classdef AppFramework<handle





    methods(Static)

        function ret=getSetFramework(varargin)
mlock


            persistent frameworkInstance;
            if~isempty(varargin)
                frameworkInstance=varargin{1};
            end


            if isempty(frameworkInstance)
                frameworkInstance=Simulink.sdi.internal.AppFramework;
            end
            ret=frameworkInstance;
        end

    end


    methods

        function ret=getDefaultRunNameTemplate(~)
            ret='Run <run_index>: <model_name>';
        end

        function displayError(~,me)
            rethrowAsCaller(me);
        end

        function clear(~,varargin)


            sdi.Repository.clearRepositoryFile();
        end

        function deleteRun(~,runID)
            repo=sdi.Repository(1);
            repo.removeRun(runID);
        end

        function deleteSignal(~,sigID)
            repo=sdi.Repository(1);
            repo.remove(sigID);
        end


        function onSignalAdded(~,varargin)
        end
        function onSignalsRemoved(~,varargin)
        end
        function onSignalPropChange(~,varargin)
        end
        function onRunPropChange(~,varargin)
        end
        function onRapidAccelRunImport(~,varargin)
        end
        function onPreSignalPlotted(~,varargin)
        end
        function waitForSignalToBePlotted(~,varargin)
        end
        function onRunsCreated(~,varargin)
        end
        function onAddedToRun(~,varargin)
        end
        function beginCancellableOperation(~)
        end
        function endCancellableOperation(~)
        end
        function ret=createProgressTrackerForImport(~,varargin)
            ret=[];
        end
        function ret=createProgressTrackerForExport(~,varargin)
            ret=[];
        end
        function ret=isImportCancelled(~,varargin)
            ret=false;
        end
        function displayMsgBox(~,varargin)
        end

        function setSignalChecked(~,varargin)
        end

        function ret=getSelectedVisual(~,varargin)
            ret='';
        end

        function fireRunMetaDataUpdatedEvent(~,~,varargin)
        end

        function ret=getClient(~,varargin)
            ret=[];
        end

        function ret=getMaxSigsPref(~)
            ret=[];
        end


        function exportDomainToMLDATX(~,varargin)
            error('TODO: Not supported')
        end

        function exportSignalsToXLS(~,varargin)
            error('TODO: Not supported')
        end

        function exportToFile(~,varargin)
            error('TODO: Not supported')
        end

        function createVideoSignal(~,varargin)
            error('TODO: Not supported')
        end

        function setMetaDataForRun(~,varargin)
        end

        function ret=createPreRunDeleteListener(~,~)
            ret=[];
        end


        function launchSDI(~,varargin)
            error('Not supported')
        end

        function ret=compareRuns(~,varargin)%#ok<STOUT>
            error('Not supported')
        end
    end

end
