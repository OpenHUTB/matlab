classdef SimulationResultDebugger<handle





    properties(SetAccess=immutable)
modelName
modelH
    end

    properties(SetAccess=immutable,Hidden=true)

origFastRestartVal
originalDirtyStatusMap
    end

    properties(Access=private)
        tempModelState Simulink.internal.TemporaryModelState
        simIn Simulink.SimulationInput

        msObj ModelSlicer
        msApiObj SLSlicerAPI.SLSlicer

        simHandler Coverage.SimulationHandler

CoverageFile


slicerCloseListener
slicerTimeWindowListener
slicerStepHighlightListener

        closingSlicerDDG=false;
        isFastRestartSupported=true;


origDiagnosticsMap
    end

    events
        eventModelSlicerDialogClosed;
        eventModelSlicerSimStepHighlighted;
    end

    methods
        function obj=SimulationResultDebugger(arg)
            if isa(arg,'sltest.harness.SimulationInput')
                in=arg;
                model=arg.HarnessName;
            elseif isa(arg,'Simulink.SimulationInput')
                in=arg;
                model=arg.ModelName;
            else
                assert(strcmpi(get_param(arg,'type'),'block_diagram'));
                model=arg;
                in=Simulink.SimulationInput(model);
            end
            obj.modelName=getfullname(model);
            obj.modelH=get_param(model,'handle');

            obj.origFastRestartVal=get_param(model,'FastRestart');

            obj.originalDirtyStatusMap=constructDirtyStatusMap(model);

            obj.setModelInputs(in);

            obj.setupSlicer();

            obj.suppressDiagnostics();
        end


        function setModelInputs(obj,in)
            validateattributes(in,{'Simulink.SimulationInput'},{'scalar'});


            obj.resetModelSimInputs();


            in=in.setModelParameter('EnableRollBack','on');
            in=in.setModelParameter('NumberOfSteps',1);
            obj.simIn=in;


            obj.tempModelState=Simulink.internal.TemporaryModelState(obj.simIn,"ApplyHidden","on");


            cellfun(@(m)set_param(m,'Dirty','off'),...
            find_mdlrefs(obj.modelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true));
        end

        function resetModelSimInputs(obj)
            if~isempty(obj.tempModelState)&&isvalid(obj.tempModelState)

                if bdIsLoaded(obj.modelName)&&...
                    ~strcmp(get_param(obj.modelName,'SimulationStatus'),'paused')

                    delete(obj.tempModelState);
                end
            end
        end

        function setTimeWindow(obj,tstart,tstop)
            assert(~obj.isFastRestartSupported||~obj.simHandler.isRunning())
            obj.msApiObj.setTimeWindow(tstart,tstop);
        end


        function addSliceCriterion(obj)
            [tstart,tstop]=obj.msApiObj.getTimeWindow();

            obj.msApiObj.addConfiguration();
            obj.configureActiveCriterionStyle();


            obj.msApiObj.CoverageFile=obj.CoverageFile;
            obj.msApiObj.UseTimeWindow=true;
            obj.msApiObj.setTimeWindow(tstart,tstop);
        end

        function addStartingPoint(obj,startingPoint)
            obj.msApiObj.addStartingPoint(startingPoint);
            obj.highlight();
        end

        function apiObj=getSlicerAPI(obj)
            apiObj=obj.msApiObj;
        end

        function setCriteriaTag(obj,tag)
            obj.msApiObj.setCriteriaTag(tag);
        end

        function deleteCriterionByTag(obj,tag)
            obj.msApiObj.deleteCriterionByTag(tag);
        end

        function setCriteriaName(obj,name)
            obj.msApiObj.Name=name;
            obj.highlight();
        end

        function setCriteriaDescription(obj,desc)
            obj.msApiObj.Description=desc;
            obj.highlight();
            obj.refreshHighlight;
        end

        function switchToCriteria(obj,criteriaIndex)
            [tstart,tstop]=obj.msApiObj.getTimeWindow();
            obj.msApiObj.ActiveConfig=criteriaIndex;
            obj.msApiObj.setTimeWindow(tstart,tstop);
            obj.highlight();
        end

        function highlight(obj)



            obj.msApiObj.highlight(obj.msApiObj.ActiveConfig);
        end

        function refreshHighlight(obj)
            obj.msApiObj.refreshHighlight;
        end

        function criteriaIndex=getCurrentCriteriaIndex(obj)
            criteriaIndex=obj.msApiObj.ActiveConfig;
        end


        function setTimeWindowChangeCb(obj,pauseFcn,varargin)
            obj.slicerTimeWindowListener=addlistener(obj.msObj,'eventModelSlicerTimeWindowSet',...
            @(~,evtData)pauseFcn(evtData,varargin{:}));
        end


        function stepForward(obj)

            origBacktraceWarningState=warning('query','backtrace').state;
            warning('off','backtrace');
            obj.simHandler.stepForward();
            warning(origBacktraceWarningState,'backtrace');
        end

        function stepBack(obj)

            origBacktraceWarningState=warning('query','backtrace').state;
            warning('off','backtrace');
            obj.simHandler.stepBack();
            warning(origBacktraceWarningState,'backtrace');
        end

        function runToTimeStep(obj,timeToPause)
            currentTimeStep=get_param(obj.modelH,'TimeOfMajorStep');
            tout=obj.msObj.cvd.tout;
            idx=...
            Coverage.CovData.binarySearch(tout,timeToPause,0);
            timeToPause=tout(idx);


            origBacktraceWarningState=warning('query','backtrace').state;
            warning('off','backtrace');
            if(timeToPause>currentTimeStep)
                obj.runAndPause(timeToPause);
            elseif(timeToPause<currentTimeStep)
                obj.rollBackAndPause(timeToPause);
            end
            warning(origBacktraceWarningState,'backtrace');
        end

        function runAndPause(obj,timeToPause)
            obj.simHandler.runAndPause(timeToPause);
        end

        function rollBackAndPause(obj,timeToPause)


            obj.msObj.removeSliceRefreshCallbacks();
            cleanupObj=onCleanup(@()obj.msObj.addSliceRefreshCallbacks);

            try
                obj.simHandler.rollBackAndPause(timeToPause);
            catch Mex
                rethrow(Mex);
            end
            obj.msApiObj.setTimeWindow(timeToPause,timeToPause);
            obj.msObj.refreshDynamicSliceForStepFromExistingData();
        end

        function simOut=simulateForCoverage(obj)
            assert(~obj.isFastRestartSupported||~obj.simHandler.isRunning());
            obj.configureCoverageCollection(true);
            obj.msApiObj.simulate();
            obj.configureCoverageCollection(false);


            obj.CoverageFile=obj.msApiObj.CoverageFile;


            obj.updateCoverageDataForConfigs();

            simOut=obj.simHandler.getSimOut();

            if(isempty(simOut)&&~obj.isFastRestartSupported)
                sc=SlicerConfiguration.getConfiguration(obj.modelName);
                simOut=sc.CurrentCriteria.cvd.simData;
            end
        end

        function stopSimulation(obj)
            if obj.simHandler.isRunning()
                obj.simHandler.stopSim();
            end
        end

        function continueSimulation(obj)
            if obj.simHandler.isRunning()
                obj.simHandler.continueSim();
            end
        end

        function runSimulation(obj)
            obj.simHandler.runSim();
        end

        function yesno=isSlicerDialogClosedByUser(obj)
            yesno=obj.closingSlicerDDG;
        end

        function yesno=isModelFastRestartCompatible(obj)
            yesno=obj.isFastRestartSupported;
        end


        function delete(obj)
            obj.restoreDiagnostics();
            obj.removeSlicerCloseListener();
            obj.removeSlicerStepHighlightListener();
            obj.closeSlicer();
            try
                obj.resetModelState();
            catch
            end
        end
    end

    methods(Access=private)
        function setupSlicer(obj)

            set_param(obj.modelH,'FastRestart','on');


            msDDGObj=createSlicerDDG(obj.modelH);


            if isempty(msDDGObj)||msDDGObj.getDialogSource.Model.modelSlicer.hasError


                if~isempty(modelslicerprivate('slicerMapper','get',obj.modelH))
                    obj.msObj=modelslicerprivate('slicerMapper','get',obj.modelH);
                end


                msg=getString(message('stm:general:SlicerLaunchFailure'));
                mex=MException('Stm:DebugUsingSlicer:SlicerLaunchFailure',msg);
                throw(mex);
            end



            if(strcmp(get_param(obj.modelH,'FastRestart'),'off'))
                obj.isFastRestartSupported=false;
            end

            obj.disableSlicerCriteriaPanel(msDDGObj);

            obj.msObj=modelslicerprivate('slicerMapper','get',obj.modelH);
            obj.simHandler=obj.msObj.simHandler;




            obj.configureCoverageCollection(false);


            scfg=SlicerConfiguration.getConfiguration(obj.modelH);
            obj.msApiObj=SLSlicerAPI.SLSlicer(obj.modelH,scfg);


            obj.msApiObj.addConfiguration();
            obj.configureActiveCriterionStyle();


            obj.CoverageFile=obj.msApiObj.CoverageFile;
            obj.msApiObj.UseTimeWindow=~isempty(obj.msApiObj.CoverageFile);


            obj.addSlicerCloseListener();


            obj.addSlicerStepHighlightCompletedListener();
        end

        function resetModelState(obj)
            obj.resetModelSimInputs();


            set_param(obj.modelH,'FastRestart',obj.origFastRestartVal);


            cellfun(@(m,val)set_param(m,'Dirty',val),...
            obj.originalDirtyStatusMap.keys,...
            obj.originalDirtyStatusMap.values);
        end

        function slicerDialogCloseCallback(obj)
            obj.resetModelState();



            obj.closingSlicerDDG=true;
            notify(obj,'eventModelSlicerDialogClosed');
        end

        function addSlicerCloseListener(obj)
            obj.slicerCloseListener=addlistener(obj.msObj,'eventModelSlicerDialogClosed',...
            @(~,~)obj.slicerDialogCloseCallback());
        end

        function removeSlicerCloseListener(obj)
            delete(obj.slicerCloseListener);
            obj.slicerCloseListener=[];
        end

        function addSlicerStepHighlightCompletedListener(obj)
            obj.slicerStepHighlightListener=addlistener(obj.msObj,'eventModelSlicerSimStepHighlighted',...
            @(~,~)obj.notifyHighlightAfterStep);
        end

        function notifyHighlightAfterStep(obj)
            notify(obj,'eventModelSlicerSimStepHighlighted');
        end

        function removeSlicerStepHighlightListener(obj)
            delete(obj.slicerStepHighlightListener);
            obj.slicerStepHighlightListener=[];
        end

        function configureCoverageCollection(obj,val)
            obj.msObj.collectCoverageDuringSimulation=val;
        end

        function updateCoverageDataForConfigs(obj)
            for idx=1:length(obj.msApiObj.Configuration)
                cfg=obj.msApiObj.Configuration(idx);
                if~strcmp(obj.CoverageFile,cfg.CoverageFile)
                    cfg.CoverageFile=obj.CoverageFile;
                end
            end
        end

        function configureActiveCriterionStyle(obj)
            obj.msApiObj.Color='red';
            obj.msApiObj.highlight();
        end

        function disableSlicerCriteriaPanel(~,msDDGObj)
            disableCriteriaPanel(msDDGObj);
        end

        function closeSlicer(obj)
            try
                if~isempty(obj.msObj)&&~isempty(obj.msObj.dlg.getSource)...
                    &&~obj.closingSlicerDDG
                    closeSlicerDDG(obj.msObj.dockedStudio);
                end
            catch
            end
            delete(obj.msApiObj);
            delete(obj.msObj);
        end

        function suppressDiagnostics(obj)
            obj.origDiagnosticsMap=containers.Map('keyType','char','valueType','char');
            s=warning('query','Simulink:blocks:WarnTuningWhenCoverage');
            obj.origDiagnosticsMap('Simulink:blocks:WarnTuningWhenCoverage')=s.state;
            warning('off','Simulink:blocks:WarnTuningWhenCoverage');
        end

        function restoreDiagnostics(obj)
            if(isempty(obj.origDiagnosticsMap))
                return;
            end
            keys=obj.origDiagnosticsMap.keys;
            values=obj.origDiagnosticsMap.values;
            for idx=1:length(keys)
                warning(values{idx},keys{idx});
            end
        end
    end

    methods(Static)

        [value,numSigs]=getValueOfAllSubSignals(simTime,sigValues,numSigs);
        value=getValueOfSelectedSubSignals(simTime,sigValues,reqSignals);
        [value,numSigs]=getValueOfScalarSignal(simTime,sigValues,numSigs);
        truncatedName=getTruncatedSignalName(sigName);
        value=stripString(value);
        newValue=showModifiedPVDforSignal(signal,simTime,numSignalToShow);
    end
end

function map=constructDirtyStatusMap(model)


    allMdls=find_mdlrefs(model,'KeepModelsLoaded',true,...
    'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    map=containers.Map(allMdls,...
    cellfun(@(m)get_param(m,'Dirty'),allMdls,'UniformOutput',false));
end
