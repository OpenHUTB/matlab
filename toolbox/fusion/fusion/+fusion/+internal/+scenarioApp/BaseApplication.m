classdef(Abstract)BaseApplication<...
    matlabshared.application.Application&...
    matlabshared.application.ToolGroupFileSystem&...
    matlabshared.application.ToolGroupCutCopyPaste&...
    matlabshared.application.undoredo.ToolGroupUndoRedo


    properties(Constant,Hidden)
        ResourceCatalog='fusion:trackingScenarioApp:Designer:'
    end

    properties(Hidden,Transient)
CallbackErrorHandler
        Debug=false
    end

    methods
        function this=BaseApplication(varargin)
            this@matlabshared.application.Application(varargin{:});
            setupErrorHandler(this);
        end

        function setupErrorHandler(this)
            errorHandler=fusion.internal.scenarioApp.ErrorHandler;
            errorHandler.PreambleID=strcat(this.ResourceCatalog,'ErrorPreamble');
            errorHandler.CleanupFcn=@(ex)this.unblockCallbacks;
            errorHandler.Debug=this.Debug;
            this.CallbackErrorHandler=errorHandler;
        end

        function str=msgString(this,tagPrefix,varargin)
            str=getString(message(strcat(this.ResourceCatalog,tagPrefix),varargin{:}));
        end

        function helpCallback(~,~,~)
            helpview(fullfile(docroot,'fusion','helptargets.map'),...
            'trackingScenarioDesigner');
        end
    end

    methods(Hidden)
        function runCallback(this,cb,varargin)
            if this.IsBusy


                this.CallbackQueue{end+1}=[{cb},varargin];
                return;
            else
                this.IsBusy=true;


                execute(this.CallbackErrorHandler,cb,varargin{:});



                while~isempty(this.CallbackQueue)
                    info=this.CallbackQueue{1};
                    this.CallbackQueue(1)=[];
                    info{1}(info{2:end});
                end
                this.IsBusy=false;
            end
        end

        function unblockCallbacks(this)
            if this.IsBusy
                this.CallbackQueue={};
                this.IsBusy=false;
            end
        end
    end


    methods(Hidden)
        function appContainerSetup(this)
            if useAppContainer(this)
                s=settings;
                s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue=1;
                s.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue=1;
                s.matlab.ui.internal.dialog.Decaf.TemporaryValue=1;
            end
        end

        function shown=showComponent(~,component)
            shown=false;
            if~matlab.lang.OnOffSwitchState(component.Figure.Visible)
                component.Figure.Visible='on';
            end

            if~component.FigureDocument.Visible
                component.FigureDocument.Visible=true;
                shown=true;
            end
        end

        function hidden=hideComponent(~,component)
            hidden=false;
            if matlab.lang.OnOffSwitchState(component.Figure.Visible)
                component.Figure.Visible='off';
            end

            if component.FigureDocument.Visible
                component.FigureDocument.Visible=false;
                hidden=true;
            end
        end

        function updated=updateComponentVisibility(~,component)
            updated=false;
            visible=matlab.lang.OnOffSwitchState(component.Figure.Visible);
            if visible~=component.FigureDocument.Visible
                component.FigureDocument.Visible=visible;
                updated=true;
            end
        end

    end


    properties(Abstract,Dependent,Hidden)

CanvasMode
TooltipString
XYCanvasCenter
XYCanvasUnitsPerPixel
TZEnable
TZCanvasCenter
TZCanvasUnitsPerPixel
TableEnable
TableEditEnable

EnableGround
EnableTrajectories
EnableWaypoints
EnableCoverage
EnableDetections
EnableIndicator
    end

    properties(SetAccess=protected,Hidden,Abstract)
ViewModel


