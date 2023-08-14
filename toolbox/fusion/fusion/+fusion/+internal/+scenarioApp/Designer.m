classdef Designer<fusion.internal.scenarioApp.BaseApplication



    properties(SetAccess=protected,Hidden)

LayoutManager


DataModel
ViewModel


Simulator


PlatformClassEditor
SensorClassEditor
    end

    properties(Dependent,SetAccess=protected,Hidden)
PlatformPanel
SensorPanel
ScenarioCanvas
SensorCanvas
ScenarioView
TrajectoryTable
    end

    properties(Hidden)
        FocusedComponent='scenario'
    end

    properties(SetAccess=protected,Hidden)
PlatformToAdd
SensorToAdd
    end

    properties(Access=protected,Transient)

ApplicationClosingListener


PlatformsChangedListener
SensorsChangedListener
SensorAddedListener
SensorDeletedListener
CurrentWaypointChangedListener
TrajectoryChangedListener
PlatformSelectedListener
PlatformAddedListener
PlatformDeletedListener


RecordStartedListener
RecordLoggedListener
RecordSelectedListener
RecordCompleteListener
RecordStoppedListener

PlaybackRestartedListener
PlaybackStartedListener
PlaybackPausedListener
PlaybackStoppedListener


PlatformPanelEnableChangedListener
PlatformPanelSignatureDisplayListener
SensorPanelEnableChangedListener


ScenarioViewOptionsChangedListener
ScenarioViewIndicatorChangedListener


