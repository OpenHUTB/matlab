classdef StmDebugger<handle




    properties(Access=private)
        signalObj=[];
        simOutSignal=[];
        slicerCloseListener;
        slicerStepHighlightListener;
        signalToSliceCriteriaIndexMap;
        simWatcher=[];
    end

    properties(Access=private,Constant)
        slicerCriteriaTag='StmGenerated';
    end

    properties(Access=public)
        ModelName=[];
        resultsDebugger=[];
        simulationToDebug=1;
        secondSimData=[];
        timeDiff=0;
    end

    methods(Access=private)
        function obj=StmDebugger(signalId,timeDiff)
            obj.updateBaselineSignal(signalId);
            obj.signalToSliceCriteriaIndexMap=containers.Map('KeyType','char','ValueType','double');
            obj.timeDiff=timeDiff;
        end

        function addSlicerCloseCallback(obj)

            obj.slicerCloseListener=addlistener(obj.resultsDebugger,'eventModelSlicerDialogClosed',...
            @(~,~)obj.tearDownSession);
        end

        function addSlicerStepHighlightCompletedListener(obj)
            obj.slicerStepHighlightListener=addlistener(obj.resultsDebugger,'eventModelSlicerSimStepHighlighted',...
            @(~,~)obj.appendValuesToActivePVD);
        end

        function removeSlicerCloseCallback(obj)
            delete(obj.slicerCloseListener);
            obj.slicerCloseListener=[];
        end

        function addModelCloseCallBack(obj)

            load_system(obj.ModelName);
            bdObj=get_param(obj.ModelName,'Object');
            if~bdObj.hasCallback('PreClose','stmDebugModelCloseCallback')
                Simulink.addBlockDiagramCallback(obj.ModelName,'PreClose','stmDebugModelCloseCallback',...
                @(~,~)obj.tearDownSession);
            end
        end

        function switchToSimulationTab(obj)

            modelHandle=get_param(obj.ModelName,'Handle');
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studioHandles=arrayfun(@(s)s.App.blockDiagramHandle,allStudios);
            studioIdx=find(studioHandles==modelHandle,1);
            studio=allStudios(studioIdx);
            toolStrip=studio.getToolStrip;
            toolStrip.ActiveTab='globalSimulationTab';
        end

        function removeModelCloseCallback(obj)

            if~isempty(obj.ModelName)&&bdIsLoaded(obj.ModelName)
                bdObj=get_param(obj.ModelName,'Object');
                if bdObj.hasCallback('PreClose','stmDebugModelCloseCallback')
                    Simulink.removeBlockDiagramCallback(obj.ModelName,'PreClose','stmDebugModelCloseCallback');
                end
            end
        end

        function tearDownSession(obj)
            obj.closeSession;

            payloadStruct=struct('VirtualChannel','Results/EndDebugSession','Payload',[]);
            message.publish('/stm/messaging',payloadStruct);
        end


        function updateBaselineSignal(obj,sigId)
            engine=Simulink.sdi.Instance.engine;
            obj.signalObj=engine.getSignal(sigId);
        end


        function updateSimOutSignal(obj,sigId)
            engine=Simulink.sdi.Instance.engine;
            obj.simOutSignal=engine.getSignal(sigId);
        end

        function addCurrentSignalToSliceCriteriaIndexMapEntry(obj,criteriaIndex)
            signalMapKey=obj.getSignalMapKey();
            obj.signalToSliceCriteriaIndexMap(signalMapKey)=criteriaIndex;
        end

        function clearGeneratedSlicerCriterion(obj)
            if~isempty(obj.ModelName)&&bdIsLoaded(obj.ModelName)...
                &&~isempty(obj.resultsDebugger)
                obj.resultsDebugger.deleteCriterionByTag(obj.slicerCriteriaTag);
            end
        end

        function appendValuesToActivePVD(obj)

            import SlicerApplication.SimulationResultDebugger.*;
            if isempty(obj.secondSimData)

                return;
            end

            simTime=get_param(obj.ModelName,'TimeOfMajorStep');
            numSignalToShow=slInternal('getValueDisplayOption',obj.ModelName,'MaxElements');

            for idx=1:obj.secondSimData.numElements
                signal=obj.secondSimData.getElement(idx);
                showModifiedPVDforSignal(signal,simTime,numSignalToShow);
            end
        end

        setupSlicerCriteria(obj);

        function delete(obj)
            obj.clearGeneratedSlicerCriterion;
            obj.removeModelCloseCallback;
            obj.removeSlicerCloseCallback;


            if~isempty(obj.resultsDebugger)&&...
                obj.resultsDebugger.isSlicerDialogClosedByUser()
                obj.simWatcher.simModel.ModelLoadedOrOpened=true;
                obj.simWatcher.slicerDebugPreventHarnessClose=true;
            end
            delete(obj.resultsDebugger);
            obj.signalToSliceCriteriaIndexMap=[];
            if~isempty(obj.simWatcher)
                stm.internal.RunTestConfiguration.revertModelSettingsAfterSimulation(obj.simWatcher);
                obj.simWatcher=[];
            end
        end

        function signalMapKey=getSignalMapKey(obj)

            signalMapKey=strcat(obj.signalObj.SignalLabel,'_',string(obj.signalObj.DataID));
        end
    end

    methods(Static)
        sldbg=getInstance(varargin);
        debugButtonClicked(sigId,simIndex,timeDiff);
        debugSignalChanged(baselineSignal,simOutSignal);
        simOut=simulateForDebug(runTestCfg,simWatcher);
        stepBack();
        stepForward();
        continueSimulation(buttonState);
        stopSimulation();
        runToFailure(timeOfFailure);
        closeSession();
        timeWindowHighlight(start,stop);
        scopeToSeedView(sigId);

        function bool=supportsDebug(simMode)

            bool=simMode=="normal"||simMode=="accelerator";
        end
    end

end