PlatformToAdd
SensorToAdd
    end

    methods(Abstract)
        new(this,tag)
        openFile(this,tag)
        getTitle(this)
        saveFile(this,tag)

        addSensorMode(this,sensor)
        addPlatformMode(this,platform)

        updatePlatformPanel(this)
        updateSensorPanel(this)

        sensorXYZ=getSensorLocations(this)
        [curid,ids,allids]=getCurrentPlatformSensorIDs(this)
        sensors=getSensorsByPlatform(this)
        sensors=getAllSensors(this);

        platforms=getPlatforms(this)
        [curPlatform,index]=getCurrentPlatform(this)
        platform=getPlatformByID(this,id)
        [curSensor,index]=getCurrentSensor(this)
        selectPlatformByIndex(this,index)
        setCurrentPlatform(this,platform)
        setCurrentSensorByIndex(this,index)
        setCurrentSensor(this,sensor)
        resetCurrentSensor(this)
        deleteCurrentPlatform(this)
        deleteCurrentSensor(this)
        deleteClassInfo(this,entry)
        deleteSensorClassInfo(this,entry)
        duplicatePlatform(this)
        duplicateSensor(this)

        varargout=editPlatformClassSpecifications(this)
        varargout=editSensorClassSpecifications(this)
        classSpecs=getPlatformClassSpecifications(this)
        classSpecs=getSensorClassSpecifications(this)
        updatePlatformClassSpecifications(this,info)
        updateSensorClassSpecifications(this,info)
        updatePlatformClassEditor(this,info)
        updateSensorClassEditor(this,info)

        restoreDefaultLayout(this)
        exportMatlabCode(this,varargin)
        deleteCurrentTrajectory(this)
        moveCurrentTrajectory(this,template,offset)
        extendCurrentTrajectory(this,template,newXY)
        changeTrajectory(this,newIdx,newTraj,oldIdx,oldTraj)
        setAutoTime(this,value)
        setAutoCourse(this,value)
        setAutoGroundSpeed(this,value)
        setAutoClimbRate(this,value)
        setAutoPitch(this,value)
        setAutoBank(this,value)

        cwp=getCurrentWaypoint(this);
        setCurrentWaypoint(this,idx)
        requestWaypoints(this)
        setCurrentWaypointXY(this,newXY)
        setCurrentWaypointTZ(this,newTZ)
        setCurrentPositionZ(this,newZ)
        replaceCurrentTrajectory(this,replacement)
        toggleTrajectoryTable(this,state)
        toggleTZAxes(this,state)

        setCurrentTrajectory(this,traj)

        goToStart(this)
        stepForward(this)
        stepBackward(this)
        run(this)
        setNewSimulationTime(this,newTime);
        isStarted=isPlaybackStarted(this);
        isRunning=isPlaybackRunning(this);
        isComplete=isPlaybackComplete(this);
        isPaused=isPlaybackPaused(this);
        isStopped=isPlaybackStopped(this);
        [stopTime,maxStopTime]=getSimulationStopTime(this);
        totalTime=getSimulationTotalTime(this);
        time=getLastDisplayTime(this)
        [recordStart,recordStop,total]=recordLimits(this)
        entry=currentPlaybackEntry(this)
        entries=previousPlaybackEntries(this,n)

        done=importSignatureCallback(this)

        addSensor(this,sensor)
        addPlatform(this,platform)
        setPlatformProperty(this,name,value,varargin)
        setSensorProperty(this,name,value,varargin)
        addNewPlatformClass(this,info)
        addNewSensorClass(this,info)

        toggleViewGroundPlane(this,state)
        toggleViewTrajectories(this,state)
        toggleViewCoverageArea(this,state)
        toggleViewIndicator(this,state)
        viewScenarioXY(this)
        viewScenarioXZ(this)
        viewScenarioYZ(this)

        setScenarioCanvasTooltipString(this,newString);
        setScenarioCanvasMode(this,newMode);
        setCurrentPositionXY(this,xyPoint);
        requestTZDrag(this,drag);
        requestXYDrag(this,drag);

        pos=getPositionAroundCenter(this,size)

        notifyEventToApplicationDataModel(this,eventName)
    end
    methods(Access=protected,Abstract)
        pasteItemImpl(this,varargin)
    end
end