ScenarioCanvasModeChangedListener
ScenarioTooltipChangedListener
ScenarioXYLimitsChangedListener
ScenarioTZLimitsChangedListener
ScenarioTZEnableChangedListener
ScenarioTableEnableChangedListener
ScenarioTableEditEnableChangedListener
    end

    methods
        function b=useAppContainer(this)
            b=this.usingWebFigures;
        end

        function this=Designer(varargin)
            this@fusion.internal.scenarioApp.BaseApplication(varargin{:});
            this.DataModel=fusion.internal.scenarioApp.dataModel.DataModel;
            this.ViewModel=fusion.internal.scenarioApp.viewModel.ViewModel;
            this.Simulator=fusion.internal.scenarioApp.Simulator(this);
            this.ApplicationClosingListener=event.listener(this,'ApplicationClosing',@this.onApplicationClosing);
            appContainerSetup(this);
        end

        function tag=getTag(~)
            tag='TrackingScenarioDesigner';
        end

        function name=getName(this)
            name=msgString(this,'AppName');
        end

        function title=getTitle(this)
            title=getTitle@matlabshared.application.ToolGroupFileSystem(this);
        end

        function set.DataModel(this,newModel)


            updateRadarSpecification(newModel);
            this.DataModel=newModel;


            this.PlatformsChangedListener=event.listener(this.DataModel,'PlatformsChanged',@this.onPlatformsChanged);%#ok<*MCSUP>
            this.SensorsChangedListener=event.listener(this.DataModel,'SensorsChanged',@this.onSensorsChanged);
            this.SensorAddedListener=event.listener(this.DataModel,'SensorAdded',@this.onSensorAdded);
            this.SensorDeletedListener=event.listener(this.DataModel,'SensorDeleted',@this.onSensorDeleted);
            this.CurrentWaypointChangedListener=event.listener(this.DataModel,'CurrentWaypointChanged',@this.onCurrentWaypointChanged);
            this.TrajectoryChangedListener=event.listener(this.DataModel,'TrajectoryChanged',@this.onTrajectoryChanged);
            this.PlatformSelectedListener=event.listener(this.DataModel,'NewPlatformSelected',@this.onNewPlatformSelected);
            this.RecordSelectedListener=event.listener(this.DataModel.SimulatorSpecification,'RecordSelected',@this.onRecordSelected);
            this.PlatformAddedListener=event.listener(this.DataModel,'PlatformAdded',@this.onPlatformAdded);
            this.PlatformDeletedListener=event.listener(this.DataModel,'PlatformDeleted',@this.onPlatformDeleted);

            this.RecordStartedListener=event.listener(this.DataModel.SimulatorSpecification,'RecordStarted',@this.onRecordStarted);
            this.RecordLoggedListener=event.listener(this.DataModel.SimulatorSpecification,'RecordLogged',@this.onRecordLogged);
            this.RecordCompleteListener=event.listener(this.DataModel.SimulatorSpecification,'RecordComplete',@this.onRecordComplete);
            this.RecordStoppedListener=event.listener(this.DataModel.SimulatorSpecification,'RecordStopped',@this.onRecordStopped);
            this.PlaybackRestartedListener=event.listener(this.DataModel.SimulatorSpecification,'PlaybackRestarted',@this.onPlaybackRestarted);
            this.PlaybackStartedListener=event.listener(this.DataModel.SimulatorSpecification,'PlaybackStarted',@this.onPlaybackStarted);
            this.PlaybackPausedListener=event.listener(this.DataModel.SimulatorSpecification,'PlaybackPaused',@this.onPlaybackPaused);
            this.PlaybackStoppedListener=event.listener(this.DataModel.SimulatorSpecification,'PlaybackStopped',@this.onPlaybackStopped);

        end

        function set.ViewModel(this,viewModel)
            this.ViewModel=viewModel;


            this.PlatformPanelEnableChangedListener=event.listener(this.ViewModel.PlatformPanel,'PanelEnableChanged',@this.onPlatformPanelEnableChanged);
            this.PlatformPanelSignatureDisplayListener=event.listener(this.ViewModel.PlatformPanel,'SignatureDisplayChanged',@this.onSignatureDisplayChanged);

            this.SensorPanelEnableChangedListener=event.listener(this.ViewModel.SensorPanel,'PanelEnableChanged',@this.onSensorPanelEnableChanged);


            this.ScenarioViewOptionsChangedListener=event.listener(this.ViewModel.ScenarioView,'ViewOptionsChanged',@this.onViewOptionsChanged);
            this.ScenarioViewIndicatorChangedListener=event.listener(this.ViewModel.ScenarioView,'ViewIndicatorChanged',@this.onViewIndicatorChanged);


            this.ScenarioCanvasModeChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'CanvasModeChanged',@this.onScenarioCanvasModeChanged);
            this.ScenarioTooltipChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'TooltipChanged',@this.onScenarioTooltipChanged);
            this.ScenarioXYLimitsChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'XYLimitsChanged',@this.onScenarioXYLimitsChanged);
            this.ScenarioTZLimitsChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'TZLimitsChanged',@this.onScenarioTZLimitsChanged);
            this.ScenarioTZEnableChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'TZEnableChanged',@this.onScenarioCanvasTZEnableChanged);
            this.ScenarioTableEnableChangedListener=event.listener(this.ViewModel.ScenarioCanvas,'TableEnableChanged',@this.onScenarioCanvasTableEnableChanged);
        end

        function open(this,varargin)
            if numel(varargin)==1
                arg=varargin{1};
                if isa(arg,'trackingScenario')

                    if varargin{1}.IsEarthCentered
                        delete(this.Simulator);
                        error(message([this.ResourceCatalog,'ImportGeoScenarioUnsupported']));
                    end
                    importScenario(this,varargin{1});
                elseif isstring(arg)||ischar(arg)&&isvector(arg)
                    openFile(this,varargin{1});
                else
                    delete(this.Simulator);
                    error(message([this.ResourceCatalog,'UnrecognizedArgument']));
                end
            end
            open@fusion.internal.scenarioApp.BaseApplication(this);
            update(this);
        end


        function comp=get.PlatformPanel(this)
            comp=this.LayoutManager.PlatformPanel;
        end

        function comp=get.SensorPanel(this)
            comp=this.LayoutManager.SensorPanel;
        end

        function comp=get.ScenarioCanvas(this)
            comp=this.LayoutManager.ScenarioCanvas;
        end

        function comp=get.SensorCanvas(this)
            comp=this.LayoutManager.SensorCanvas;
        end

        function comp=get.ScenarioView(this)
            comp=this.LayoutManager.ScenarioView;
        end

        function comp=get.TrajectoryTable(this)
            comp=this.LayoutManager.TrajectoryTable;
        end
    end




    methods
        function classSpecs=getPlatformClassSpecifications(this)
            classSpecs=this.DataModel.PlatformClassSpecifications;
        end

        function classSpecs=getSensorClassSpecifications(this)
            classSpecs=this.DataModel.SensorClassSpecifications;
        end

        function simulatorSpecs=getSimulatorSpecifications(this)
            simulatorSpecs=this.DataModel.SimulatorSpecification;
        end

        function[classStrings,classValue]=getSensorPanelClassDropdown(this)


            [classStrings,classValue]=getSensorClassStrings(this.DataModel);

        end

        function[curSensorXYZ,sensorXYZ]=getSensorLocations(this)


            sensorXYZ=zeros(0,3);
            curSensorXYZ=zeros(0,3);

            if~isempty(this.getCurrentPlatform)&&~isempty(this.getCurrentSensor)
                currentPlatformID=this.DataModel.CurrentPlatform.ID;
                allSensors=this.DataModel.SensorSpecifications;
                sensorPlatformIDs=vertcat(allSensors(:).PlatformID);
                currentPlatformSensors=allSensors(ismember(sensorPlatformIDs,currentPlatformID));
                currentSensor=this.getCurrentSensor;
                isCurrentSensor=arrayfun(@(x)isequal(x,currentSensor),currentPlatformSensors);
                if numel(currentPlatformSensors)>1
                    sensorXYZ=vertcat(currentPlatformSensors(~isCurrentSensor).MountingLocation);
                end
                curSensorXYZ=currentSensor.MountingLocation;

                if isempty(sensorXYZ)
                    sensorXYZ=zeros(0,3);
                end
                if isempty(curSensorXYZ)
                    curSensorXYZ=zeros(0,3);
                end
            end
        end

        function[curid,ids,allids]=getCurrentPlatformSensorIDs(this)


            ids=zeros(0,1);
            curid=zeros(0,1);
            allids=zeros(0,1);

            if~isempty(this.getCurrentPlatform)&&~isempty(this.getCurrentSensor)
                currentPlatformID=this.DataModel.CurrentPlatform.ID;
                allSensors=this.DataModel.SensorSpecifications;
                sensorPlatformIDs=vertcat(allSensors(:).PlatformID);
                currentPlatformSensors=allSensors(ismember(sensorPlatformIDs,currentPlatformID));
                currentSensor=this.getCurrentSensor;
                isCurrentSensor=arrayfun(@(x)isequal(x,currentSensor),currentPlatformSensors);
                allids=vertcat(currentPlatformSensors.ID);
                if numel(currentPlatformSensors)>1
                    ids=vertcat(currentPlatformSensors(~isCurrentSensor).ID);
                end
                curid=currentSensor.ID;

                if isempty(ids)
                    ids=zeros(0,1);
                end
                if isempty(curid)
                    curid=zeros(0,1);
                end
            end
        end


        function[curPlatform,index]=getCurrentPlatform(this)
            curPlatform=this.DataModel.CurrentPlatform;
            if~isempty(curPlatform)
                index=find(this.DataModel.PlatformSpecifications==curPlatform,1,'first');
            else
                index=nan;
            end
        end

        function[plats]=getPlatforms(this)
            plats=this.DataModel.PlatformSpecifications;
        end

        function plat=getPlatformByID(this,id)
            plat=this.DataModel.getPlatformByID(id);
        end


        function[curSensor,index]=getCurrentSensor(this)
            curSensor=this.DataModel.CurrentSensor;
            if~isempty(curSensor)
                allSpecs=this.DataModel.getSensorsByPlatform;
                index=find(allSpecs==curSensor,1,'first');
            else
                index=0;
            end
        end

        function sensors=getSensorsByPlatform(this)
            sensors=this.DataModel.getSensorsByPlatform();
        end

        function sensors=getAllSensors(this)
            sensors=this.DataModel.SensorSpecifications;
        end

        function cwp=getCurrentWaypoint(this)
            cwp=this.DataModel.CurrentWaypoint;
        end

        function setCurrentWaypoint(this,idx)
            this.DataModel.CurrentWaypoint=idx;
        end

        function items=getCurrentDropDownItems(this,type)












            switch type
            case 'sensor'
                allSpecs=getSensorsByPlatform(this.DataModel);
            case 'platform'
                allSpecs=this.DataModel.PlatformSpecifications;
            end
            nSpecs=numel(allSpecs);
            items=cell(nSpecs,1);
            for i=1:nSpecs
                name=allSpecs(i).Name;
                items{i}=sprintf('%d: %s',i,name);
            end
        end
    end


    methods
        function selectPlatformByIndex(this,index)
            model=this.DataModel;
            model.CurrentPlatform=model.PlatformSpecifications(index);
        end

        function setCurrentPlatform(this,platform)
            model=this.DataModel;

            index=find(platform==model.PlatformSpecifications,1);
            if~isempty(index)
                selectPlatformByIndex(this,index);
            end
        end

        function setCurrentSensorByIndex(this,index)
            model=this.DataModel;
            [~,indices]=model.getSensorsByPlatform;
            if isempty(indices)
                model.CurrentSensor=fusion.internal.scenarioApp.dataModel.SensorSpecification.empty;
            else
                model.CurrentSensor=model.SensorSpecifications(indices(index));
            end
        end

        function setCurrentSensor(this,sensor)
            model=this.DataModel;
            [sensors,indices]=model.getSensorsByPlatform;
            index=sensors==sensor;

            model.CurrentSensor=model.SensorSpecifications(indices(index));
        end

        function ret=resetCurrentSensor(this)
            ret=this.DataModel.resetCurrentSensor();
        end
    end


    methods(Hidden)

        function updatePlatformPanel(this)
            currentPlatform=this.getCurrentPlatform;
            platformItems=getCurrentDropDownItems(this,'platform');
            update(this.PlatformPanel,currentPlatform,platformItems);
        end

        function updateSensorPanel(this)
            currentSensor=this.getCurrentSensor;
            platformItems=getCurrentDropDownItems(this,'platform');
            sensorItems=getCurrentDropDownItems(this,'sensor');
            update(this.SensorPanel,currentSensor,platformItems,sensorItems);
        end

        function updatePlatformClassEditor(this,info)
            if nargin==2

                this.PlatformClassEditor.ClassInfo(this.PlatformClassEditor.CurrentEntry)=info;
            end
            update(this.PlatformClassEditor);
        end

        function updateSensorClassEditor(this,info)
            if nargin==2

                this.SensorClassEditor.ClassInfo(this.SensorClassEditor.CurrentEntry)=info;
            end
            update(this.SensorClassEditor);
        end

        function updateToolstrip(this)

            sensorItems=getCurrentDropDownItems(this,'sensor');
            platformItems=getCurrentDropDownItems(this,'platform');
            update(this.Toolstrip,platformItems,sensorItems);
        end

        function updateTable(this)
            currentPlatform=this.getCurrentPlatform;
            editEnable=this.TableEditEnable;
            if~isempty(currentPlatform)
                currentTraj=currentPlatform.TrajectorySpecification;
                currentWaypoint=getCurrentWaypoint(this);
                update(this.TrajectoryTable,currentTraj,editEnable,currentWaypoint);
            else
                update(this.TrajectoryTable,[],editEnable,0);
            end
        end

        function updateTableEnable(this)
            enable=this.TableEnable;
            state=matlab.lang.OnOffSwitchState(enable);
            updateTrajectoryTableComponent(this,state);
        end

        function updateSimulationMode(this,state)

            tabgroup=this.Toolstrip;
            if strcmp(state,'on')&&~tabgroup.isSimMode

                switchSimMode(tabgroup,state)


                enterSimulationLayout(this);
            elseif strcmp(state,'off')

                switchSimMode(tabgroup,state)


                this.ScenarioCanvas.Figure.Visible='on';
                this.PlatformPanel.Figure.Visible='on';
                this.ScenarioView.Figure.Visible='on';
                restoreDefaultLayout(this);
            end


        end
    end

    properties(Dependent,Hidden)
