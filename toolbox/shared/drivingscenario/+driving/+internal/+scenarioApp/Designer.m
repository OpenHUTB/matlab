% 构造驾驶场景设计器的主类
classdef Designer<driving.internal.scenarioApp.Display&...
        driving.internal.scenarioApp.ScenarioBuilder&...
        matlabshared.application.undoredo.ToolGroupUndoRedo&...
        matlabshared.application.ToolGroupCutCopyPaste&...
        matlabshared.application.ToolGroupFileSystem

    properties(Hidden)
        MostRecentCanvas='scenario';
        Sim3dScene='';
    end

    properties(Hidden,Constant)
        IsADTInstalled=~isempty(ver('driving'));
    end

    properties(SetAccess=protected,Hidden)
        RoadProperties;
        ActorProperties;
        BarrierProperties;
        SensorCanvas;
        SensorProperties;
        BirdsEyePlot;
        ActorAdder;
        ActorAligner;
        RoadAdder;
        BarrierAdder;
        SensorAdder;
        ClassEditor;
        GamingEngineViewer;  % 游戏引擎查看器
        SimulationSettings;
        ViewCache;
        RoadCreationInProgress=false;
        ShouldClearLargeRoadWarning=false;
        RoadCreationTimer;
        ShowAxesOrientation=false;
        ShowOpenStreetMapImport=true;
        ShowExport3dSim=false;
        ShowPlacementSection=false;
        ShowZenrinJapanMapImport=true;
    end

    properties(Access=protected)
        PropertyListener;
        SimulatorListener;
        WaypointsChangedListener;
        ScenarioCanvasModeChangedListener;
        ScenarioCanvasSelectionChangedListener;
        GamingEngineWindowClosedListener;
        RestartPlayer=false;
        NeedsAutoScale=false;
        ShowAsymmetricRoads=false;
        LoadWarning
    end

    events(NotifyAccess=public)
        CurrentSensorChanged;
        CurrentRoadChanged;
        CurrentActorChanged;
        CurrentBarrierChanged;
        RoadPropertyChanged;
        BarrierPropertyChanged;
        ActorPropertyChanged;
        NumRoadsChanging;
        NumActorsChanging;
        NumBarriersChanging
        NumRoadsChanged;
        NumActorsChanged;
        NumBarriersChanged;
        NewScenario;
    end

    properties(Hidden)
        HEREHDLiveMapImportArgs={}
        OpenStreetMapImportArgs={}
        UseIRAdapters=true;
        ShowImportErrors=true;
        ShowExportErrors=true;
        ZenrinJapanMapImportArgs={}
        OpenSCENARIOExportArgs={}
    end

    methods
        function this=Designer(varargin)
            this@driving.internal.scenarioApp.Display(varargin{:});
            this.SimulatorListener=addStateChangedListener(this.Simulator,@this.onSimulatorStateChanged);
        end

        function open(this)
            open@driving.internal.scenarioApp.Display(this);
            autoScale(this);
        end


        function title=getTitle(this)
            fileName=getCurrentFileName(this);
            if isempty(fileName)
                fileName='untitled';
            end
            [~,fileName]=fileparts(char(fileName));
            title=getString(message('driving:scenarioApp:ScenarioBuilderNameWithFileName',fileName));

            if this.IsDirty
                title=sprintf('%s*',title);
            end
        end

        function sensor=getCurrentSensor(this)
            index=getCurrentSensorIndex(this);
            sensors=this.SensorSpecifications;
            if isempty(index)||index>numel(sensors)
                sensor=[];
            else
                sensor=this.SensorSpecifications(index);
            end
        end

        function index=getCurrentSensorIndex(this)
            props=this.SensorProperties;
            if isempty(props)
                if isempty(this.SensorSpecifications)
                    index=[];
                else
                    index=1;
                end
            else
                index=props.SpecificationIndex;
            end
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:ScenarioBuilderName'));
        end

        function tag=getTag(~)
            tag='DrivingScenarioDesigner';
        end

        function str=generateMatlabCode(this,functionName)
            if nargin<2
                functionName=this.CurrentFileName;
                if isempty(functionName)
                    functionName='';
                else
                    [~,functionName]=fileparts(functionName);
                end
            end
            if~isempty(functionName)
                functionName=matlab.lang.makeValidName(functionName,'Prefix','ds');
            end
            str=generateMatlabCode@driving.internal.scenarioApp.ScenarioBuilder(...
                this,functionName,this.EgoCarId,getStopTime(this.Simulator));
        end

        function generateOpenScenarioFile(this,warning)
            if~isempty(warning)
                exportOpenScenarioFileWarning(this,warning+"");
            end
        end

        function modelName=generateSimulinkModel(this,mode)
            modelName='';
            cancel=getString(message('Spcuilib:application:Cancel'));
            saveAs=getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogSaveAs'));

            success=true;
            switch mode
                case 'scenario'
                    fileName=this.CurrentFileName;
                    if isempty(fileName)
                        selection=uiconfirm(this,getString(message('driving:scenarioApp:ExportSimulinkModelUnsavedSessionText')),...
                            getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogTitle')),...
                            {saveAs,cancel},cancel);
                        switch selection
                            case saveAs
                                success=this.saveFileAs();
                            case cancel
                                return
                        end
                    elseif this.IsDirty
                        save=getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogSave'));
                        selection=uiconfirm(this,getString(message('driving:scenarioApp:ExportSimulinkModelDirtySessionText')),...
                            getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogTitle')),...
                            {save,saveAs,cancel},cancel);
                        switch selection
                            case save
                                success=this.saveFile();
                            case saveAs
                                success=this.saveFileAs();
                            case cancel
                                return;
                        end
                    end
                    fileName=getCurrentFileName(this);
                case 'sensor'
                    fileName=[];
            end
            if success
                modelName=generateSimulinkModel@driving.internal.scenarioApp.ScenarioBuilder(...
                    this,getStopTime(this.Simulator.Player),fileName);
            else
                errorMessage(this,...
                    getString(message('driving:scenarioApp:ExportSimulinkModelNotExportedDialogText')),...
                    getString(message('driving:scenarioApp:ExportSimulinkModelNotExportedDialogTitle')));
            end
        end

        function[modelName,warnings]=generate3dSimModel(this)
            freezeUserInterface(this);
            modelName='';
            warnings={};
            cancel=getString(message('Spcuilib:application:Cancel'));
            saveAs=getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogSaveAs'));



            scene=this.Sim3dScene;
            if isempty(scene)
                ok=getString(message('MATLAB:uistring:popupdialogs:OK'));
                selection=uiconfirm(this,getString(message('driving:scenarioApp:Export3dSimModelNoSceneText')),...
                    getString(message('driving:scenarioApp:Export3dSimModelNoSceneTitle')),...
                    {ok,cancel},cancel);
                if strcmp(selection,cancel)
                    return;
                end
            end

            dirty=this.IsDirty;
            sessionName=this.CurrentFileName;
            assetTypes={this.ActorSpecifications.AssetType};
            validTypes={'MuscleCar','Sedan','SportUtilityVehicle','SmallPickupTruck','Hatchback','BoxTruck'};
            if~isempty(setdiff(assetTypes,validTypes))


                removeAndSave=getString(message('driving:scenarioApp:Export3dSimRemoveInvalidAndSave'));
                if isempty(sessionName)||dirty


                    keep=getString(message('driving:scenarioApp:Export3dSimKeepInvalidAndSave'));
                else
                    keep=getString(message('driving:scenarioApp:Export3dSimKeepInvalid'));
                end


                selection=uiconfirm(this,getString(message('driving:scenarioApp:Export3dSimModelInvalidAssetTypesText')),...
                    getString(message('driving:scenarioApp:Export3dSimModelInvalidAssetTypesTitle')),...
                    {keep,removeAndSave,cancel},cancel);

                switch selection
                    case keep
                        if dirty||isempty(sessionName)
                            success=this.saveFile();
                        else
                            success=true;
                        end
                    case removeAndSave


                        badIndex=find(~cellfun(@(v)any(strcmp(v,validTypes)),assetTypes));


                        edit=driving.internal.scenarioApp.undoredo.DeleteActor(this,badIndex);


                        execute(edit);



                        success=this.saveFileAs();
                        if success


                            addEditNoApply(this,edit);
                        else

                            undo(edit);
                            if~dirty


                                removeDirty(this);
                            end
                        end
                    case{cancel,''}
                        return;
                end
            elseif isempty(sessionName)


                selection=uiconfirm(this,getString(message('driving:scenarioApp:ExportSimulinkModelUnsavedSessionText')),...
                    getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogTitle')),...
                    {saveAs,cancel},cancel);
                switch selection
                    case saveAs
                        success=this.saveFile();
                    case cancel
                        return;
                end
            elseif dirty


                save=getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogSave'));
                selection=uiconfirm(this,getString(message('driving:scenarioApp:ExportSimulinkModelDirtySessionText')),...
                    getString(message('driving:scenarioApp:ExportSimulinkModelSaveDialogTitle')),...
                    {save,saveAs,cancel},cancel);
                success=false;
                switch selection
                    case save
                        success=this.saveFile();
                    case saveAs
                        success=this.saveFileAs();
                    case{cancel,''}
                        return;
                end
            else
                success=true;
            end
            if success
                [modelName,warnings]=generate3dSimModel@driving.internal.scenarioApp.ScenarioBuilder(...
                    this,getStopTime(this.Simulator.Player),this.getCurrentFileName,this.EgoCarId,scene);
            else
                errorMessage(this,...
                    getString(message('driving:scenarioApp:ExportSimulinkModelNotExportedDialogText')),...
                    getString(message('driving:scenarioApp:ExportSimulinkModelNotExportedDialogTitle')));
            end
        end

        function actorAdder=getActorAdder(this)
            actorAdder=this.ActorAdder;
            if isempty(actorAdder)
                actorAdder=driving.internal.scenarioApp.ActorAdder(this);
                this.ActorAdder=actorAdder;
            end
        end

        function actorAligner=getActorAligner(this)
            actorAligner=this.ActorAligner;
            if isempty(actorAligner)
                actorAligner=driving.internal.scenarioApp.ActorAligner(this);
                this.ActorAligner=actorAligner;
            end
        end


        function barrierAdder=getBarrierAdder(this)
            barrierAdder=this.BarrierAdder;
            if isempty(barrierAdder)
                barrierAdder=driving.internal.scenarioApp.BarrierAdder(this);
                this.BarrierAdder=barrierAdder;
            end
        end

        function roadAdder=getRoadAdder(this)
            roadAdder=this.RoadAdder;
            if isempty(roadAdder)
                roadAdder=driving.internal.scenarioApp.RoadAdder(this);
                this.RoadAdder=roadAdder;
            end
        end

        function sensorAdder=getSensorAdder(this)
            sensorAdder=this.SensorAdder;
            if isempty(sensorAdder)
                sensorAdder=driving.internal.scenarioApp.SensorAdder(this);
                this.SensorAdder=sensorAdder;
            end
        end

        function alertAndDelete(this,varargin)
            if isPlaying(this.Simulator)
                vetoClose(this.ToolGroup);
            else
                alertAndDelete@matlabshared.application.Application(this,varargin{:});
            end
        end

        function close(this)
            stop(this.Simulator);
            close@driving.internal.scenarioApp.Display(this);
        end

        function initializeClose(this)
            stop(this.Simulator);
            initializeClose@driving.internal.scenarioApp.Display(this);
        end

        function new(this,tag,force)
            if nargin>2&&force||allowNew(this)

                stop(this.Simulator);
                scenarioCanvas=this.ScenarioView;
                exitInteractionMode(scenarioCanvas);
                scenarioCanvas.CurrentSpecification=[];
                new@driving.internal.scenarioApp.ScenarioBuilder(this,tag);
                new@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
                new@matlabshared.application.ToolGroupFileSystem(this);
                update(this.RoadProperties);
                update(this.ActorProperties);

                barrierProps=this.BarrierProperties;
                if~isempty(barrierProps)
                    update(barrierProps);
                end
                sensorProps=this.SensorProperties;
                if~isempty(sensorProps)
                    update(sensorProps);
                end
                bep=this.BirdsEyePlot;
                if~isempty(bep)
                    bep.IsCoverageStale=true;
                    clearData(bep);
                    clear(bep);
                end
                sensorCanvas=this.SensorCanvas;
                if~isempty(sensorCanvas)
                    update(sensorCanvas);
                end


                hScenarioView=this.ScenarioView;
                if hScenarioView.isInteracting
                    hScenarioView.exitInteraction;
                end
                hScenarioView.VerticalAxis=hScenarioView.DefaultVerticalAxis;
                hScenarioView.EnableRoadInteractivity=hScenarioView.DefaultRoadInteractivity;
                if any(strcmp(tag,{'session','sensors'}))
                    focusOnComponent(this.EgoCentricView);
                    focusOnComponent(this.RoadProperties);
                    updateExport(this.Toolstrip);
                end
                if any(strcmp(tag,{'session','scenario'}))
                    focusOnComponent(this.ScenarioView);
                    updateExport(this.Toolstrip);
                    notify(this,'NewScenario');
                end
                updateCutCopyPasteQab(this);
            end
        end

        function varargout=addRoad(this,varargin)
            roadSpec=addRoad@driving.internal.scenarioApp.ScenarioBuilder(this,varargin{:});

            updateForNewRoad(this,roadSpec);
            if nargout
                varargout={roadSpec};
            end
        end

        function varargout=deleteRoad(this,index)
            exitInteractionMode(this.ScenarioView);
            roadProps=this.RoadProperties;
            if index==roadProps.SpecificationIndex||roadProps.SpecificationIndex>=numel(this.RoadSpecifications)
                roadProps.SpecificationIndex=1;
            end
            deletedRoad=deleteRoad@driving.internal.scenarioApp.ScenarioBuilder(this,index);

            canvas=this.ScenarioView;
            if isequal(deletedRoad,canvas.CurrentSpecification)
                canvas.CurrentSpecification=[];
            end
            setDirty(this);
            updateCutCopyPasteQab(this);
            updateExport(this.Toolstrip);
            if nargout>0
                varargout={deletedRoad};
            end
        end

        function varargout=deleteBarrier(this,index)

            barrierProps=this.getBarrierPropertiesComponent();
            nSpecs=numel(this.BarrierSpecifications);
            canvas=this.ScenarioView;
            if any(index==barrierProps.SpecificationIndex)||barrierProps.SpecificationIndex>=nSpecs
                barrierProps.SpecificationIndex=1;
            end

            deletedBarrier=deleteBarrier@driving.internal.scenarioApp.ScenarioBuilder(this,index);

            if~isempty(canvas.CurrentSpecification)&&any(canvas.CurrentSpecification==deletedBarrier)
                canvas.CurrentSpecification=[];
            end
            setDirty(this);
            updateCutCopyPasteQab(this);
            update(barrierProps);
            updateExport(this.Toolstrip);
            if nargout>0
                varargout={deletedBarrier};
            end
        end

        function varargout=deleteActor(this,index)

            actorProps=this.ActorProperties;
            nSpecs=numel(this.ActorSpecifications);
            canvas=this.ScenarioView;

            index=index(:)';

            if any(index==actorProps.SpecificationIndex)||all(actorProps.SpecificationIndex>=nSpecs)
                actorProps.SpecificationIndex=1;
            end
            if strcmp(canvas.InteractionMode,'addActorWaypoints')&&canvas.ActorID>nSpecs-1
                canvas.InteractionMode='none';
            end
            deletedActor=deleteActor@driving.internal.scenarioApp.ScenarioBuilder(this,index);
            oldEgo=this.EgoCarId;


            if~isempty(oldEgo)
                if any(oldEgo==index)
                    newEgo=[];



                    actorSpecs=this.ActorSpecifications;
                    for indx=1:numel(actorSpecs)
                        if getProperty(this.ClassSpecifications,actorSpecs(indx).ClassID,'isVehicle')
                            newEgo=indx;
                            break;
                        end
                    end
                    this.EgoCarId=newEgo;
                else
                    this.EgoCarId=oldEgo-sum(oldEgo>index);
                end
            end
            if~isempty(canvas.CurrentSpecification)&&any(canvas.CurrentSpecification==deletedActor)
                canvas.CurrentSpecification=[];
            end
            updateClassEditor(this);
            setDirty(this);
            updateCutCopyPasteQab(this);
            updateExport(this.Toolstrip);
            if this.ShowSimulators
                updateToolstrip(this.Simulator);
            else
                update(this.Toolstrip.SimulateSection);
            end
            if nargout>0
                varargout={deletedActor};
            end
        end

        function varargout=addActor(this,varargin)

            actorSpec=addActor@driving.internal.scenarioApp.ScenarioBuilder(this,varargin{:});

            updateForNewActor(this,actorSpec);
            if nargout
                varargout={actorSpec};
            end
        end

        function varargout=addBarrier(this,varargin)

            barrierSpec=addBarrier@driving.internal.scenarioApp.ScenarioBuilder(this,varargin{:});

            updateForNewBarrier(this,barrierSpec);
            if nargout
                varargout={barrierSpec};
            end
        end

        function varargout=addSensor(this,varargin)

            hSensor=addSensor@driving.internal.scenarioApp.ScenarioBuilder(this,varargin{:});

            sp=getSensorPropertiesComponent(this);
            sp.SpecificationIndex=numel(this.SensorSpecifications);
            updateForSensors(this);
            setDirty(this);
            if nargout>0
                varargout={hSensor};
            end
        end

        function varargout=deleteSensor(this,index)
            [varargout{1:nargout}]=deleteSensor@driving.internal.scenarioApp.ScenarioBuilder(this,index);
            sensorProps=getSensorPropertiesComponent(this);
            if index==sensorProps.SpecificationIndex||sensorProps.SpecificationIndex>=numel(this.SensorSpecifications)
                sensorProps.SpecificationIndex=1;
            end
            update(sensorProps);
            bep=this.BirdsEyePlot;
            bep.IsCoverageStale=true;
            update(bep);
            update(getSensorCanvasComponent(this));
            updateForSensors(this);
        end

        function addRoadCenters(this,varargin)




            addRoadCenters@driving.internal.scenarioApp.ScenarioBuilder(this,varargin{:});
            setDirty(this);
        end

        function delete(this)
            this.SimulatorListener=[];
            this.PropertyListener=[];
            delete@driving.internal.scenarioApp.Display(this);
        end

        function v=getVerticalAxis(this)
            if~isempty(this.ScenarioView)
                v=this.ScenarioView.VerticalAxis;
            else
                v=getVerticalAxis@driving.internal.scenarioApp.ScenarioBuilder(this);
            end
        end
    end

    methods(Hidden)

        function[b,product,appName]=shouldSupportDDUX(~)
            b=true;
            product='Automated Driving Toolbox';
            appName='Driving Scenario Designer';
        end

        function title=getDocumentGroupTitle(~,tag)
            if strcmp(tag,'WorkingArea')
                title=getString(message('driving:scenarioApp:WorkingAreaGroupTitle'));
            else
                title=tag;
            end
        end
        function createStatusItems(this)
            setStatus(this,'','main');
        end

        function pos=getDefaultPosition(~)
            pos=matlabshared.application.getInitialToolPosition([1280,768],0.7,true);
        end

        % 获得虚幻引擎查看器
        function v=getGamingEngineViewer(this, force, varargin)
            v=this.GamingEngineViewer;
            if isempty(v) && nargin>1 && force
                % 构建虚幻引擎查看器
                v=driving.internal.scenarioApp.GamingEngineScenarioViewer(this,varargin{:});
                % 监听虚幻引擎窗口关闭的事件
                this.GamingEngineWindowClosedListener = event.listener(v,...
                    'WindowClosed', @this.onGamingEngineWindowClosed);
                this.GamingEngineViewer = v;
            end
        end

        function sc=getSensorCanvasComponent(this,isOpening)
            sc=this.SensorCanvas;
            if~isempty(sc)||nargin>1&&isOpening&&isempty(this.SensorSpecifications)
                return;
            end
            sc=driving.internal.scenarioApp.SensorCanvas(this);
            this.SensorCanvas=sc;
            if nargin>1&&isOpening
                return;
            end
            addComponent(this,sc);
            if~useAppContainer(this)
                sc.Figure.Visible=true;
                drawnow
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setClientLocation(getName(sc),this.ToolGroup.Name,...
                    md.getClientLocation(md.getClient(getName(this.ScenarioView),this.ToolGroup.Name)));
            end
        end

        function bep=getBirdsEyePlotComponent(this,isOpening)
            bep=this.BirdsEyePlot;
            if~isempty(bep)||isempty(this.SensorSpecifications)
                return;
            end
            bep=driving.internal.scenarioApp.BirdsEyePlot(this);
            this.BirdsEyePlot=bep;

            aLimits=this.ViewCache;
            if isfield(aLimits,'BirdsEyePlot')&&~isempty(aLimits.BirdsEyePlot)
                bepLimits=aLimits.BirdsEyePlot;
                if isfield(bepLimits,'XLim')
                    bep.Axes.XLim=bepLimits.XLim;
                    bep.Axes.YLim=bepLimits.YLim;
                else
                    setCenterAndUnitsPerPixel(bep,bepLimits.Center,bepLimits.UnitsPerPixel);
                end
            end

            if nargin>1&&isOpening
                return;
            end


            addComponent(this,bep);


            if~useAppContainer(this)
                bep.Figure.Visible=true;
                drawnow
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setClientLocation(getName(bep),this.ToolGroup.Name,...
                    md.getClientLocation(md.getClient(getName(this.EgoCentricView),this.ToolGroup.Name)));
            end
        end

        function sp=getSensorPropertiesComponent(this,isOpening)
            sp=this.SensorProperties;
            if~isempty(sp)||isempty(this.SensorSpecifications)
                return;
            end
            sp=driving.internal.scenarioApp.SensorProperties(this);
            this.SensorProperties=sp;

            if nargin>1&&isOpening
                return;
            end
            addComponent(this,sp);

            this.PropertyListener.Source={this.ActorProperties,this.RoadProperties...
                ,getBarrierPropertiesComponent(this),sp};

            if~useAppContainer(this)
                sp.Figure.Visible=true;
                drawnow
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setClientLocation(getName(sp),this.ToolGroup.Name,...
                    md.getClientLocation(md.getClient(getName(this.ActorProperties),this.ToolGroup.Name)));
            end
        end

        function bp=getBarrierPropertiesComponent(this,isOpening)
            bp=this.BarrierProperties;
            if~isempty(bp)||isempty(this.BarrierSpecifications)
                return;
            end
            bp=driving.internal.scenarioApp.BarrierProperties(this);
            this.BarrierProperties=bp;

            if nargin>1&&isOpening
                return;
            end
            addComponent(this,bp);

            this.PropertyListener.Source={this.ActorProperties,this.RoadProperties...
                ,bp,getSensorPropertiesComponent(this)};

            if~useAppContainer(this)
                bp.Figure.Visible=true;
                drawnow
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setClientLocation(getName(bp),this.ToolGroup.Name,...
                    md.getClientLocation(md.getClient(getName(this.ActorProperties),this.ToolGroup.Name)));
            end
        end

        function onGamingEngineWindowClosed(this,~,~)
            this.ScenarioView.removeMessage('GamingEngineIncompatibility');
        end

        function openSplitOpening(this)
            simulator=this.Simulator;
            if isRunning(simulator)
                this.RestartPlayer=true;
                pause(simulator);
            else
                this.RestartPlayer=false;
            end
        end

        function openSplitOpened(this)
            if this.RestartPlayer
                run(this.Simulator);
            end
        end

        function roadCreationStarting(this,msgText,period)
            if nargin<3
                if useAppContainer(this)
                    period=3;
                else
                    period=1.5;
                end
            end
            if nargin<2
                msgText=getString(message('driving:scenarioApp:CreateLargeRoadWarning'));
            end
            t=timer('StartDelay',period,...
                'Tag','RoadCreationStarting',...
                'UserData',msgText,...
                'TimerFcn',@this.largeRoadNetworkTimerCallback);
            start(t);
            this.RoadCreationTimer=t;
            this.RoadCreationInProgress=true;
        end
        function openDRIVEFileWarning(this,msgText,period)
            if nargin<3
                if useAppContainer(this)
                    period=3;
                else
                    period=1.5;
                end
            end
            if nargin<2
                msgText=getString(message('driving:scenarioApp:CreateLargeRoadWarning'));
            end
            t=timer('StartDelay',period,...
                'Tag','RoadCreationStarting',...
                'UserData',msgText,...
                'TimerFcn',@this.openDRIVEWarningTimerCallback);
            start(t);
            this.RoadCreationTimer=t;
            this.RoadCreationInProgress=true;
        end

        function roadCreationFinished(this,force)
            matlabshared.application.deleteTimer(this.RoadCreationTimer);
            this.RoadCreationInProgress=false;
            if this.ShouldClearLargeRoadWarning||nargin>1&&force
                this.ShouldClearLargeRoadWarning=false;
                this.ScenarioView.removeMessage('LargeRoadNetworkWarning');
            end
        end
        function exportOpenScenarioFileWarning(this,warning)
            if nargin<3
                if useAppContainer(this)
                    period=3;
                else
                    period=1.5;
                end
            end
            if nargin<2
                warning='';
            end
            t=timer('StartDelay',period,...
                'Tag','OpenScenarioExport',...
                'UserData',warning,...
                'TimerFcn',@this.exportOpenScenarioWarningTimerCallback);
            start(t);
        end
        function exportOpenScenarioWarningTimerCallback(this,t,~)
            message=t.UserData;
            matlabshared.application.deleteTimer(t);
            this.ScenarioView.warningMessage(message,'OpenScenarioExport','FontSize',10);
        end

        function largeRoadNetworkTimerCallback(this,t,~)
            message=t.UserData;
            matlabshared.application.deleteTimer(t);
            this.ScenarioView.warningMessage(message,'LargeRoadNetworkWarning','FontSize',10);
            drawnow
            t=timer('StartDelay',1.0,...
                'Tag','RoadCreationTeardown',...
                'TimerFcn',@this.dismissLargeRoadWarningCallback);
            start(t);
        end
        function openDRIVEWarningTimerCallback(this,t,~)
            message=t.UserData;
            matlabshared.application.deleteTimer(t);
            moreInfo=message;
            message='The following changes will be made before import:';
            this.ScenarioView.warningMessage(message,'OpenDRIVEWarning','FontSize',10,'MoreInfoText',moreInfo);
        end

        function dismissLargeRoadWarningCallback(this,t,~)
            matlabshared.application.deleteTimer(t);
            if this.RoadCreationInProgress
                this.ShouldClearLargeRoadWarning=true;
            else
                this.ScenarioView.removeMessage('LargeRoadNetworkWarning');
            end
        end

        function[cut,copy,paste,delete]=createCutCopyPasteDeleteMenus(this,h,canvas)
            if nargin<3
                canvas=this;
            end
            [cut,copy,paste]=createCutCopyPasteMenus(this,h);
            delete=uimenu(h,...
                'Tag','DeleteItem',...
                'Label',getString(message('Spcuilib:application:Delete')),...
                'Callback',@canvas.deleteCallback);
        end

        function b=isCutEnabled(this)
            if isCopyEnabled(this)
                mode=this.MostRecentCanvas;
                if strcmp(mode,'scenario')
                    b=strcmp(this.ScenarioView.InteractionMode,'none');
                else
                    b=strcmp(this.SensorCanvas.InteractionMode,'none');
                end
            else
                b=false;
            end
        end

        function b=isCopyEnabled(this)
            b=false;
            if isStopped(this.Simulator)
                mode=this.MostRecentCanvas;
                if strcmp(mode,'scenario')
                    b=~isempty(this.ScenarioView.CurrentSpecification);
                elseif strcmp(mode,'sensors')
                    b=~isempty(getCurrentSensor(this));
                end
            end
        end

        function b=isPasteEnabled(this)
            b=isStopped(this.Simulator)&&isPasteEnabled@matlabshared.application.ToolGroupCutCopyPaste(this);
            if b
                mode=this.MostRecentCanvas;
                if strcmp(mode,'scenario')
                    b=strcmp(this.ScenarioView.InteractionMode,'none');
                else
                    b=strcmp(this.SensorCanvas.InteractionMode,'none');
                end
            end
        end

        function files=getRecentFiles(this)
            files=getRecentFiles@matlabshared.application.ToolGroupFileSystem(this);
        end

        function fileName=getRecentFileNameFromText(~,text)

            [~,fileName]=strtok(text,')');
            fileName(1:2)=[];
        end

        function[icon,label]=getInfoForRecentFile(this,fileName,type)
            import matlab.ui.internal.toolstrip.*;
            iconPath=this.getPathToIcons;
            switch type
                case 'default'
                    [icon,label]=getInfoForRecentFile(this,fileName,getDefaultOpenTag(this));
                    return;
                case 'classes'
                    icon=Icon(fullfile(iconPath,'Actor24.png'));
                    label=getString(message('driving:scenarioApp:RecentFileClasses'));
                case{'session','PrebuiltScenario'}
                    icon=Icon(fullfile(iconPath,'Session24.png'));
                    label=getString(message('driving:scenarioApp:RecentFileSession'));
                case 'sensors'
                    icon=Icon(fullfile(iconPath,'Sensors24.png'));
                    label=getString(message('driving:scenarioApp:RecentFileSensors'));
                case 'scenario'
                    icon=Icon(fullfile(iconPath,'Scenario24.png'));
                    label=getString(message('driving:scenarioApp:RecentFileScenario'));
                case 'OpenDRIVEReader'
                    icon=Icon(fullfile(iconPath,'Scenario24.png'));
                    label=getString(message('driving:scenarioApp:RecentFileOpenDRIVE'));
            end
            label=sprintf('(%s) %s',label,fileName);
        end

        function helpCallback(~,~,~)
            helpview(fullfile(docroot,'driving','ref','drivingscenariodesigner-app.html'));
        end

        function updateBirdsEyePlot(this)
            bep=this.BirdsEyePlot;
            if~isempty(bep)
                if getCurrentSample(this.Simulator)==1

                    calculateSensorData(bep);
                end
                update(bep);
            end
        end

        function openSimulationSettings(this)
            ss=this.SimulationSettings;
            if isempty(ss)
                ss=driving.internal.scenarioApp.SimulationSettingsDialog(this);
                addComponent(this,ss,false);
                this.SimulationSettings=ss;
            else
                refresh(ss);
            end
            open(ss);
        end

        function varargout=editClassSpecifications(this)
            cse=this.ClassEditor;
            if isempty(cse)
                cse=driving.internal.scenarioApp.ClassEditor(this);
                addComponent(this,cse,false);
                this.ClassEditor=cse;
            end
            cse.NewMode=false;
            refresh(cse);
            update(cse);
            open(cse);
            if nargout>0
                varargout={cse};
            end
        end

        function varargout=newClassSpecification(this)
            cse=this.ClassEditor;
            if isempty(cse)
                cse=driving.internal.scenarioApp.ClassEditor(this);
                addComponent(this,cse,false);
                this.ClassEditor=cse;
            end
            cse.NewMode=true;
            refresh(cse);
            addNew(cse);
            update(cse);
            updateLayout(cse);
            open(cse);
            if nargout
                classSpecs=this.ClassSpecifications;
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

        function updateClassSpecifications(this,classInfo)
            setDirty(this);
            updateClassSpecifications@driving.internal.scenarioApp.ScenarioBuilder(this,classInfo);
            updateActorsGallery(this.Toolstrip);



            update(this.ActorProperties);
        end

        function success=saveFile(this,varargin)
            success=saveFile@matlabshared.application.ToolGroupFileSystem(this,varargin{:});
            if success
                saveFile@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
                removeDirty(this);



                if nargin<3
                    tag='session';
                else
                    tag=varargin{2};
                end
                clearCompiledScenarioData(this,tag);
            end
        end

        function success=openFile(this,varargin)
            sim=this.Simulator;
            if~isempty(sim)&&isRunning(sim)
                pause(sim);
            end
            success=openFile@matlabshared.application.ToolGroupFileSystem(this,varargin{:});
            if success
                openFile@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
            end
        end

        function success=importItem(this,tag)
            success=false;

            if isRunning(this.Simulator)
                pause(this.Simulator);
            end

            if useAppContainer(this)
                parentPos=this.Window.AppContainer.WindowBounds;
            else
                parentPos=getToolGroupName(this);
            end
            switch tag
                case 'OpenDRIVEReader'

                    pos=matlabshared.application.getCenterPosition([650,250],parentPos);
                    dialog=driving.internal.openDRIVEImport.openDRIVE.DialogController(pos,this.ShowImportErrors);
                case 'HEREHDLiveMap'

                    pos=matlabshared.application.getCenterPosition([460,600],parentPos);
                    importer=driving.internal.heremaps.import.RoadNetworkImporter(...
                        this.HEREHDLiveMapImportArgs{:});
                    dialog=driving.internal.heremaps.import.DialogController(...
                        importer,pos);
                case 'OpenStreetMap'

                    pos=matlabshared.application.getCenterPosition([460,600],parentPos);
                    importer=driving.internal.scenarioImport.osm.RoadNetworkImporter(...
                        this.OpenStreetMapImportArgs{:});
                    dialog=driving.internal.scenarioImport.osm.DialogController(...
                        importer,pos);
                case 'ZenrinJapanMap'

                    if driving.internal.scenarioImport.isZenrinJapanMapInstalled()

                        pos=matlabshared.application.getCenterPosition([460,600],parentPos);
                        importer=driving.internal.zenrinjapanmap.import.RoadNetworkImporter(...
                            this.ZenrinJapanMapImportArgs{:});
                        dialog=driving.internal.zenrinjapanmap.import.DialogController(...
                            importer,pos);
                    else

                        install=getString(message('driving:scenarioImport:ZenrinJapanMapAppInstallText'));
                        cancel=getString(message('driving:scenarioImport:ZenrinJapanMapAppCancelText'));
                        selected=uiconfirm(this,...
                            getString(message('driving:scenarioImport:ZenrinJapanMapNotInstalled')),...
                            getString(message('Spcuilib:application:ImportErrorTitle')),...
                            {install,cancel},install);
                        if strcmp(selected,install)
                            supportPackageInstaller
                        end
                        return
                    end
                otherwise
                    success=importItem@matlabshared.application.ToolGroupFileSystem(this,tag);
                    return
            end

            if~allowImport(this)
                return
            end

            dialog.attach(this);
            dialog.open();

            success=true;
        end

        function spec=getSaveFileSpecification(~,tag)
            switch tag
                case 'OpenDRIVEReader'
                    spec={'*.xodr;*.xml',getString(message('driving:scenarioApp:OpenDRIVEFileTypeDescription'))};
                otherwise
                    spec={'*.mat',getString(message('driving:scenarioApp:FileTypeDescription'))};
            end
        end

        function title=getSaveDialogTitle(~,tag)
            switch tag
                case 'session'
                    title=getString(message('driving:scenarioApp:SaveDialogTitleSession'));
                case 'scenario'
                    title=getString(message('driving:scenarioApp:SaveDialogTitleScenario'));
                case 'sensors'
                    title=getString(message('driving:scenarioApp:SaveDialogTitleSensors'));
                case 'classes'
                    title=getString(message('driving:scenarioApp:SaveDialogTitleClasses'));
            end
        end

        function title=getOpenDialogTitle(~,tag)
            switch tag
                case{'session','PrebuiltScenario'}
                    title=getString(message('driving:scenarioApp:OpenDialogTitleSession'));
                case 'scenario'
                    title=getString(message('driving:scenarioApp:OpenDialogTitleScenario'));
                case 'sensors'
                    title=getString(message('driving:scenarioApp:OpenDialogTitleSensors'));
                case 'classes'
                    title=getString(message('driving:scenarioApp:OpenDialogTitleClasses'));
                case 'OpenDRIVEReader'
                    title=getString(message('driving:scenarioApp:OpenDialogTitleOpenDRIVE'));
            end
        end

        function b=showRecentFiles(~)
            b=true;
        end

        function info=getNewSpecification(this)
            iconPath=this.getPathToIcons;

            info(1).text=getString(message('driving:scenarioApp:NewSessionText'));
            info(1).tag='session';
            info(1).description=getString(message('driving:scenarioApp:NewSessionDescription'));

            if this.IsADTInstalled
                components(1).text=getString(message('driving:scenarioApp:NewScenarioText'));
                components(1).tag='scenario';
                components(1).icon=fullfile(iconPath,'Scenario24.png');
                components(1).description=getString(message('driving:scenarioApp:NewScenarioDescription'));

                components(2).text=getString(message('driving:scenarioApp:NewSensorsText'));
                components(2).tag='sensors';
                components(2).icon=fullfile(iconPath,'Sensors24.png');
                components(2).description=getString(message('driving:scenarioApp:NewSensorsDescription'));
                info={
                    {getString(message('driving:scenarioApp:NewSessionText')),info},...
                    {getString(message('driving:scenarioApp:ComponentsHeader')),components}};
            else
            end

        end

        function info=getOpenSpecification(this)
            iconPath=this.getPathToIcons;

            session(1).text=getString(message('driving:scenarioApp:OpenSessionText'));
            session(1).tag='session';
            session(1).icon=[];
            session(1).description=getString(message('driving:scenarioApp:OpenSessionDescription'));

            session(2).text=getString(message('driving:scenarioApp:OpenPrebuiltScenarioText'));
            session(2).tag='PrebuiltScenario';
            session(2).icon=[];
            session(2).description=getString(message('driving:scenarioApp:OpenPrebuiltScenarioDescription'));

            components=struct.empty;
            if this.IsADTInstalled
                components(1).text=getString(message('driving:scenarioApp:OpenScenarioText'));
                components(1).tag='scenario';
                components(1).icon=fullfile(iconPath,'Scenario24.png');
                components(1).description=getString(message('driving:scenarioApp:OpenScenarioDescription'));

                components(2).text=getString(message('driving:scenarioApp:OpenSensorsText'));
                components(2).tag='sensors';
                components(2).icon=fullfile(iconPath,'Sensors24.png');
                components(2).description=getString(message('driving:scenarioApp:OpenSensorsDescription'));
            end

            class.text=getString(message('driving:scenarioApp:OpenClassDefinitionsText'));
            class.tag='classes';
            class.icon=fullfile(iconPath,'Actor24.png');

            info{1}={getString(message('driving:scenarioApp:SessionHeader')),session};
            infoI=2;
            if~isempty(components)
                info{infoI}={getString(message('driving:scenarioApp:ComponentsHeader')),components};
                infoI=infoI+1;
            end
            info{infoI}={getString(message('driving:scenarioApp:ClassDefinitionsHeader')),class};
        end

        function info=getImportDescription(this)
            info=getImportDescription@matlabshared.application.ToolGroupFileSystem(this);
            info.description=getString(message('driving:scenarioApp:ImportDescription'));
        end

        function info=getImportSpecification(this)
            iconPath=this.getPathToIcons;

            roadfile(1).text=getString(message('driving:scenarioApp:OpenDriveTitle'));
            roadfile(1).tag='OpenDRIVEReader';
            roadfile(1).icon=fullfile(iconPath,'OpenDrive_Import_24.png');
            roadfile(1).description=getString(message('driving:scenarioApp:OpenDRIVEDescription'));

            idx=1;
            mapdata=struct.empty;
            if this.ShowOpenStreetMapImport
                mapdata(idx).text=getString(message('driving:scenarioApp:OpenStreetMapText'));
                mapdata(idx).tag='OpenStreetMap';
                mapdata(idx).icon=fullfile(iconPath,'ImportMapFile24.png');
                mapdata(idx).description=getString(message('driving:scenarioApp:OpenStreetMapDescription'));
                idx=2;
            end

            if this.IsADTInstalled
                mapdata(idx).text=getString(message('driving:scenarioApp:HEREHDLMText'));
                mapdata(idx).tag='HEREHDLiveMap';
                mapdata(idx).icon=fullfile(iconPath,'ImportMapWeb24.png');
                mapdata(idx).description=getString(message('driving:scenarioApp:HEREHDLMDescription'));
                idx=idx+1;

                if this.ShowZenrinJapanMapImport
                    mapdata(idx).text=getString(message('driving:scenarioApp:ZenrinJapanMapText'));
                    mapdata(idx).tag='ZenrinJapanMap';
                    mapdata(idx).icon=fullfile(iconPath,'ImportMapWeb24.png');
                    mapdata(idx).description=getString(message('driving:scenarioApp:ZenrinJapanMapDescription'));
                end
            end

            info{1}={getString(message('driving:scenarioApp:ExternalStandardPopupHeader')),roadfile};
            if~isempty(mapdata)
                info{2}={getString(message('driving:scenarioApp:ImportMapDataCategoryTitle')),mapdata};
            end
        end

        function tag=getDefaultSaveTag(~)
            tag='session';
        end

        function tag=getDefaultOpenTag(~)
            tag='session';
        end

        function tag=getDefaultNewTag(~)
            tag='session';
        end

        function info=getSaveSpecification(this)

            iconPath=this.getPathToIcons;

            info.text={getString(message('driving:scenarioApp:SaveSessionText')),...
                getString(message('driving:scenarioApp:SaveSessionAsText'))};
            info.tag='session';
            info.description=getString(message('driving:scenarioApp:SaveSessionDescription'));

            if this.IsADTInstalled
                components.text=getString(message('driving:scenarioApp:SaveScenarioText'));
                components.tag='scenario';
                components.icon=fullfile(iconPath,'Scenario24.png');
                components.description=getString(message('driving:scenarioApp:SaveScenarioDescription'));

                components(2).text=getString(message('driving:scenarioApp:SaveSensorsText'));
                components(2).tag='sensors';
                components(2).icon=fullfile(iconPath,'Sensors24.png');
                components(2).description=getString(message('driving:scenarioApp:SaveSensorsDescription'));
            end

            class.text=getString(message('driving:scenarioApp:SaveClassDefinitionsText'));
            class.tag='classes';
            class.icon=fullfile(iconPath,'Actor24.png');

            if this.IsADTInstalled

                info={
                    {getString(message('driving:scenarioApp:SessionHeader')),info},...
                    {getString(message('driving:scenarioApp:ComponentsHeader')),components},...
                    {getString(message('driving:scenarioApp:ClassDefinitionsHeader')),class}};
            else
                info={
                    {getString(message('driving:scenarioApp:SessionHeader')),info},...
                    {getString(message('driving:scenarioApp:ClassDefinitionsHeader')),class}};
            end
        end

        function updateActorInScenario(this,index)
            updateActorInScenario@driving.internal.scenarioApp.ScenarioBuilder(this,index);
            if isempty(this.ScenarioView)
                return;
            end
            updateActor(this.ScenarioView,index,true);
            updateActor(this.EgoCentricView,index);
            sensorCanvas=this.SensorCanvas;
            if~isempty(sensorCanvas)
                update(sensorCanvas);
            end
            updateBirdsEyePlot(this);
            clearCaches(this.Simulator);
        end

        function name=getClassNameFromID(this,id)


            name=getProperty(this.ClassSpecifications,id,'name');
        end

        function updateView(this,notFirstCall)

            scenario=this.ScenarioView;
            egoCentric=this.EgoCentricView;
            roads=this.RoadProperties;
            barriers=this.BarrierProperties;
            actors=this.ActorProperties;
            toolGroup=getApplicationName(this);
            sensors=this.SensorProperties;
            bep=this.BirdsEyePlot;
            sensorCanvas=this.SensorCanvas;

            if nargin<2
                notFirstCall=false;
            end

            allComps=[barriers,actors,roads,scenario,egoCentric,sensors,sensorCanvas,bep];


            set([allComps.Figure],'Visible','on');

            allHorizontalGutterWidth=32;
            allVerticalGutterHeight=204;
            [~,~,w,ht]=getPosition(this);
            totalWidth=w-allHorizontalGutterWidth;
            availableHeight=ht-allVerticalGutterHeight;

            canvasWidth=availableHeight/totalWidth;

            propertyWidth=299;
            viewWidth=385;

            availableWidth=totalWidth*(1-canvasWidth)-propertyWidth-viewWidth;

            if availableWidth>0
                propertyWidth=propertyWidth+availableWidth*0.2;
            end
            propertyWidth=propertyWidth/totalWidth;
            viewWidth=1-canvasWidth-propertyWidth;

            columnWeights=[propertyWidth,canvasWidth,viewWidth];

            if useAppContainer(this)
                appContainer=this.Window.AppContainer;
                leftComps=[roads,barriers,actors,sensors];
                centerComps=[scenario,sensorCanvas];
                rightComps=[egoCentric,bep];

                appContainer.DocumentLayout=struct(...
                    'gridDimensions',struct('w',3,'h',1),...
                    'columnWeights',columnWeights,...
                    'rowWeights',1,...
                    'tileCount',3,...
                    'tileCoverage',[1,2,3],...
                    'tileOccupancy',{getTileOccupancy(this.Window,leftComps,centerComps,rightComps)});
                return;
            else
                drawnow

                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                md.setDocumentArrangement(toolGroup,md.TILED,java.awt.Dimension(3,1))





                if notFirstCall
                    drawnow
                end

                md.setDocumentColumnWidths(toolGroup,columnWeights);


                column=com.mathworks.widgets.desk.DTLocation.create(0);
                setLocation(roads,md,toolGroup,column,notFirstCall);
                setLocation(actors,md,toolGroup,column,notFirstCall);

                if~isempty(barriers)
                    setLocation(barriers,md,toolGroup,column,notFirstCall);
                end

                sensors=this.SensorProperties;
                if~isempty(sensors)
                    setLocation(sensors,md,toolGroup,column,notFirstCall);
                end

                column=com.mathworks.widgets.desk.DTLocation.create(1);
                setLocation(scenario,md,toolGroup,column,notFirstCall)
                sensorCanvas=this.SensorCanvas;
                if~isempty(sensorCanvas)
                    setLocation(sensorCanvas,md,toolGroup,column,notFirstCall);
                end

                column=com.mathworks.widgets.desk.DTLocation.create(2);
                setLocation(egoCentric,md,toolGroup,column,notFirstCall);

                bep=this.BirdsEyePlot;
                if~isempty(bep)
                    setLocation(bep,md,toolGroup,column,notFirstCall);
                end
                if~notFirstCall
                    drawnow
                    focusOnComponent(roads);
                end
            end
            updateTableColumnWidths(actors);
            if~isempty(barriers)
                updateTableColumnWidths(barriers);
            end
        end

        function updateForNewRoad(this,newRoadSpec)


            this.EgoCentricView.update();
            roadProps=this.RoadProperties;
            allSpecs=this.RoadSpecifications;
            roadProps.SpecificationIndex=find(allSpecs==newRoadSpec);
            if numel(allSpecs)==1


                notify(this,'CurrentRoadChanged')
            end
            update(roadProps);
            canvas=this.ScenarioView;
            focusOnComponent(roadProps);
            if this.ShowSimulators
                updateToolstrip(this.Simulator);
            else
                update(this.Toolstrip.SimulateSection);
            end
            updateBirdsEyePlot(this);
            setDirty(this);

            canvas.CurrentSpecification=newRoadSpec;
            update(canvas);
            updateExport(this.Toolstrip);
        end

        function updateForSensors(this,newSensor)
            if~this.IsADTInstalled
                return
            end
            sensorProps=getSensorPropertiesComponent(this);
            if isempty(sensorProps)
                return;
            end
            update(getSensorCanvasComponent(this));
            if nargin>1
                sensorProps.SpecificationIndex=find(this.SensorSpecifications==newSensor);
            elseif sensorProps.SpecificationIndex>numel(this.SensorSpecifications)
                sensorProps.SpecificationIndex=1;
            end
            update(sensorProps);

            bep=getBirdsEyePlotComponent(this);

            bep.IsCoverageStale=true;
            clearData(bep);
            calculateSensorData(bep);
            update(bep);
            updateExport(this.Toolstrip);
            updateCutCopyPasteQab(this);
        end

        function updateForNewActor(this,newActorSpec)
            actorProps=this.ActorProperties;
            canvas=this.ScenarioView;
            focusOnComponent(actorProps);
            actorProps.SpecificationIndex=[newActorSpec.ActorID];

            if(isempty(this.EgoCarId)||this.EgoCarId>numel(this.ActorSpecifications))&&...
                    getProperty(this.ClassSpecifications,newActorSpec(1).ClassID,'isVehicle')
                this.EgoCarId=newActorSpec(1).ActorID;
            end

            update(actorProps);
            updateToolstrip(this.Simulator);
            updateBirdsEyePlot(this);

            setDirty(this);

            updateActor(canvas,[],true);
            updateActor(this.EgoCentricView,[],true);
            updateExport(this.Toolstrip);
            canvas.CurrentSpecification=newActorSpec;
        end

        function updateForNewBarrier(this,newBarrierSpec)
            barrierProps=this.getBarrierPropertiesComponent();
            canvas=this.ScenarioView;
            focusOnComponent(barrierProps);
            barrierProps.SpecificationIndex=find(this.BarrierSpecifications==newBarrierSpec(1));

            barrierProps.SpecificationIndex=numel(this.BarrierSpecifications);
            update(barrierProps);
            updateToolstrip(this.Simulator);
            updateBirdsEyePlot(this);

            setDirty(this);

            canvas.CurrentSpecification=newBarrierSpec(1);
            update(canvas);
            update(this.EgoCentricView);
            updateExport(this.Toolstrip);
        end

        function focusOnComponent(this,comp)

            canvas=this.ScenarioView;
            if isequal(comp,canvas)||isequal(comp,this.SensorCanvas)||~this.isComponentInSameLocation(comp,canvas)
                focusOnComponent@matlabshared.application.Application(this,comp);
            end
        end

        function updateClassEditor(this)
            classEditor=this.ClassEditor;
            if~isempty(classEditor)
                update(classEditor);
            end
        end

        function clearCompiledScenarioData(this,tag)



            if any(strcmp(tag,{'session','scenario'}))

                driving.scenario.internal.setGetCompiledScenarioData(getCurrentFileName(this),[]);
            end
        end

        function h=createCommandLineInterface(this)
            h=driving.scenario.Designer(this);
        end

        function errorAndWarningMessage=processOpenDRIVERoadNetwork(this,fileName,workflow)
            try

                if strcmp(workflow,'fileImport')
                    roadCreationStarting(this,getString(message('driving:scenarioApp:LoadOpenDRIVEWarning')),0.3);
                end


                if~isempty(this.ScenarioView)
                    new(this,'scenario',true);
                end
                errorAndWarningMessage='';
                if this.UseIRAdapters&&~this.ShowAsymmetricRoads

                    adapterobj=matlabshared.drivingutils.OpenDriveAdapter(fileName);
                    rn=adapterobj.getRoadNetworkData('UseHeading',true);
                    errorAndWarningMessage=driving.scenario.internal.getOpenDRIVEImportMessages(adapterobj.ExceptionsLog,adapterobj.WarningsLog);

                    scenario=driving.internal.scenarioAdapter.getDrivingScenario...
                        (rn,'UseRoadGroups',true,'UseCompositeLaneSpec',true,'AllowSharpCurvature',true);

                    this.RoadSpecifications=[driving.internal.scenarioApp.road.Arbitrary.fromScenario(scenario),...
                        driving.internal.scenarioApp.road.RoadGroupArbitrary.fromScenario(scenario)];
                    if isempty(this.RoadSpecifications)
                        error(message('driving:scenario:InvalidRoadEntities'));
                    end
                    this.Scenario=generateNewScenarioFromSpecifications(this);

                    roadCreationFinished(this);
                    setDirty(this);

                    canvas=this.ScenarioView;
                    if~isempty(this.ScenarioView)
                        canvas.EnableRoadInteractivity=false;
                        fitToView(canvas);
                    end
                else

                    readerObj=matlabshared.drivingutils.OpenDriveReader(fileName);
                    roadList=readerObj.getStructure();

                    [roads,warnings]=driving.scenario.internal.openDRIVEReader(roadList,'ShowAsymmetricRoads',this.ShowAsymmetricRoads);

                    this.Scenario.ShowRoadBorders=false;
                    roadSpecArray=driving.internal.scenarioApp.road.Specification.empty(8,0);
                    for roadInd=1:numel(roads)
                        r=roads(roadInd);
                        openDrivePvPairs={'LeftRoadWidth',r.leftRoadWidth,...
                            'RightRoadWidth',r.rightRoadWidth,...
                            'Junction',r.junction,...
                            'LaneOffset',r.laneOffset};
                        if this.ShowAsymmetricRoads
                            roadSpec=driving.internal.scenarioApp.road.OpenDRIVEArbitrary(r.centers,'BankAngle',r.bankAngles,'Lanes',r.laneSpecification,openDrivePvPairs{:});
                        else
                            roadSpec=driving.internal.scenarioApp.road.Arbitrary(r.centers,'BankAngle',r.bankAngles,'Lanes',...
                                r.laneSpecification,'Name',r.name,openDrivePvPairs{:},'IsOpenDRIVE',true);
                        end
                        roadSpecArray(roadInd)=roadSpec;
                    end
                    s.RoadSpecifications=roadSpecArray;
                    processOpenDRIVEData(this,s);
                    if strcmp(workflow,'fileImport')
                        roadCreationFinished(this);
                    end


                    this.Scenario.IsOpenDRIVERoad=true;
                    if strcmp(workflow,'fileImport')

                        warningMessage=getOpenDRIVEWarningMessage(this,warnings,workflow);
                        if~isempty(warningMessage)
                            openDRIVEFileWarning(this,warningMessage+"",0.3);
                        end
                    else

                        warningMessage=getOpenDRIVEWarningMessage(this,warnings,workflow);
                        if~isempty(warningMessage)
                            existState=warning('backtrace');
                            warning('off','backtrace');
                            warning('driving:scenarioApp:OpenDRIVEWarnings',warningMessage);
                            warning('on','backtrace');
                            warning(existState);
                        end
                    end


                    this.Toolstrip.hAddRoad.Enabled=false;
                    this.Toolstrip.hExportMatlabCode.Enabled=false;
                end
            catch ME
                roadCreationFinished(this);
                throw(ME);
            end

            if~isempty(errorAndWarningMessage)&&strcmp(workflow,'commandLine')
                errTitle=getString(message('driving:scenarioImport:ODErrorTitleText'));
                errorAndWarningMessage=[errTitle,newline,newline,errorAndWarningMessage];
                existState=warning('backtrace');
                warning('off','backtrace');
                warning('driving:scenarioApp:OpenDRIVEWarnings',errorAndWarningMessage);
                warning('on','backtrace');
                warning(existState);
            end
        end
    end

    methods(Hidden,Static)
        function pathToIcon=getPathToIcons

            pathToIcon=fullfile(matlabroot,'toolbox','shared','drivingscenario','+driving','+internal','+scenarioApp');
        end

        function varargout=forceAppContainer(varargin)
            persistent forceFlag;
            if nargin
                forceFlag=varargin{1};
            end
            if nargout
                if isempty(forceFlag)
                    forceFlag=false;
                end
                varargout{1}=forceFlag;
            end
        end
    end

    methods(Access=protected)

        function b=onCloseRequest(this,varargin)
            if useAppContainer(this)
                b=onCloseRequest@matlabshared.application.ToolGroupFileSystem(this);
            else
                b=false;
                if this.IsLaunching
                    return;
                end
                b=allowClose(this,true);

                if b
                    this.ToolGroupBeingDestroyedListener=[];
                    this.ApplicationBeingDestroyedListener=[];
                end
            end
        end

        function id=getWarningIdsToIgnore(~)
            id={'MATLAB:system:nonRelevantProperty','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'};
        end

        function onSimulatorChanged(this)
            actorProps=this.ActorProperties;
            if~isempty(actorProps)
                updateLayout(actorProps)
                update(actorProps);
            end
        end

        function convertAxesOrientation(this,oldOrientation,newOrientation)

            convertAxesOrientation@driving.internal.scenarioApp.ScenarioBuilder(this,oldOrientation,newOrientation);

            if~strcmpi(newOrientation,oldOrientation)

                scenarioCanvas=this.ScenarioView;
                if~isempty(scenarioCanvas)
                    scenarioCanvas.Center(2)=-scenarioCanvas.Center(2);
                    scenarioCanvas.updateLimits();
                end
                sensorCanvas=this.SensorCanvas;
                if~isempty(sensorCanvas)
                    sensorCanvas.Center(2)=-sensorCanvas.Center(2);
                    sensorCanvas.updateLimits();
                end
                birdsEyePlot=this.BirdsEyePlot;
                if~isempty(birdsEyePlot)
                    birdsEyePlot.Center(2)=-birdsEyePlot.Center(2);
                    birdsEyePlot.updateLimits();
                    birdsEyePlot.IsCoverageStale=true;
                end
            end
        end

        function data=loadDataFile(this,fileName,~)
            this.LoadWarning={};
            [oldWarnStr,oldWarnId]=lastwarn;
            lastwarn('','')
            w=warning;
            c=onCleanup(@()cleanUpWarning(w,oldWarnStr,oldWarnId));
            warning('off','MATLAB:load:classNotFound');

            data=load(fileName,'-mat');

            [~,id]=lastwarn;

            if strcmp(id,'MATLAB:load:classNotFound')&&...
                    isfield(data.data,'SensorSpecifications')&&...
                    ~isempty(data.data.SensorSpecifications)&&...
                    isempty(data.data.SensorSpecifications(1).Sensor)




                data.data=rmfield(data.data,'SensorSpecifications');
                id='driving:scenarioApp:OpenWarningMissingADT';
                [~,name,ext]=fileparts(fileName);
                this.LoadWarning={getString(message(id,[name,ext])),id};
            end
        end

        function p=getIconMatFiles(~)

            p={fullfile(matlabroot,'toolbox','shared','drivingscenario',...
                '+driving','+internal','+scenarioApp','icons.mat')};
        end

        function id=getInvalidFileFormatId(~)
            id='driving:scenarioApp:InvalidFileFormat';
        end

        function tag=openFileImpl(this,fileName,tag,inputArgs)
            [~,~,ext]=fileparts(fileName);
            if strcmp(tag,"")&&strcmp(ext,'.xodr')||strcmp(ext,'.xml')
                tag='OpenDRIVEReader';
                processOpenDRIVERoadNetwork(this,fileName,'commandLine');
            else
                tag=openFileImpl@matlabshared.application.ToolGroupFileSystem(this,fileName,tag,inputArgs);
            end
        end

        function processOpenDRIVEData(this,data)
            if~isfield(data,'RoadSpecifications')
                error(message('driving:scenarioApp:InvalidScenarioFile'));
            end
            this.RoadSpecifications=data.RoadSpecifications;

            roadProps=this.RoadProperties;
            if~isempty(roadProps)
                roadProps.SpecificationIndex=1;
            end

            if isfield(data,'ClassSpecifications')
                processOpenData(this.ClassSpecifications,data.ClassSpecifications);
                toolstrip=this.Toolstrip;
                if~isempty(toolstrip)
                    updateActorsGallery(toolstrip);
                end
            end
            this.Scenario.IsOpenDRIVERoad=true;


            generateNewScenarioFromSpecifications(this);


            if isempty(this.ScenarioView)
                this.NeedsAutoScale=true;
            else
                this.ScenarioView.EnableRoadInteractivity=false;
                autoScaleCanvas(this);
            end
        end


        function warningMessage=getOpenDRIVEWarningMessage(this,warnings,~)
            warningMessage=[];
            bulletStr='';
            if this.ShowAsymmetricRoads
                if numel(warnings.invalidLaneMarkerTypes)~=0
                    warningMessage=[getString(message('driving:scenario:OpenDRIVEWarningHeader')),newline];
                    if(numel(warnings.invalidLaneMarkerTypes)~=0)
                        wInvalidLaneMarkerTypes=getString(message('driving:scenario:InvalidLaneMarkerTypes',...
                            strjoin(unique(warnings.invalidLaneMarkerTypes),', ')));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidLaneMarkerTypes];
                    end
                    footerMessage=getString(message('driving:scenario:OpenDRIVEWarningFooter'));
                    warningMessage=[warningMessage,newline,newline,footerMessage,newline];
                end
            else
                if warnings.isElevationInvalid||warnings.isSuperElevationInvalid||warnings.isRoadMarkColorinvalid||warnings.isJunctionInvalid||warnings.isLaneOffsetInvalid||warnings.isLaneMarkWidthInvalid||warnings.isLaneWidthInvalid||numel(warnings.variableLaneWidths)~=0||numel(warnings.variableLaneMarkerStyles)~=0 ...
                        ||numel(warnings.invalidLaneMarkerTypes)~=0
                    warningMessage=[getString(message('driving:scenario:OpenDRIVEWarningHeader')),newline];
                    if(numel(warnings.variableLaneWidths)~=0)
                        wVarLaneWidths=getString(message('driving:scenario:VariableLaneWidths'));
                        warningMessage=[warningMessage,newline,bulletStr,wVarLaneWidths];
                    end
                    if(numel(warnings.variableLaneMarkerStyles)~=0)
                        wVarLaneMarkerStyles=getString(message('driving:scenario:VariableLaneMarkerStyles'));
                        warningMessage=[warningMessage,newline,bulletStr,wVarLaneMarkerStyles];
                    end
                    if(numel(warnings.invalidLaneMarkerTypes)~=0)
                        wInvalidLaneMarkerTypes=getString(message('driving:scenario:InvalidLaneMarkerTypes',...
                            strjoin(unique(warnings.invalidLaneMarkerTypes),', ')));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidLaneMarkerTypes];
                    end
                    if warnings.isElevationInvalid
                        wElevationNaN=getString(message('driving:scenario:ElevationValueNaNorInf'));
                        warningMessage=[warningMessage,newline,bulletStr,wElevationNaN];
                    end
                    if warnings.isSuperElevationInvalid
                        wBankAngleNaN=getString(message('driving:scenario:SuperElevationValueNaNorInf'));
                        warningMessage=[warningMessage,newline,bulletStr,wBankAngleNaN];
                    end
                    if warnings.isRoadMarkColorinvalid
                        wInvalidColor=getString(message('driving:scenario:InvalidMarkingColorOpenDRIVE'));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidColor];
                    end
                    if warnings.isJunctionInvalid
                        wInvalidJunction=getString(message('driving:scenario:InvalidNaNorInfValueOpenDRIVE','junction attribute values of road element','-1'));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidJunction];
                    end
                    if warnings.isLaneOffsetInvalid
                        wInvalidLaneOffset=getString(message('driving:scenario:InvalidNaNorInfValueOpenDRIVE','laneoffset values','empty'));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidLaneOffset];
                    end
                    if warnings.isLaneMarkWidthInvalid
                        wInvalidRoadMarkWidth=getString(message('driving:scenario:InvalidNaNorInfValueOpenDRIVE','width attribute values of road mark','0.15'));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidRoadMarkWidth];
                    end
                    if warnings.isLaneWidthInvalid
                        wInvalidLaneWidth=getString(message('driving:scenario:InvalidNaNorInfValueOpenDRIVE','lane width values','3'));
                        warningMessage=[warningMessage,newline,bulletStr,wInvalidLaneWidth];
                    end
                    footerMessage=getString(message('driving:scenario:OpenDRIVEWarningFooter'));
                    warningMessage=[warningMessage,newline,newline,footerMessage,newline];
                end
            end
        end

        function addRecentFile(this,fileName,tag)
            addRecentFile@matlabshared.application.ToolGroupFileSystem(this,fileName,tag);
        end

        function updatePlots(this)
            updatePlots@driving.internal.scenarioApp.Display(this);
            if~isempty(this.BirdsEyePlot)
                update(this.BirdsEyePlot);
            end
            if~isempty(this.SensorCanvas)
                update(this.SensorCanvas);
            end
        end

        function updatePlotsForActors(this)
            updatePlotsForActors@driving.internal.scenarioApp.Display(this);
            if~isempty(this.BirdsEyePlot)
                update(this.BirdsEyePlot);
            end
            if~isempty(this.SensorCanvas)
                update(this.SensorCanvas);
            end
        end

        function item=copyItemImpl(this)
            mode=this.MostRecentCanvas;
            item=[];
            if strcmp(mode,'scenario')
                item=this.ScenarioView.CurrentSpecification;
            elseif strcmp(mode,'sensors')
                item=getCurrentSensor(this);
            end
            if~isempty(item)



                item=copy(item);
            end
        end

        function item=cutItemImpl(this)
            mode=this.MostRecentCanvas;
            edit=[];
            if strcmp(mode,'scenario')
                item=this.ScenarioView.CurrentSpecification;
                if isa(item,'driving.internal.scenarioApp.ActorSpecification')
                    edit=driving.internal.scenarioApp.undoredo.CutActor(this,item);


                elseif isa(item,'driving.internal.scenarioApp.road.Specification')
                    edit=driving.internal.scenarioApp.undoredo.CutRoad(this,item);
                elseif isa(item,'driving.internal.scenarioApp.BarrierSpecification')
                    edit=driving.internal.scenarioApp.undoredo.CutBarrier(this,item);
                end
            elseif strcmp(mode,'sensors')
                item=getCurrentSensor(this);
                edit=driving.internal.scenarioApp.undoredo.CutSensor(this,item);
            end
            if~isempty(edit)
                applyEdit(this,edit);
            end
        end

        function pasteItemImpl(this,item,varargin)
            if isa(item,'driving.internal.scenarioApp.SensorSpecification')
                pasteItem(this.SensorCanvas,item,varargin{:});


            else
                pasteItem(this.ScenarioView,item,varargin{:});
            end
        end

        function onNewUse3dSimDimensions(this,newUse3d)
            canvas=this.ScenarioView;
            if~isempty(canvas)
                update(canvas);
                if newUse3d
                    canvas.removeMessage('GamingEngineIncompatibility');
                end
            end
        end

        function onNewSampleTime(this,newSampleTime)
            this.Scenario.SampleTime=newSampleTime;
        end

        function onScenarioCanvasSelectionChanged(this,~,~)
            updateCutCopyPasteQab(this);
            selection=this.ScenarioView.CurrentSpecification;
            if isa(selection,'driving.internal.scenarioApp.road.Specification')
                roadProps=this.RoadProperties;
                roadProps.SpecificationIndex=find(this.RoadSpecifications==selection);
                focusOnComponent(roadProps);
            elseif isa(selection,'driving.internal.scenarioApp.ActorSpecification')
                actorProps=this.ActorProperties;
                actorProps.SpecificationIndex=[selection.ActorID];
                focusOnComponent(actorProps);
            end
        end

        function onScenarioCanvasModeChanged(this,~,~)
            mode=this.ScenarioView.InteractionMode;
            roadProps=this.RoadProperties;
            actorProps=this.ActorProperties;

            actorNeedsUpdate=actorProps.InteractiveMode;
            actorProps.InteractiveMode=false;
            roadNeedsUpdate=roadProps.InteractiveMode;
            roadProps.InteractiveMode=false;
            if any(strcmp(mode,{'addRoad','addRoadCenters'}))
                roadNeedsUpdate=~roadProps.InteractiveMode;
                roadProps.InteractiveMode=true;
                focusOnComponent(roadProps);
            end

            if any(strcmp(mode,{'addActor','addActorWaypoints'}))
                actorNeedsUpdate=~actorProps.InteractiveMode;
                actorProps.InteractiveMode=true;
                focusOnComponent(actorProps);
            end




            if~isempty(this.BarrierProperties)
                barrierProps=this.getBarrierPropertiesComponent();
                if any(strcmp(mode,{'addBarrier','addMultipleBarriers','addBarrierCenters'}))
                    barrierNeedsUpdate=~barrierProps.InteractiveMode;
                    barrierProps.InteractiveMode=true;
                    focusOnComponent(barrierProps);
                else
                    barrierNeedsUpdate=barrierProps.InteractiveMode;
                    barrierProps.InteractiveMode=false;
                end
                if barrierNeedsUpdate
                    update(barrierProps);
                end
            end

            if roadNeedsUpdate
                update(roadProps);
            end
            if actorNeedsUpdate
                update(actorProps);
            end
        end

        function onCanvasPropertyChanged(this,~,ev)
            if isa(ev.Specification,'driving.internal.scenarioApp.road.Specification')
                updateProperty(this.RoadProperties,ev.Property);
            elseif isa(ev.Specification,'driving.internal.scenarioApp.ActorSpecification')
                updateProperty(this.ActorProperties,ev.Property);
            elseif isa(ev.Specification,'driving.internal.scenarioApp.BarrierSpecification')
                if~isempty(this.BarrierProperties)
                    updateProperty(this.BarrierProperties,ev.Property);
                end
            end
        end

        function onSimulatorStateChanged(this,~,~)
            simulator=this.Simulator;
            stopped=isStopped(simulator);
            paused=isPaused(simulator);
            if this.CloseRequested&&(stopped||paused)
                approveClose(this);
                return;
            end
            enabled=stopped;
            roadProps=this.RoadProperties;
            roadProps.Enabled=enabled;
            update(roadProps);

            if~isempty(this.BarrierProperties)
                barrierProps=this.BarrierProperties;
                barrierProps.Enabled=enabled;
                update(barrierProps);
            end

            actorProps=this.ActorProperties;
            actorProps.Enabled=enabled;
            update(actorProps);

            sensorProps=this.SensorProperties;
            if~isempty(sensorProps)
                sensorProps.Enabled=enabled;
                update(sensorProps);
            end

            simSettings=this.SimulationSettings;
            if~isempty(simSettings)
                update(simSettings);
            end

            updateUndoRedo(this);
            updateCutCopyPasteQab(this);
            canvas=this.ScenarioView;
            if stopped||paused
                stopTimeStampTimer(canvas);
            else
                startTimeStampTimer(canvas);
            end
            if this.IsUpdateAllowed

                updateForSimulationStateChange(canvas);

            end
            updateToolstrip(this.Simulator);
        end

        function b=canUndo(this)
            sim=this.Simulator;
            if isempty(sim)
                b=true;
            else
                b=isStopped(this.Simulator);
            end
            if b
                b=canUndo(this.UndoRedo);
            end
        end

        function b=canRedo(this)
            sim=this.Simulator;
            if isempty(sim)
                b=true;
            else
                b=isStopped(this.Simulator);
            end
            if b
                b=canRedo(this.UndoRedo);
            end
        end

        function onPropertyChanged(this,~,~)
            setDirty(this);
        end

        function h=createToolstrip(this)

            h=driving.internal.scenarioApp.Toolstrip(this);
        end

        function str=getDirtyWarningString(~,type)
            if strcmp(type,'close')
                str=getString(message('driving:scenarioApp:CloseDirtyStateWarning'));
            else
                str=getString(message('driving:scenarioApp:DirtyStateWarning'));
            end
        end

        function f=createDefaultComponents(this)
            displayBarrierEditPoints=true;
            canvas=driving.internal.scenarioApp.ScenarioCanvas(this,...
                'ShowWaypoints',true,...
                'ShowRoadEditPoints',true,...
                'ShowBarrierEditPoints',displayBarrierEditPoints);
            this.ScenarioView=canvas;
            if isfield(this.ViewCache,'ScenarioView')&&~isempty(this.ViewCache.ScenarioView)
                cache=this.ViewCache.ScenarioView;
                if isfield(cache,'XLim')
                    canvas.Axes.XLim=cache.XLim;
                    canvas.Axes.YLim=cache.YLim;
                elseif isfield(cache,'Center')
                    setCenterAndUnitsPerPixel(canvas,cache.Center,cache.UnitsPerPixel);
                end
                if isfield(cache,'EnableRoadInteractivity')
                    canvas.EnableRoadInteractivity=cache.EnableRoadInteractivity;
                end
                if isfield(cache,'VerticalAxis')
                    canvas.VerticalAxis=cache.VerticalAxis;
                end
            end
            this.EgoCentricView=driving.internal.scenarioApp.EgoCentricView(this);
            if isfield(this.ViewCache,'EgoCentricView')&&~isempty(this.ViewCache.EgoCentricView)
                cache=this.ViewCache.EgoCentricView;
                if isfield(cache,'ShowActorMeshes')
                    this.EgoCentricView.ShowActorMeshes=cache.ShowActorMeshes;
                end
            end
            this.RoadProperties=driving.internal.scenarioApp.RoadProperties(this);
            this.ActorProperties=driving.internal.scenarioApp.ActorProperties(this);

            canvas=this.ScenarioView;

            allProps=[this.RoadProperties,this.ActorProperties,getBarrierPropertiesComponent(this,true)];

            this.PropertyListener=event.listener(allProps,...
                'PropertyChanged',@this.onPropertyChanged);
            this.ScenarioCanvasModeChangedListener=event.listener(canvas,...
                'ModeChanged',@this.onScenarioCanvasModeChanged);
            this.ScenarioCanvasSelectionChangedListener=event.listener(canvas,...
                'SelectionChanged',@this.onScenarioCanvasSelectionChanged);
            this.WaypointsChangedListener=event.listener(canvas,...
                'PropertyChanged',@this.onCanvasPropertyChanged);

            f=[this.ScenarioView,this.EgoCentricView,allProps...
                ,getSensorPropertiesComponent(this,true),getBirdsEyePlotComponent(this,true)...
                ,getSensorCanvasComponent(this,true)];

            if this.Scenario.IsOpenDRIVERoad
                this.Toolstrip.hAddRoad.Enabled=false;
                this.Toolstrip.hExportMatlabCode.Enabled=false;
                canvas.EnableRoadInteractivity=false;
            end
        end

        function autoScaleCanvas(this)
            canvas=this.ScenarioView;
            axes=canvas.Axes;
            set(axes,'XLimMode','auto','YLimMode','auto','ZLimMode','auto');
            drawnow

            captureAxesLimits(canvas);



            canvas.UnitsPerPixel=canvas.UnitsPerPixel*1.1;
            set(axes,'XLimMode','manual','YLimMode','manual');
            fixZLim(canvas);
        end

        function autoScale(this)
            if this.NeedsAutoScale
                autoScaleCanvas(this);
            end
        end

        function data=getSaveData(this,type)








            if~strcmp(type,'classes')
                data.AxesOrientation=this.AxesOrientation;
            end
            if any(strcmp(type,{'session','scenario'}))
                data.RoadSpecifications=this.RoadSpecifications;
                data.ActorSpecifications=this.ActorSpecifications;
                data.BarrierSpecifications=this.BarrierSpecifications;
                data.EgoCarId=this.EgoCarId;


                sims=this.AllSimulators;
                for indx=1:numel(sims)
                    data.Simulators(indx)=struct(...
                        'class',class(sims(indx)),...
                        'props',serialize(sims(indx)));
                end
                data.Simulator=class(this.Simulator);

                data.SampleTime=this.SampleTime;
                data.GeographicReference=this.GeographicReference;

                data.ScenarioView.Center=this.ScenarioView.Center;
                data.ScenarioView.UnitsPerPixel=this.ScenarioView.UnitsPerPixel;
                data.ScenarioView.EnableRoadInteractivity=this.ScenarioView.EnableRoadInteractivity;
                data.ScenarioView.ShowEgoIndicator=this.ScenarioView.ShowEgoIndicator;
                data.ScenarioView.VerticalAxis=this.ScenarioView.VerticalAxis;

                data.BirdsEyePlot=[];
                if~isempty(this.BirdsEyePlot)
                    data.BirdsEyePlot.Center=this.BirdsEyePlot.Center;
                    data.BirdsEyePlot.UnitsPerPixel=this.BirdsEyePlot.UnitsPerPixel;
                end

                data.IsOpenDRIVERoad=this.Scenario.IsOpenDRIVERoad;
                data.ActorCount=this.ActorCount;
                data.Use3dSimDimensions=this.Use3dSimDimensions;


                data.EgoCentricView.ShowActorMeshes=this.EgoCentricView.ShowActorMeshes;
                data.Sim3dScene=this.Sim3dScene;
            end
            if any(strcmp(type,{'session','scenario','classes'}))
                data.ClassSpecifications=getSaveData(this.ClassSpecifications);
            end
            if any(strcmp(type,{'session','sensors'}))
                data.CustomSeed=this.CustomSeed;
                data.SensorSpecifications=this.SensorSpecifications;
            end
        end

        function path=getOpenFilePath(this,tag)
            if strcmp(tag,'PrebuiltScenario')
                path=fullfile(matlabroot,'toolbox','shared','drivingscenario','PrebuiltScenarios');
            else
                path=getOpenFilePath@matlabshared.application.ToolGroupFileSystem(this);
            end
        end

        function newTag=updateTag(this,tag)
            if strcmp(tag,'PrebuiltScenario')
                newTag=getDefaultOpenTag(this);
            else
                newTag=updateTag@matlabshared.application.ToolGroupFileSystem(this,tag);
            end
        end

        function processOpenData(this,newData,type)


            if any(strcmp(type,{'classes'}))
                if~isfield(newData,'ClassSpecifications')
                    error(message('driving:scenarioApp:InvalidClassDefinitionFile'));
                end
                if~isempty(this.ActorSpecifications)
                    yes=getString(message('Spcuilib:application:Yes'));
                    no=getString(message('Spcuilib:application:No'));
                    answer=uiconfirm(this,getString(message('driving:scenarioApp:LoadClassesWithExistingActors')),...
                        getName(this),{yes,no},yes);
                    if isempty(answer)||strcmp(answer,no)
                        return;
                    end
                    new(this,'scenario',true);
                end
                processOpenData(this.ClassSpecifications,newData.ClassSpecifications);
                if~isempty(this.Toolstrip)
                    updateActorsGallery(this.Toolstrip);
                end
            end

            if any(strcmp(type,{'scenario','session','PrebuiltScenario'}))
                notify(this,'NewScenario');
            end


            if isfield(newData,'AxesOrientation')
                orientation=newData.AxesOrientation;
            else
                orientation='ENU';
            end
            if~strcmp(type,'classes')



                if isfield(newData,'RoadSpecifications')
                    this.RoadSpecifications=[];
                end
                if isfield(newData,'ActorSpecifications')
                    this.ActorSpecifications=[];
                end
                if isfield(newData,'SensorSpecifications')
                    this.SensorSpecifications=driving.internal.scenarioApp.SensorSpecification.empty;
                end
                this.BarrierSpecifications=driving.internal.scenarioApp.BarrierSpecification.empty;
                this.AxesOrientation=orientation;
            end


            if any(strcmp(type,{'session','PrebuiltScenario','scenario'}))
                if~isfield(newData,'RoadSpecifications')||...
                        ~isfield(newData,'ActorSpecifications')||...
                        ~isfield(newData,'EgoCarId')
                    error(message('driving:scenarioApp:InvalidScenarioFile'));
                end



                if isfield(newData,'IsOpenDRIVERoad')
                    if newData.IsOpenDRIVERoad
                        roadSpecs=newData.RoadSpecifications;
                        newData.IsOpenDRIVERoad=false;
                        if~isempty(roadSpecs)
                            for indx=1:numel(roadSpecs)
                                rollAngle=roadSpecs(indx).BankAngle;
                                roadCenters=roadSpecs(indx).Centers;
                                InHeading=roadSpecs(indx).Heading;
                                [centers,bankAngle,heading]=driving.scenario.internal.shiftCenters(roadCenters,rollAngle,InHeading);
                                roadSpecs(indx).Centers=centers;
                                roadSpecs(indx).BankAngle=bankAngle;
                                roadSpecs(indx).Heading=heading;
                                roadSpecs(indx).IsOpenDRIVE=false;
                                roadSpecs(indx).LeftRoadWidth=[];
                                roadSpecs(indx).RightRoadWidth=[];
                            end
                            newData.RoadSpecifications=roadSpecs;
                        end
                    end
                end


                this.RoadSpecifications=transpose(newData.RoadSpecifications(:));
                newData=extractBarriersFromActorData(this,newData);
                this.ActorSpecifications=newData.ActorSpecifications;
                roadProps=this.RoadProperties;
                actorProps=this.ActorProperties;
                if~isempty(roadProps)
                    roadProps.SpecificationIndex=1;
                    actorProps.SpecificationIndex=1;
                end

                if isfield(newData,'ClassSpecifications')
                    processOpenData(this.ClassSpecifications,newData.ClassSpecifications);
                    toolstrip=this.Toolstrip;
                    if~isempty(toolstrip)
                        updateActorsGallery(toolstrip);
                    end
                end
                if isfield(newData,'Sim3dScene')
                    this.Sim3dScene=newData.Sim3dScene;
                end


                actorSpecs=this.ActorSpecifications;
                classSpecs=this.ClassSpecifications;
                for indx=1:numel(actorSpecs)


                    if isempty(actorSpecs(indx).AssetType)
                        actorSpecs(indx).AssetType=classSpecs.getProperty(actorSpecs(indx).ClassID,'AssetType');
                    elseif strcmp(actorSpecs(indx).AssetType,'Unknown')
                        actorSpecs(indx).AssetType='Cuboid';
                    end

                    aMesh=actorSpecs(indx).Mesh;
                    shouldUpdateMesh=isempty(aMesh);
                    if~shouldUpdateMesh


                        shouldUpdateMesh=isequal(size(aMesh.Vertices),[8,3])&&isequal(size(aMesh.Faces),[12,3]);
                    end
                    if shouldUpdateMesh

                        isVehicle=classSpecs.getProperty(actorSpecs(indx).ClassID,'isVehicle');
                        dims=struct('Length',actorSpecs(indx).Length,'Width',actorSpecs(indx).Width,...
                            'Height',actorSpecs(indx).Height,'RearOverhang',1);
                        if isempty(driving.internal.scenarioApp.ClassEditor.getMeshExpression(aMesh,isVehicle,dims))

                            actorSpecs(indx).Mesh=classSpecs.getProperty(actorSpecs(indx).ClassID,'Mesh');
                        end
                    end
                end

                if isfield(newData,'BarrierSpecifications')
                    this.BarrierSpecifications=newData.BarrierSpecifications;
                    if isOpen(this)
                        barrierProps=getBarrierPropertiesComponent(this);
                        barrierProps.SpecificationIndex=1;
                    end
                end


                if~isempty(this.Scenario)&&this.Scenario.IsOpenDRIVERoad
                    this.Scenario.IsOpenDRIVERoad=false;
                end


                if isfield(newData,'IsOpenDRIVERoad')
                    this.Scenario.IsOpenDRIVERoad=newData.IsOpenDRIVERoad;
                end
                if~isfield(newData,'ActorCount')
                    newData.ActorCount=numel(newData.ActorSpecifications);
                end
                if isfield(newData,'GeographicReference')
                    this.Scenario.GeographicReference=newData.GeographicReference;
                end
                this.ActorCount=newData.ActorCount;

                this.EgoCarId=newData.EgoCarId;
                generateNewScenarioFromSpecifications(this);


                if isfield(newData,'ScenarioView')&&~isempty(newData.ScenarioView)
                    svData=newData.ScenarioView;
                    canvas=this.ScenarioView;
                    if~isempty(canvas)
                        if isfield(svData,'XLim')
                            applyAxesLimits(canvas,svData.YLim,svData.XLim);
                        else
                            setCenterAndUnitsPerPixel(canvas,svData.Center,svData.UnitsPerPixel);
                        end


                        if isfield(svData,'EnableRoadInteractivity')
                            canvas.EnableRoadInteractivity=svData.EnableRoadInteractivity;
                        else
                            canvas.EnableRoadInteractivity=canvas.DefaultRoadInteractivity;
                        end
                        if isfield(svData,'ShowEgoIndicator')
                            canvas.ShowEgoIndicator=svData.ShowEgoIndicator;
                        end
                        if isfield(svData,'VerticalAxis')
                            canvas.VerticalAxis=svData.VerticalAxis;
                        else
                            canvas.VerticalAxis=canvas.DefaultVerticalAxis;
                        end


                    else
                        if isfield(svData,'XLim')
                            this.ViewCache.ScenarioView.XLim=svData.XLim;
                            this.ViewCache.ScenarioView.YLim=svData.YLim;
                        else
                            this.ViewCache.ScenarioView.Center=svData.Center;
                            this.ViewCache.ScenarioView.UnitsPerPixel=svData.UnitsPerPixel;
                        end
                        if isfield(svData,'EnableRoadInteractivity')
                            this.ViewCache.ScenarioView.EnableRoadInteractivity=svData.EnableRoadInteractivity;
                        end
                        if isfield(svData,'VerticalAxis')
                            this.ViewCache.ScenarioView.VerticalAxis=svData.VerticalAxis;
                        end
                    end
                end


                if isfield(newData,'EgoCentricView')&&~isempty(newData.EgoCentricView)
                    svData=newData.EgoCentricView;
                    canvas=this.EgoCentricView;
                    if~isempty(canvas)
                        if isfield(svData,'ShowActorMeshes')
                            canvas.ShowActorMeshes=svData.ShowActorMeshes;
                        end
                    else
                        if isfield(svData,'ShowActorMeshes')
                            this.ViewCache.EgoCentricView.ShowActorMeshes=svData.ShowActorMeshes;
                        end
                    end
                end

                if~isempty(roadProps)
                    update(roadProps);
                    update(actorProps);
                    updateToolstrip(this.Simulator);
                end

                barrierProps=this.BarrierProperties;
                if~isempty(barrierProps)
                    update(barrierProps);
                end

                if isfield(newData,'Simulator')
                    sims=newData.Simulators;
                    for indx=1:numel(sims)
                        sim=initSimulator(this,sims(indx).class);
                        deserialize(sim,sims(indx).props);
                    end
                    initSimulator(this,newData.Simulator);
                else

                    initSimulator(this,'driving.internal.scenarioApp.ScenarioSimulator');
                    player=this.Simulator.Player;
                    if isfield(newData,'Repeat')
                        player.Repeat=newData.Repeat;
                        player.StopCondition=newData.StopCondition;
                        player.StopTime=newData.StopTime;
                        this.SampleTime=newData.SampleTime;
                    else

                        player.Repeat=false;
                        player.StopCondition='first';
                        player.StopTime=10;
                        this.SampleTime=0.01;
                    end
                end
                if isfield(newData,'Use3dSimDimensions')
                    this.Use3dSimDimensions=newData.Use3dSimDimensions;
                end

            end


            if any(strcmp(type,{'session','PrebuiltScenario','sensors'}))
                if isfield(newData,'CustomSeed')
                    this.CustomSeed=newData.CustomSeed;
                end
                if isfield(newData,'SensorSpecifications')
                    sensors=newData.SensorSpecifications;
                    for indx=1:numel(sensors)
                        fixBackwardsCompatibility(sensors(indx));
                    end
                    this.SensorSpecifications=sensors;
                elseif strcmp(type,'sensors')


                    error(message('driving:scenarioApp:InvalidSensorFile'));
                end
                if isOpen(this)
                    updateForSensors(this);
                end




                if(isfield(newData,'BirdsEyePlot')&&~isempty(newData.BirdsEyePlot))
                    svData=newData.BirdsEyePlot;
                    bep=this.BirdsEyePlot;
                    if~isempty(bep)
                        if isfield(svData,'XLim')
                            bep.Axes.XLim=svData.XLim;
                            bep.Axes.YLim=svData.YLim;
                        else
                            setCenterAndUnitsPerPixel(bep,svData.Center,svData.UnitsPerPixel);
                        end
                    else
                        if isfield(svData,'XLim')
                            this.ViewCache.BirdsEyePlot.XLim=svData.XLim;
                            this.ViewCache.BirdsEyePlot.YLim=svData.YLim;
                        else
                            this.ViewCache.BirdsEyePlot.Center=svData.Center;
                            this.ViewCache.BirdsEyePlot.UnitsPerPixel=svData.UnitsPerPixel;
                        end
                    end
                end
            end


            sv=this.ScenarioView;
            if~isempty(sv)
                exitInteractionMode(sv);
            end
            sc=this.SensorCanvas;
            if~isempty(sc)
                sc.InteractionMode='none';
            end
            warnings=this.LoadWarning;
            if~isempty(warnings)&&~isempty(sv)
                warningMessage(sv,warnings{:});
            end


            if~isempty(this.Toolstrip)
                updateExport(this.Toolstrip);
            end
        end

        function parseInputs(this,varargin)
            fileName=[];
            scenario=[];
            sensors=[];
            egoCarId=[];
            pvPairs=varargin;
            if nargin>1
                if ischar(pvPairs{1})||isstring(pvPairs{1})



                    if~isprop(this,pvPairs{1})
                        fileName=pvPairs{1};
                        pvPairs(1)=[];
                    end
                end







                while~isempty(pvPairs)&&~ischar(pvPairs{1})&&~isstring(pvPairs{1})
                    if iscell(pvPairs{1})&&~isempty(pvPairs{1})&&isSensor(pvPairs{1}{1})
                        sensors=pvPairs{1};
                    elseif isSensor(pvPairs{1})



                        sensors=pvPairs(1);
                    elseif isnumeric(pvPairs{1})&&~isempty(scenario)


                        egoCarId=pvPairs{1};
                    elseif isa(pvPairs{1},'drivingScenario')
                        scenario=pvPairs{1};
                    else
                        id='driving:scenarioApp:UnrecognizedInput';
                        error(id,getString(message(id)));
                    end
                    pvPairs(1)=[];
                end
            end


            for indx=1:2:numel(pvPairs)
                this.(pvPairs{indx})=pvPairs{indx+1};
            end


            if~isempty(fileName)
                this.openFile(fileName);
                removeDirty(this);
            end


            if~isempty(scenario)


                setDirty(this);
                this.NeedsAutoScale=true;


                if~isempty(scenario.ParkingLots)
                    fig=helpdlg(getString(message('driving:scenarioApp:ParkingLotsNotSupportedText')),...
                        getString(message('driving:scenarioApp:ParkingLotsNotSupportedTitle')));
                    uiwait(fig);
                end





                this.AxesOrientation=scenario.AxesOrientation;
                this.ViewCache.ScenarioView.VerticalAxis=scenario.VerticalAxis;
                this.RoadSpecifications=[driving.internal.scenarioApp.road.Arbitrary.fromScenario(scenario)...
                    ,driving.internal.scenarioApp.road.RoadGroupArbitrary.fromScenario(scenario)];
                this.ActorSpecifications=driving.internal.scenarioApp.ActorSpecification.fromScenario(scenario,this.ClassSpecifications);
                this.BarrierSpecifications=driving.internal.scenarioApp.BarrierSpecification.fromScenario(scenario,this.ClassSpecifications.Map);
                this.Scenario=generateNewScenarioFromSpecifications(this);

                if~isempty(this.RoadSpecifications)&&isa(this.RoadSpecifications(1),...
                        'driving.internal.scenarioApp.road.Arbitrary')...
                        &&this.RoadSpecifications(1).IsOpenDRIVE
                    this.Scenario.IsOpenDRIVERoad=true;
                    this.Scenario.ShowRoadBorders=false;
                end
                if~isempty(egoCarId)
                    if~isscalar(egoCarId)
                        warning(message('driving:scenarioApp:EgoCarIdNonScalar'));
                        egoCarId=[];
                    elseif egoCarId>numel(this.ActorSpecifications)
                        warning(message('driving:scenarioApp:EgoCarIdExceedsActors'));
                        egoCarId=[];
                    else
                        egoClass=this.ActorSpecifications(egoCarId).ClassID;
                        cs=this.ClassSpecifications;
                        if~cs.getProperty(egoClass,'isVehicle')
                            warning(message('driving:scenarioApp:EgoCarIdInvalidClass'));
                            egoCarId=[];
                        end
                    end
                end
                if isempty(egoCarId)

                    if~isempty(this.ActorSpecifications)
                        classIds=[this.ActorSpecifications.ClassID];
                        cs=this.ClassSpecifications;



                        for index=1:numel(classIds)
                            if cs.getProperty(classIds(index),'isVehicle')
                                egoCarId=index;
                                break
                            end
                        end
                    end
                end

                if~isempty(scenario.GeoReference)
                    this.Scenario.GeographicReference=scenario.GeoReference;


                    this.ViewCache.ScenarioView.EnableRoadInteractivity=false;
                end

                this.SampleTime=scenario.SampleTime;
                this.EgoCarId=egoCarId;
            end


            if~isempty(sensors)

                sensors=driving.internal.scenarioApp.SensorSpecification.fromDetectionGenerators(sensors);
                [intervals,changed]=driving.internal.scenarioApp.SensorSpecification.fixUpdateIntervals([sensors.UpdateInterval],this.SampleTime*1000);
                if changed
                    id='driving:scenarioApp:UpdateUpdateIntervalOnImport';
                    warning(id,getString(message(id)));
                    for indx=1:numel(sensors)
                        sensors(indx).UpdateInterval=intervals(indx);
                    end
                end
                this.SensorSpecifications=sensors;
            end
            initSimulator(this,'driving.internal.scenarioApp.ScenarioSimulator');
            if isempty(this.Scenario)
                this.Scenario=drivingScenario;
            elseif~isempty(scenario)&&~isinf(scenario.StopTime)
                player=this.Simulator.Player;
                player.StopCondition='time';
                player.StopTime=scenario.StopTime;
            end
        end

        function newData=extractBarriersFromActorData(this,newData)

            egoCarId=newData.EgoCarId;
            egoCar=newData.ActorSpecifications(egoCarId);

            barrierClassIDs=driving.internal.scenarioApp.BarrierSpecification.getClassAndID(newData.ClassSpecifications);

            count=1;
            barrierSpecs=driving.internal.scenarioApp.BarrierSpecification.empty;
            for i=1:numel(newData.ActorSpecifications)
                actorSpec=newData.ActorSpecifications(i);
                if barrierClassIDs.isKey(actorSpec.ClassID)
                    barrierSpecs(count,1)=driving.internal.scenarioApp.BarrierSpecification.convertActorToBarrier(actorSpec);
                    barrierSpecs(count,1).BarrierType=barrierClassIDs(actorSpec.ClassID);
                    barrierIdx(count)=i;
                    count=count+1;
                end
            end
            if~isempty(barrierSpecs)

                newData.ActorSpecifications(barrierIdx)=[];

                egoMatch=arrayfun(@(x)isequal(x,egoCar),newData.ActorSpecifications);
                egoIdx=find(egoMatch==1);
                if~isequal(egoIdx,egoCarId)
                    newData.EgoCarId=egoIdx;
                end

                if isfield(newData,'BarrierSpecifications')
                    newData.BarrierSpecifications=[newData.BarrierSpecifications,barrierSpecs'];
                else
                    newData.BarrierSpecifications=barrierSpecs';
                end
            end
        end
    end

    methods(Access={?driving.internal.scenarioImport.RoadNetworkImporter})

        function applyScenarioImport(this,importer)
            import driving.internal.scenarioApp.road.*

            roadCreationStarting(this)
            rc=onCleanup(@()roadCreationFinished(this));

            new(this,'scenario',true);
            notify(this,'NewScenario');

            setDirty(this);


            this.RoadSpecifications=[Arbitrary.fromScenario(importer.Scenario),...
                RoadGroupArbitrary.fromScenario(importer.Scenario)];
            this.Scenario=generateNewScenarioFromSpecifications(this);
            this.Scenario.GeographicReference=importer.getGeographicReference();


            canvas=this.ScenarioView;
            canvas.VerticalAxis='Y';
            canvas.EnableRoadInteractivity=false;
            fitToView(canvas);


            importer.postAppImport(this);

            if~isempty(this.Toolstrip)
                updateExport(this.Toolstrip);
            end
        end

    end

end

function cleanUpWarning(wstate,wstr,wid)

warning(wstate);
lastwarn(wstr,wid);

end

function setLocation(comp,md,toolGroup,column,notFirstCall)

name=getName(comp);

if notFirstCall
    toolgroupClient=javaMethodEDT('getClient',md,name,toolGroup);
    tl=javaMethodEDT('getClientLocation',md,toolgroupClient);
else

    tl=md.getClientLocation(md.getClient(name,toolGroup));
end


if tl.getTile~=column.getTile
    md.setClientLocation(name,toolGroup,column);
end
end

function b=isSensor(input)
b=isa(input,'driving.internal.AbstractDetectionGenerator')||...
    isa(input,'lidarsim.internal.AbstractLidarSensor')||...
    isa(input,'insSensor')||...
    isa(input,'drivingRadarDataGenerator')||...
    isa(input,'ultrasonicDetectionGenerator');
end