EnableGround
EnableTrajectories
EnableWaypoints
EnableCoverage
EnableDetections
EnableIndicator
    end
    methods
        function ret=get.EnableGround(this)
            ret=this.ViewModel.ScenarioView.EnableGround;
        end
        function ret=get.EnableTrajectories(this)
            ret=this.ViewModel.ScenarioView.EnableTrajectories;
        end
        function ret=get.EnableWaypoints(this)
            ret=this.ViewModel.ScenarioView.EnableWaypoints;
        end
        function ret=get.EnableCoverage(this)
            ret=this.ViewModel.ScenarioView.EnableCoverage;
        end
        function ret=get.EnableDetections(this)
            ret=this.ViewModel.ScenarioView.EnableDetections;
        end
        function ret=get.EnableIndicator(this)
            ret=this.ViewModel.ScenarioView.EnableIndicator;
        end
    end


    properties(Dependent,Hidden)
CanvasMode
TooltipString
XYCanvasCenter
XYCanvasUnitsPerPixel
TZEnable
TZCanvasCenter
TZCanvasUnitsPerPixel
TableEnable
TableEditEnable
    end

    methods

        function ret=get.CanvasMode(this)
            ret=this.ViewModel.ScenarioCanvas.CanvasMode;
        end

        function ret=get.TooltipString(this)
            ret=this.ViewModel.ScenarioCanvas.TooltipString;
        end
        function ret=get.XYCanvasCenter(this)
            ret=this.ViewModel.ScenarioCanvas.XYCanvasCenter;
        end
        function ret=get.XYCanvasUnitsPerPixel(this)
            ret=this.ViewModel.ScenarioCanvas.XYCanvasUnitsPerPixel;
        end
        function ret=get.TZEnable(this)
            ret=this.ViewModel.ScenarioCanvas.TZEnable;
        end
        function ret=get.TZCanvasCenter(this)
            ret=this.ViewModel.ScenarioCanvas.TZCanvasCenter;
        end
        function ret=get.TZCanvasUnitsPerPixel(this)
            ret=this.ViewModel.ScenarioCanvas.TZCanvasUnitsPerPixel;
        end
        function ret=get.TableEnable(this)
            ret=this.ViewModel.ScenarioCanvas.TableEnable;
        end
        function ret=get.TableEditEnable(this)
            ret=this.ViewModel.ScenarioCanvas.TableEditEnable;
        end

        function setScenarioCanvasMode(this,newMode)
            this.ViewModel.ScenarioCanvas.CanvasMode=newMode;
        end

        function setScenarioCanvasTooltipString(this,newString)
            this.ViewModel.ScenarioCanvas.TooltipString=newString;
        end
    end


    methods(Hidden)

        function setCurrentTrajectory(this,traj,varargin)

            edit=fusion.internal.scenarioApp.undoredo.SetCurrentTrajectory(...
            this.DataModel,...
            this.getCurrentPlatform,...
            traj,varargin{:});
            applyEdit(this,edit);
        end

        function setCurrentPositionXY(this,xyPoint)
            setCurrentPositionXY(this.DataModel,xyPoint);
        end

        function setCurrentPositionZ(this,newZ)
            setCurrentPositionZ(this.DataModel,newZ);
        end

        function setCurrentWaypointXY(this,newXY)
            setCurrentWaypointXY(this.DataModel,newXY);
        end

        function setCurrentWaypointTZ(this,newTZ)
            setCurrentWaypointTZ(this.DataModel,newTZ);
        end

        function moveCurrentTrajectory(this,template,offset)
            moveCurrentTrajectory(this.DataModel,template,offset);
        end

        function extendCurrentTrajectory(this,template,newXY)
            extendCurrentTrajectory(this.DataModel,template,newXY);
        end

        function replaceCurrentTrajectory(this,replacement)
            replaceCurrentTrajectory(this.DataModel,replacement);
        end

        function changeTrajectory(this,newIdx,newTraj,oldIdx,oldTraj)
            edit=fusion.internal.scenarioApp.undoredo.ChangeTrajectory(...
            this.DataModel,...
            this.DataModel.CurrentPlatform,...
            newIdx,...
            newTraj,...
            oldIdx,...
            oldTraj);
            applyEdit(this,edit);
        end

        function addPlatform(this,newPlatform)

            edit=fusion.internal.scenarioApp.undoredo.AddPlatform(...
            this.DataModel,...
            newPlatform);
            applyEdit(this,edit);
        end

        function addNewPlatformClass(this,info)
            pce=this.PlatformClassEditor;
            allInfo=pce.ClassInfo;
            maxId=-inf;
            for indx=1:numel(allInfo)
                maxId=max(allInfo(indx).id,maxId);
            end

            if nargin<2
                info=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getNewSpecification();
            end
            info.id=maxId+1;

            allInfo(end+1)=info;
            pce.CurrentEntry=numel(allInfo);
            pce.ClassInfo=allInfo;

            update(pce);
        end

        function addNewSensorClass(this,info)
            editor=this.SensorClassEditor;
            allInfo=editor.ClassInfo;
            maxId=-inf;
            for indx=1:numel(allInfo)
                maxId=max(allInfo(indx).id,maxId);
            end

            if nargin<2
                info=fusion.internal.scenarioApp.dataModel.SensorClassSpecifications.getNewSpecification();
            end
            info.id=maxId+1;

            allInfo(end+1)=info;
            editor.CurrentEntry=numel(allInfo);
            editor.ClassInfo=allInfo;

            update(editor);
        end

        function addSensor(this,newSensor)

            edit=fusion.internal.scenarioApp.undoredo.AddSensor(...
            this.DataModel,...
            newSensor);
            applyEdit(this,edit);
        end

        function setSensorProperty(this,name,value,varargin)





            model=this.DataModel;
            if strcmp(name,'Name')
                value=getUniqueName(model.PlatformSpecifications,value);
            end
            current=model.CurrentSensor;
            if any(current==model.SensorSpecifications)
                edit=fusion.internal.scenarioApp.undoredo.SetSensorProperty(...
                model,current,name,value,varargin{:});
                applyEdit(this,edit);
            else
                current.(name)=value;
            end
        end

        function setSensorClassInfoProperty(this,name,varargin)
            editor=this.SensorClassEditor;
            current=editor.ClassInfo(editor.CurrentEntry);
            current.(name);
        end

        function setPlatformClassInfoProperty(this,name,varargin)
            editor=this.PlatformClassEditor;
            current=editor.ClassInfo(editor.CurrentEntry);
            current.(name);
        end


        function setPlatformProperty(this,name,value,varargin)





            model=this.DataModel;
            if strcmp(name,'Name')
                value=getUniqueName(model.PlatformSpecifications,value);
            end
            current=model.CurrentPlatform;
            if any(current==model.PlatformSpecifications)
                edit=fusion.internal.scenarioApp.undoredo.SetPlatformProperty(...
                model,current,name,value,varargin{:});
                applyEdit(this,edit);
            else
                current.(name)=value;
            end
        end

        function deleteCurrentTrajectory(this)
            edit=fusion.internal.scenarioApp.undoredo.DeleteTrajectory(this.DataModel);
            applyEdit(this,edit);
        end


        function setCurrentTrajectoryProperty(this,setTrajectoryMethod,value)
            currentPlatform=this.DataModel.CurrentPlatform;
            if~isempty(currentPlatform)
                traj=copy(currentPlatform.TrajectorySpecification);
                setTrajectoryMethod(traj,value);
                setPlatformProperty(this,'TrajectorySpecification',traj);
            end
        end

        function setAutoTime(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoTime(traj,value),value);
        end

        function setAutoCourse(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoCourse(traj,value),value);
        end

        function setAutoGroundSpeed(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoGroundSpeed(traj,value),value);
        end

        function setAutoClimbRate(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoClimbRate(traj,value),value);
        end

        function setAutoPitch(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoPitch(traj,value),value);
        end

        function setAutoBank(this,value)
            setCurrentTrajectoryProperty(this,@(traj,value)setAutoBank(traj,value),value);
        end

        function setCurrentPlatformDefaultSpeed(this,value)
            currentPlatform=this.DataModel.CurrentPlatform;
            if~isempty(currentPlatform)&&value>0
                traj=copy(currentPlatform.TrajectorySpecification);
                traj.DefaultGroundSpeed=value;
                setPlatformProperty(this,'TrajectorySpecification',traj);
            end
        end

        function onNewPlatformSelected(this,~,~)
            reset=resetCurrentSensor(this.DataModel);
            if reset
                updateSensorPanel(this);
                updateSensorComponents(this);
            end
            onNewPlatformSelected(this.ScenarioCanvas)
            updatePlatformPanel(this)
            updateToolstrip(this);
            updateAndFit(this.SensorCanvas);
            update(this.ScenarioView);
            updateTable(this);
        end

        function onPlatformAdded(this,~,~)

            reset=resetCurrentSensor(this.DataModel);
            if reset
                updateSensorPanel(this);
                updateSensorComponents(this);
            end
            updateAndFit(this.SensorCanvas);


            onNewPlatformSelected(this.ScenarioCanvas);


            onPlatformAdded(this.PlatformPanel);
            setRCSviewerCuts(this.PlatformPanel);
            updatePlatformPanel(this)



            update(this.ScenarioView);


            updateTable(this);


            updateToolstrip(this);


            focusOnComponent(this.PlatformPanel);

            updateCutCopyPasteQab(this);
            setDirty(this);
        end

        function onPlatformDeleted(this,~,~)

            onPlatformsChanged(this);
            updateSensorComponents(this);
            onPlatformDeleted(this.ScenarioCanvas);
        end

        function onPlatformsChanged(this,~,~)

            onPlatformsChanged(this.Simulator)
            this.updateToolstrip();
            updateAndFit(this.SensorCanvas);
            update(this.ScenarioView);
            updateTable(this);
            onPlatformsChanged(this.ScenarioCanvas);
            updatePlatformPanel(this)
            updateCutCopyPasteQab(this);
            setDirty(this);
        end

        function onSensorsChanged(this,~,~)

            onSensorsChanged(this.Simulator)
            updateSensorPanel(this);
            update(this.SensorCanvas);
            update(this.ScenarioView);
            updateToolstrip(this);
            updateCutCopyPasteQab(this);
            setDirty(this);
        end

        function onSensorAdded(this,~,~)
            onSensorAdded(this.ViewModel.SensorPanel);
            updateShowProperties(this.SensorPanel);
            onSensorsChanged(this);
            updateSensorComponents(this,true);
        end

        function onSensorDeleted(this,~,evt)
            onSensorAdded(this.ViewModel.SensorPanel);
            updateShowProperties(this.SensorPanel);

            toDelete=evt.EventData;
            onSensorDeleted(this.SensorCanvas,toDelete);
            onSensorDeleted(this.ScenarioView,toDelete);
            onSensorsChanged(this);
            updateSensorComponents(this,true);
        end

        function onScenarioCanvasTableEnableChanged(this,~,~)
            updateTableEnable(this);
        end

        function onScenarioCanvasTZEnableChanged(this,~,~)
            updateTZEnable(this.ScenarioCanvas);
        end

        function onScenarioCanvasModeChanged(this,~,~)
            updateCanvasMode(this.ScenarioCanvas);
        end

        function onScenarioTooltipChanged(this,~,~)
            updateTooltipString(this.ScenarioCanvas);
        end

        function onScenarioXYLimitsChanged(this,~,~)
            updateLimits(this.ScenarioCanvas);
        end

        function onScenarioTZLimitsChanged(this,~,~)
            updateLimits(this.ScenarioCanvas);
        end

        function onCurrentWaypointChanged(this,~,~)
            onCurrentWaypointChanged(this.ScenarioCanvas);
            updateCurrentWaypoint(this.ScenarioView);
            updateTable(this);
        end

        function onTrajectoryChanged(this,~,~)
            onTrajectoryChanged(this.ScenarioCanvas);
            onTrajectoryChanged(this.ScenarioView);
            updateTable(this);
            updatePlatformPanel(this);
            updateToolstrip(this);
        end


        function onViewOptionsChanged(this,~,~)
            update(this.ScenarioView,false);
        end

        function onViewIndicatorChanged(this,~,~)
            updateIndicator(this.ScenarioView);
        end

        function onRecordSelected(this,~,~)
            onRecordSelected(this.ScenarioView);
            onRecordSelected(this.Simulator);
            update(this.Toolstrip.SimulateSection);
        end

        function onSignatureDisplayChanged(this,~,~)

            sig=this.getCurrentPlatform.RCSSignature;
            updateSignaturePanel(this.PlatformPanel,sig);
        end

        function onPlatformPanelEnableChanged(this,~,~)
            this.PlatformPanel.Enabled=this.ViewModel.PlatformPanel.Enabled;
            updatePlatformPanel(this);
        end

        function onSensorPanelEnableChanged(this,~,~)
            this.SensorPanel.Enabled=this.ViewModel.SensorPanel.Enabled;
            updateSensorPanel(this);
        end
    end


    methods(Hidden)

        function sensorCanvasXZ(this,value)
            this.SensorCanvas.toggleSensorAxes('X-Z',value);
        end

        function sensorCanvasYZ(this,value)
            this.SensorCanvas.toggleSensorAxes('Y-Z',value);
        end

        function varargout=editPlatformClassSpecifications(this)
            cse=this.PlatformClassEditor;
            if isempty(cse)
                cse=fusion.internal.scenarioApp.component.PlatformClassEditor(this);
                addComponent(this,cse,false);
                this.PlatformClassEditor=cse;
            end
            refresh(cse);
            update(cse);
            open(cse);
            if nargout>0
                varargout={cse};
            end
        end

        function varargout=editSensorClassSpecifications(this)
            cse=this.SensorClassEditor;
            if isempty(cse)
                cse=fusion.internal.scenarioApp.component.SensorClassEditor(this);
                addComponent(this,cse,false);
                this.SensorClassEditor=cse;
            end
            refresh(cse);
            update(cse);
            open(cse);
            if nargout>0
                varargout={cse};
            end
        end

        function varargout=createPlatformClassSpecification(this)
            cse=this.PlatformClassEditor;
            if isempty(cse)
                cse=fusion.internal.scenarioApp.component.PlatformClassEditor(this);
                addComponent(this,cse,false);
                this.PlatformClassEditor=cse;
            end
            cse.NewMode=true;
            refresh(cse);
            addNew(cse);
            update(cse);
            open(cse);
            if nargout
                classSpecs=this.DataModel.PlatformClassSpecifications;
                ids=getAllIds(classSpecs);
                waitfor(cse.Figure,'Visible');
                newId=setdiff(getAllIds(classSpecs),ids);
                if isempty(newId)
                    varargout={[]};
                else
                    varargout={classSpecs.getSpecification(newId)};
                end
            end
        end

        function done=importSignatureCallback(this)


            sig=fusion.internal.scenarioApp.component.SignatureImport.import();
            done=~isempty(sig);
            if done
                plat=this.getCurrentPlatform;
                plat.RCSSignature=sig;
                plat.HasConstantRCS=false;
                setRCSviewerCuts(this.PlatformPanel);
                updatePlatformPanel(this)
            end
        end

        function setConstantRCS(this,value)
            curPlat=this.getCurrentPlatform;

            newSig=rcsSignature('Pattern',value);
            curPlat.RCSSignature=newSig;
            curPlat.HasConstantRCS=true;
            setRCSviewerCuts(this.PlatformPanel);
            updateSignaturePanel(this.PlatformPanel,newSig);
        end

        function info=currentPlatformToClassInfo(this,curInfo)
            curPlat=this.getCurrentPlatform;
            if isempty(curPlat)
                info=[];
                return
            end

            info=curInfo;
            info.Length=curPlat.Dimension(1);
            info.Width=curPlat.Dimension(2);
            info.Height=curPlat.Dimension(3);
            info.XOffset=curPlat.Dimension(4);
            info.YOffset=curPlat.Dimension(5);
            info.ZOffset=curPlat.Dimension(6);
            info.OrientationAccuracy=curPlat.OrientationAccuracy;
            info.PositionAccuracy=curPlat.PositionAccuracy;
            info.VelocityAccuracy=curPlat.VelocityAccuracy;
            info.RCSSignature=toStruct(curPlat.RCSSignature);

            updatePlatformClassEditor(this,info);
        end

        function info=currentSensorToClassInfo(this,curInfo)
            spec=this.getCurrentSensor;
            if isempty(spec)
                info=[];
                return
            end

            allprops=properties(spec);


            for i=1:numel(allprops)
                curInfo.(allprops{i})=spec.(allprops{i});
            end

            curInfo=rmfield(curInfo,{'Name','PlatformID','MountingAngles',...
            'MountingLocation','ID','LookAngle'});

            curInfo.MaxMechanicalScanRate=spec.pMaxMechanicalScanRate;
            curInfo.MechanicalScanLimits=spec.pMechanicalScanLimits;
            curInfo.ElectronicScanLimits=spec.pElectronicScanLimits;



            curInfo=rmfield(curInfo,{'MaxAzimuthScanRate','MaxElevationScanRate'});
            curInfo=rmfield(curInfo,{'MechanicalAzimuthLimits','MechanicalElevationLimits'});
            curInfo=rmfield(curInfo,{'ElectronicAzimuthLimits','ElectronicElevationLimits'});
            curInfo=rmfield(curInfo,{'MaxNumReports'});


            info=curInfo;
            updateSensorClassEditor(this,info);
        end

    end



    methods
        function onRecordStarted(this,~,~)
            initTotalTime(this.DataModel);
            onRecordStarted(this.ScenarioView);
            disableWaypoints(this.ViewModel.ScenarioView);
            clearCurrentWaypoint(this.DataModel);
            updateToolstrip(this);
        end

        function onRecordLogged(this,~,~)
            onRecordLogged(this.ScenarioView);
            onRecordLogged(this.Simulator);
            update(this.Toolstrip.SimulateSection);
        end

        function onRecordComplete(this,~,~)
            onRecordComplete(this.Simulator);
        end

        function onRecordStopped(this,~,~)
            onRecordStopped(this.Simulator);
        end

        function onPlaybackRestarted(this,~,~)
            onPlaybackRestarted(this.Simulator);
            onPlaybackRestarted(this.ScenarioCanvas);
            onPlaybackRestarted(this.ScenarioView);
            update(this.Toolstrip.SimulateSection);
        end

        function onPlaybackStarted(this,~,~)
            onPlaybackStarted(this.ScenarioView);
            updateToolstrip(this);

            onPlaybackStarted(this.Simulator);
        end

        function onPlaybackPaused(this,~,~)
            onPlaybackPaused(this.Simulator);
            update(this.Toolstrip.SimulateSection);
        end

        function onPlaybackStopped(this,~,~)
            onPlaybackStopped(this.Simulator);
            updateToolstrip(this);
            update(this.Toolstrip.SimulateSection);
            enableWaypoints(this.ViewModel.ScenarioView);
            onPlaybackStopped(this.ScenarioView);
        end

        function setTimeStatus(this,timeStr)
            setTimeStatus(this.ScenarioView,timeStr);
        end

    end

    methods(Hidden)
        function unblockCalls(this)
            unblockCalls@fusion.internal.scenarioApp(this);
            stop(this.Simulator);
        end

        function approveClose(this)

            clearSilently(this.Simulator);
            approveClose@fusion.internal.scenarioApp.BaseApplication(this);
        end

        function b=allowClose(this,varargin)
            if useAppContainer(this)

                clearSilently(this.Simulator);
            end

            b=allowClose@fusion.internal.scenarioApp.BaseApplication(this,varargin{:});

            if b&&useAppContainer(this)
                delete(this.Simulator);
            end
        end

        function onApplicationClosing(this,~,~)
            delete(this.Simulator);
            deleteGallery(this.Toolstrip.PlatformSection);
            deleteGallery(this.Toolstrip.SensorSection);
        end
    end


    methods(Hidden)
        function b=showRecentFiles(~)
            b=true;
        end

        function new(this,~)
            if allowNew(this)
                new(this.DataModel);
                new@matlabshared.application.ToolGroupFileSystem(this);
                new@matlabshared.application.undoredo.ToolGroupUndoRedo(this);

                this.ViewModel=fusion.internal.scenarioApp.viewModel.ViewModel;
                update(this);
            end
        end

        function success=saveFile(this,varargin)
            success=saveFile@matlabshared.application.ToolGroupFileSystem(this,varargin{:});
            if success
                saveFile@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
                removeDirty(this);
            end
        end

        function success=openFile(this,varargin)
            success=openFile@matlabshared.application.ToolGroupFileSystem(this,varargin{:});
            if success
                openFile@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
            end
        end

        function spec=getSaveFileSpecification(~,~)
            spec={'*.*',getString(message('Spcuilib:application:AllFilesTypeDescription'))};
        end

        function b=isCopyEnabled(this)


            b=~isempty(this.DataModel.CurrentPlatform);
        end
    end


    methods(Hidden)
        function deleteCurrentPlatform(this)
            edit=fusion.internal.scenarioApp.undoredo.DeletePlatform(this.DataModel);
            applyEdit(this,edit);
        end

        function deleteCurrentSensor(this)
            edit=fusion.internal.scenarioApp.undoredo.DeleteSensor(this.DataModel);
            applyEdit(this,edit);
        end

        function duplicateSensor(this)
            this.FocusedComponent='sensor';
            copyItem(this);
            addSensorMode(this,this.CopyPasteBuffer);
        end

        function duplicatePlatform(this)
            this.FocusedComponent='scenario';
            copyItem(this);
            addPlatformMode(this,this.CopyPasteBuffer);
        end

        function spec=struct2sensor(this,sensorStruct)

            sensorStruct.Name=sensorStruct.name;
            sensorStruct.ClassID=sensorStruct.id;

            sensorStruct.MountingLocation=[0,0,0];
            sensorStruct.MountingAngles=[0,0,0];

            sensorStruct=rmfield(sensorStruct,{'id','name','Category'});
            pvPairs=matlabshared.application.structToPVPairs(sensorStruct);
            spec=fusion.internal.scenarioApp.dataModel.RadarSensorSpecification(...
            this.DataModel.CurrentPlatform.ID,pvPairs{:});
        end

        function addSensorMode(this,sensor)

            if isstruct(sensor)
                sensor=this.struct2sensor(sensor);
            end
            this.SensorCanvas.InteractionMode='add.sensor';
            this.SensorToAdd=sensor;
            updateSensorComponents(this,true,true);
            update(this.SensorCanvas);
            focusOnComponent(this.SensorCanvas);
        end

        function platform=struct2plat(~,structPlatform)

            structPlatform.Name=structPlatform.name;
            structPlatform.ClassID=structPlatform.id;

            structPlatform.Position=[0,0,0];
            structPlatform.Dimension=[structPlatform.Length,structPlatform.Width,structPlatform.Height,structPlatform.XOffset,structPlatform.YOffset,structPlatform.ZOffset];
            structPlatform.Orientation=[0,0,0];

            structPlatform=rmfield(structPlatform,{'id','name','Length','Width','Height',...
            'XOffset','YOffset','ZOffset','Category'});

            sigFields={'RCSSignature','TSSignature','IRSignature'};
            fhandles={'rcsSignature','tsSignature','irSignature'};
            for i=1:numel(sigFields)
                sigfield=sigFields{i};
                fun=fhandles{i};
                sig=structPlatform.(sigfield);
                structPlatform.(sigfield)=feval(fun,'Pattern',sig.Pattern,...
                'Elevation',sig.Elevation,...
                'Azimuth',sig.Azimuth,...
                'Frequency',sig.Frequency);
            end
            pvPairs=matlabshared.application.structToPVPairs(structPlatform);
            platform=fusion.internal.scenarioApp.dataModel.PlatformSpecification(pvPairs{:});
        end

        function addPlatformMode(this,platform)

            if isstruct(platform)
                platform=this.struct2plat(platform);
            end
            setCanvasMode(this.ScenarioCanvas.CanvasMode,'AddPlatform');
            this.PlatformToAdd=platform;
            focusOnComponent(this.ScenarioCanvas);
        end

        function deleteClassInfo(this,entry)
            if entry<=numel(this.PlatformClassEditor.ClassInfo)
                this.PlatformClassEditor.ClassInfo(entry)=[];
                update(this.PlatformClassEditor);
            end
        end

        function deleteSensorClassInfo(this,entry)
            if entry<=numel(this.SensorClassEditor.ClassInfo)
                this.SensorClassEditor.ClassInfo(entry)=[];
                update(this.SensorClassEditor);
            end
        end
        function notifyEventToApplicationDataModel(this,eventName)
            notify(this.DataModel,eventName);
        end
    end


    methods(Hidden)

        function toggleSensorAxes(this,evt,src)
            this.SensorCanvas.toggleSensorAxes(evt,src);
        end

        function requestWaypoints(this)
            appendWaypoints(this.ScenarioCanvas)
        end

        function toggleTZAxes(this,state)
            this.ViewModel.ScenarioCanvas.TZEnable=state;
        end

        function toggleTrajectoryTable(this,state)
            this.ViewModel.ScenarioCanvas.TableEnable=state;
        end


        function toggleViewGroundPlane(this,state)
            this.ViewModel.ScenarioView.EnableGround=state;
        end

        function toggleViewTrajectories(this,state)
            this.ViewModel.ScenarioView.EnableTrajectories=state;
        end

        function toggleViewCoverageArea(this,state)
            this.ViewModel.ScenarioView.EnableCoverage=state;
        end

        function toggleViewIndicator(this,state)
            this.ViewModel.ScenarioView.EnableIndicator=state;
        end



        function viewScenarioXY(this)
            viewScenarioXY(this.ScenarioView)
        end

        function viewScenarioXZ(this)
            viewScenarioXZ(this.ScenarioView)
        end

        function viewScenarioYZ(this)
            viewScenarioYZ(this.ScenarioView)
        end


        function goToStart(this)
            goToStart(this.Simulator)
        end

        function stepForward(this)

            stepForward(this.Simulator);
            update(this.Toolstrip.SimulateSection);
        end

        function stepBackward(this)
            stepBackward(this.Simulator);
            update(this.Toolstrip.SimulateSection);
        end

        function run(this)
            if~this.Toolstrip.isSimMode
                this.Simulator.SimulationMode='detections';
                updateSimulationMode(this,'on');
            end
            togglePlay(this.Simulator);
        end

        function runTrajOnly(this)
            updateSimulationMode(this,'on');
            this.Simulator.SimulationMode='nodetections';
            togglePlay(this.Simulator);
        end

        function stopSimulator(this)
            stop(this.Simulator);
            updateSimulationMode(this,'off');
        end

        function setNewSimulationTime(this,newTime)
            setNewSimulationTime(this.DataModel.SimulatorSpecification,newTime);
        end

        function isStarted=isPlaybackStarted(this)
            isStarted=this.DataModel.SimulatorSpecification.isPlaybackStarted();
        end
        function isRunning=isPlaybackRunning(this)
            isRunning=this.DataModel.SimulatorSpecification.isPlaybackRunning();
        end
        function isComplete=isPlaybackComplete(this)
            isComplete=this.DataModel.SimulatorSpecification.isPlaybackComplete();
        end
        function isPaused=isPlaybackPaused(this)
            isPaused=this.DataModel.SimulatorSpecification.isPlaybackPaused();
        end
        function isStopped=isPlaybackStopped(this)
            isStopped=this.DataModel.SimulatorSpecification.isPlaybackStopped();
        end

        function[stopTime,maxStopTime]=getSimulationStopTime(this)
            stopTime=this.DataModel.SimulatorSpecification.StopTime;
            maxStopTime=stopTime;
            if isinf(stopTime)
                plats=this.DataModel.PlatformSpecifications;
                for i=1:numel(plats)
                    platStop=max(plats(i).TrajectorySpecification.TimeOfArrival);
                    if isinf(stopTime)||platStop>stopTime
                        stopTime=platStop;
                    end
                end
            end
        end

        function totalTime=getSimulationTotalTime(this)
            totalTime=this.DataModel.SimulatorSpecification.TotalTime;
        end

        function lastTime=getLastDisplayTime(this)
            lastTime=getLastFiniteTime(this.DataModel);
            if lastTime==0
                lastTime=100;
            end
        end




        function requestXYDrag(this,drag)
            requestXYDrag(this.ScenarioCanvas,drag);
        end

        function requestTZDrag(this,drag)
            requestTZDrag(this.ScenarioCanvas,drag);
        end

        function[recordStart,recordStop,total]=recordLimits(this)
            [recordStart,recordStop,total]=...
            recordLimits(this.DataModel.SimulatorSpecification);
        end

        function entry=currentPlaybackEntry(this)
            entry=this.DataModel.SimulatorSpecification.currentEntry;
        end

        function entries=previousPlaybackEntries(this,n)
            entries=this.DataModel.SimulatorSpecification.entryHistory(n);
        end




        function exportMatlabCode(this,varargin)


            [caz,cel]=view(this.ScenarioView.Axes);
            viewOpts=struct('XLimits',this.ScenarioView.Axes.XLim,...
            'YLimits',this.ScenarioView.Axes.YLim,...
            'ZLimits',this.ScenarioView.Axes.ZLim,...
            'ViewAngles',[caz,cel],...
            'EnableCoverage',this.ViewModel.ScenarioView.EnableCoverage);
            str=generateMatlabCode(this.DataModel,viewOpts,varargin{:});
            matlab.desktop.editor.newDocument(char(str));


        end

        function enterSimulationLayout(this)
            layoutSimulation(this.LayoutManager)
        end

        function restoreDefaultLayout(this)
            updateTrajectoryTableComponent(this,...
            matlab.lang.OnOffSwitchState(this.ViewModel.ScenarioCanvas.TableEnable));
            updateSensorComponents(this);
        end
    end

    methods(Hidden)
        function updatePlatformClassSpecifications(this,classInfo)
            classSpecs=this.DataModel.PlatformClassSpecifications;
            clear(classSpecs);
            for indx=1:numel(classInfo)
                info=classInfo(indx);
                classSpecs.setSpecification(info.id,rmfield(info,'id'));
            end
            updatePlatformGallery(this.Toolstrip.PlatformSection);
        end

        function updateSensorClassSpecifications(this,classInfo)
            classSpecs=this.DataModel.SensorClassSpecifications;
            clear(classSpecs);
            for indx=1:numel(classInfo)
                info=classInfo(indx);
                classSpecs.setSpecification(info.id,rmfield(info,'id'));
            end
            updateSensorGallery(this.Toolstrip.SensorSection)
        end
    end

    methods(Access=protected)

        function parseInputs(this,varargin)
            this.Debug=~isempty(varargin)&&strcmp(varargin,'-debug');
        end

        function item=copyItemImpl(this)
            switch this.FocusedComponent
            case 'scenario'
                item=copy(this.DataModel.CurrentPlatform);
            case 'sensor'
                item=copy(this.DataModel.CurrentSensor);
            end
        end

        function item=cutItemImpl(this)

            model=this.DataModel;
            switch this.FocusedComponent
            case 'scenario'
                edit=fusion.internal.scenarioApp.undoredo.CutPlatform(model);
            case 'sensor'
                edit=fusion.internal.scenarioApp.undoredo.CutSensor(model);
            end
            item=copy(edit.Specification);
            applyEdit(this,edit);
        end

        function pasteItemImpl(this,item,varargin)
            if strcmp(this.FocusedComponent,'scenario')...
                &&isa(item,'fusion.internal.scenarioApp.dataModel.PlatformSpecification')
                newPlatform=pasteItem(this.ScenarioCanvas,item,varargin{:});

                edit=fusion.internal.scenarioApp.undoredo.PastePlatform(...
                this.DataModel,...
                newPlatform);
                applyEdit(this,edit);




                this.CopyPasteBuffer=copy(newPlatform);
            elseif strcmp(this.FocusedComponent,'sensor')...
                &&isa(item,'fusion.internal.scenarioApp.dataModel.SensorSpecification')
                newSensor=pasteItem(this.SensorCanvas,item,varargin{:});

                edit=fusion.internal.scenarioApp.undoredo.PasteSensor(...
                this.DataModel,...
                newSensor);
                applyEdit(this,edit);



                this.CopyPasteBuffer=copy(newSensor);
            end
        end

        function comps=createDefaultComponents(this)

            if useAppContainer(this)
                this.LayoutManager=fusion.internal.scenarioApp.layout.JSLayoutManager(this);
            else
                this.LayoutManager=fusion.internal.scenarioApp.layout.JavaLayoutManager(this);
            end
            comps=createDefaultComponents(this.LayoutManager);
        end

        function h=createToolstrip(this)
            h=fusion.internal.scenarioApp.toolstrip.Toolstrip(this);
        end

        function s=getSaveData(this,~)
            s.DataModel=this.DataModel;
            s.ViewModel=this.ViewModel;
        end

        function processOpenData(this,s,~)

            this.DataModel=s.DataModel;


            this.ViewModel=fusion.internal.scenarioApp.viewModel.ViewModel;




            if~isempty(this.Components)
                update(this);
            end
        end

        function importScenario(this,scenario)

            importWarningHandler=fusion.internal.scenarioApp.WarningHandler([this.ResourceCatalog,'Import']);


            importScenario(this.DataModel,scenario,importWarningHandler);


            displayWarnings(importWarningHandler);


            this.ViewModel=fusion.internal.scenarioApp.viewModel.ViewModel;




            if~isempty(this.Components)
                update(this);
            end
        end

        function p=getIconMatFiles(~)

            p={fullfile(matlabroot,'toolbox','fusion','fusion','+fusion',...
            '+internal','+scenarioApp','icons','classEditorIcons.mat')};
        end

        function update(this)


            updateToolstrip(this);
            update(this.SensorCanvas);
            update(this.ScenarioView,true);
            update(this.ScenarioCanvas);
            updateTable(this);
            if~isempty(getCurrentPlatform(this))
                setRCSviewerCuts(this.PlatformPanel);
            end
            updatePlatformPanel(this)
            updateSensorPanel(this);
            updateSensorComponents(this);
            onViewModelLoaded(this.ScenarioCanvas);
        end

    end

    methods

        function pos=getPositionAroundCenter(this,size)
            pos=this.LayoutManager.getPositionAroundCenter(size);
        end

    end

    methods(Access=protected)

        function updateComponents(this,notFirstCall)
            if nargin<2
                notFirstCall=false;
            end
            this.LayoutManager.updateComponents(notFirstCall);
        end

        function updateTrajectoryTableComponent(this,state)
            setVisibility(this.TrajectoryTable,state);
            drawnow;
            this.LayoutManager.updateTrajectoryTableComponent(state);
        end

        function updateSensorComponents(this,bringToFront,visible)
            if nargin<3
                visible=~isempty(this.getCurrentSensor)||...
                strcmp(this.SensorCanvas.InteractionMode,'add.sensor');
            end
            if nargin<2
                bringToFront=false;
            end
            updateSensorComponents(this.LayoutManager,visible);
            if bringToFront
                focusOnComponent(this.SensorPanel);
                focusOnComponent(this.SensorCanvas);
            end
        end

    end
end

function name=getUniqueName(specs,name)

    if isempty(specs)
        return;
    end

    rawName=name;


    rawName(regexp(rawName,'(\d+)$'):end)=[];
    indx=1;
    allNames={specs.Name};
    while any(strcmp(allNames,name))
        name=sprintf('%s%d',rawName,indx);
        indx=indx+1;
    end

end