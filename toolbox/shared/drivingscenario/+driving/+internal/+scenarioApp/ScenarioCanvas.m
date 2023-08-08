classdef ScenarioCanvas<driving.internal.scenarioApp.ScenarioView&...
        matlabshared.application.Canvas&...
        matlabshared.application.ComponentBanner&...
        driving.internal.scenarioApp.UITools





    properties



        InteractionMode='none'
        ShowWaypointsDuringSim=false;
        ShowRoadEditPointsDuringSim=false;
        ShowPoseIndicatorDuringSim=false;
        ShowEgoIndicator=false;
        EnableRoadInteractivity(1,1)logical=driving.internal.scenarioApp.ScenarioCanvas.DefaultRoadInteractivity;
    end

    properties(Access=protected)
        HasUserNotClicked=true;
        IsDoubleClick=false;


        PanHasOccurred=false;
        EgoCarIdListener;
        CurrentIndexToRemove=[];
    end

    properties


        CurrentSpecification


        PreviousMousePointer


        CurrentActor


        CurrentBarrier


        CurrentRoad



        WaypointLine



        Waypoints

        RoadEditPointDragPvPairs
        BarrierEditPointDragPvPairs


        ActorID


        BarrierID


        BarrierRoads=driving.scenario.Road.empty


        BarrierRoadEdges={}


        BarrierRoadEdgeLines={}




        CursorLine


        RoadID




        IsDraggingStart=false


        CachedPosition
        CachedYaw;
        CachedOffset;


        CachedWaypoints


        WaypointIndex


        ShouldDirty=false



        RoadOutline=matlab.graphics.primitive.Line.empty


        RoadCenterMarker


        RoadEditPointId
        RoadEditPointCache


        BarrierEditPointId
        BarrierEditPointCache
        BarrierCenterMarker
        BarrierOutline=matlab.graphics.primitive.Line.empty
        DragOffset=[0,0,0]
    end

    properties(Hidden,SetObservable)
        ClickLocation
        ClickIndex
        ClickIndexStale=false;
    end

    properties(Hidden)
        hShowWaypointsDuringSim
        hShowRoadEditPointsDuringSim
        hShowPoseIndicatorDuringSim
        hEnableRoadInteractivity
        hShowEgoIndicator
        hScenarioSettings
    end

    properties(SetAccess=protected,Hidden)
        Marquee
        RoadHighlight
        RoadEdgeHighlight=[]
        RoadEdgeSelect=[]
        ActorHighlight
        BarrierHighlight
        RoadContextMenu
        ActorContextMenu
        BarrierContextMenu
        AxesContextMenu
        WaylineContextMenu
        RoadEditPointsContextMenu
        BarrierEditPointsContextMenu
        WaypointsContextMenu
        HelpText
        RoadInteractivityDisabledMessage
        SettingsMenu
        CustomRoadContextMenus
        CustomBarrierContextMenus
        CustomEditPointContextMenus
        PoseIndicator
        ActorRotator
        EgoIndicator=matlab.graphics.GraphicsPlaceholder.empty;
        SimulatorStateChangedListener
    end

    properties(Hidden,Constant)
        HighlightColor=[12,220,240]/255;
    end

    events
        PropertyChanged
        ModeChanged
        SelectionChanged
    end

    properties(Constant,Hidden)
        DefaultRoadInteractivity=true;
    end

    methods

        function this=ScenarioCanvas(varargin)

            this@driving.internal.scenarioApp.ScenarioView(varargin{:});
            this@matlabshared.application.Canvas();
            fig=this.Figure;
            ax=this.Axes;
            this.initializeScrollZoom();
            this.initializeFloatingPalette(fig,ax);
            this.Axes.ButtonDownFcn=@this.onButtonDown;
            this.AxesContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onAxesContextMenu,'tag','AxesContextMenu');
            this.RoadContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onRoadContextMenu);
            this.ActorContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onActorContextMenu);
            this.BarrierContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onBarrierContextMenu);
            this.WaylineContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onWaylineContextMenu);
            this.RoadEditPointsContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onRoadEditPointsContextMenu);
            this.BarrierEditPointsContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onBarrierEditPointsContextMenu);
            this.WaypointsContextMenu=uicontextmenu('Parent',fig,'Callback',@this.onWaypointsContextMenu);

            this.SimulatorStateChangedListener=addStateChangedListener(this.Application.Simulator,@this.onSimulatorStateChanged);
            this.EgoCarIdListener=addPropertyListener(this.Application,'EgoCarId',@this.onEgoCarIdChanged);
            contribute(this.Application.Toolstrip,this,'DisplayProperties','ScenarioView',...
                {'EnableRoadInteractivity','ShowRoadEditPointsDuringSim',...
                'ShowWaypointsDuringSim','ShowPoseIndicatorDuringSim','ShowEgoIndicator'});
        end

        function updateActor(this,varargin)
            updateActor@driving.internal.scenarioApp.ScenarioView(this,varargin{:});
            app=this.Application;
            if this.ShowPoseIndicatorDuringSim||~isRunning(app.Simulator)
                updatePoseIndicator(this);
            end

            if nargin>1&&isequal(varargin{1},app.EgoCarId)||nargin<2
                updateEgoIndicator(this);
            end
        end

        function resize(this)
            resize@driving.internal.scenarioApp.ScenarioView(this);
            updateHelpText(this);
            if~isempty(this.Banner)
                resize(this.Banner);
            end
        end

        function is_interacting=isInteracting(this)

            is_interacting=~strcmp(this.InteractionMode,'none');
        end

        function addActorWaypoints(this,actorID)


            this.clearPendingAdd;

            this.ActorID=actorID;
            this.InteractionMode='addActorWaypoints';
        end

        function addActor(this,spec)



            this.disableAxesToolbar;

            this.clearPendingAdd;

            this.CurrentActor=spec;
            this.InteractionMode='addActor';
        end

        function addRoadCenters(this,spec)


            this.clearPendingAdd;


            if isnumeric(spec)
                roadID=spec;
                spec=this.Application.RoadSpecifications(spec);
                mode='addRoadCenters';
            else
                roadID=[];
                mode='addRoad';
            end
            waypoints=getStartingAddPoints(spec);
            this.Waypoints=waypoints;
            this.CurrentRoad=spec;
            this.RoadID=roadID;
            this.InteractionMode=mode;
            createRoadCentersLine(this);
            updateWaypointLine(this);
            updateCursorLine(this,waypoints,getCurrentPoint(this));
        end

        function addBarrierCenters(this,spec)


            this.clearPendingAdd;
            if isnumeric(spec)
                barrierID=spec;
                spec=this.Application.BarrierSpecifications(spec);
                mode='addBarrierCenters';
            else
                barrierID=[];
                mode='addBarrier';
            end

            if this.Application.Scenario.UpdateRoadIntersectionsForBarriers
                getRoadIntersectionPointsFromMergedTiles(this.Application.Scenario);
            end
            waypoints=getStartingAddPoints(spec);
            this.Waypoints=waypoints;
            this.CurrentBarrier=spec;
            this.BarrierID=barrierID;
            this.InteractionMode=mode;
            createRoadCentersLine(this);
            updateWaypointLine(this);
            updateCursorLine(this,waypoints,getCurrentPoint(this));
            focusOnComponent(this);
        end

        function set.EnableRoadInteractivity(this,newValue)
            this.EnableRoadInteractivity=newValue;
            this.RoadInteractivityDisabledMessage.Visible=~newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'EnableRoadInteractivity',newValue);
            update(this);
        end

        function set.ShowWaypointsDuringSim(this,newValue)
            this.ShowWaypointsDuringSim=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowWaypointsDuringSim',newValue);
            update(this);
        end

        function set.ShowEgoIndicator(this,newValue)
            this.ShowEgoIndicator=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowEgoIndicator',newValue);
            updateEgoIndicator(this)
        end

        function set.ShowRoadEditPointsDuringSim(this,newValue)
            this.ShowRoadEditPointsDuringSim=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowRoadEditPointsDuringSim',newValue);
            update(this);
        end

        function set.ShowPoseIndicatorDuringSim(this,newValue)
            this.ShowPoseIndicatorDuringSim=newValue;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowPoseIndicatorDuringSim',newValue);
        end

        function set.InteractionMode(this,mode)
            this.InteractionMode=mode;
            helpStr='';
            isAdd=any(strcmp(mode,{'addActor','addBarrier','addMultipleBarriers','addBarrierCenters','addRoad','addRoadCenters','addActorWaypoints'}));
            isNone=strcmp(mode,'none');
            hApp=this.Application;%#ok<*MCSUP>
            if isNone||isAdd
                if hApp.ShowSimulators
                    updateToolstrip(hApp.Simulator);
                else
                    update(hApp.Toolstrip.SimulateSection);
                end
            end
            if isAdd&&this.HasUserNotClicked&&isempty(hApp.RoadSpecifications)&&isempty(hApp.ActorSpecifications)&&isempty(hApp.BarrierSpecifications)
                if strcmp(mode,'addActor')
                    helpStr=getString(message('driving:scenarioApp:AddActorHelpText'));
                elseif any(strcmp(mode,{'addBarrier','addMultipleBarriers'}))
                    helpStr=getString(message('driving:scenarioApp:AddBarrierHelpText'));
                elseif strcmp(mode,'addRoad')
                    helpStr=getString(message('driving:scenarioApp:AddRoadHelpText'));
                elseif strcmp(mode,'addActorWaypoints')
                    helpStr=getString(message('driving:scenarioApp:AddActorWaypointsHelpText'));
                end
            end


            if isNone
                updateCursorLine(this,[]);
                setTooltipString(this,'');
            end
            hText=this.HelpText;
            hAxes=getAxes(this);
            if isempty(helpStr)
                if~isempty(hText)&&ishghandle(hText)
                    delete(hText);
                    this.HelpText=[];
                end
            else
                if isempty(hText)||~ishghandle(hText)
                    hText=text(hAxes,...
                        'FontSize',14,...
                        'HitTest','off',...
                        'Color',[.3,.3,.3],...
                        'HorizontalAlignment','center');
                    setappdata(hText,'listener',event.proplistener(hAxes,{hAxes.findprop('XLim'),hAxes.findprop('YLim')},'PostSet',@this.updateHelperTextForLimits));
                    this.HelpText=hText;
                end
                hText.UserData=helpStr;
                updateHelpText(this);
            end
            updateHighlight(this);
            notify(this,'ModeChanged');

            if isAdd
                highlightCanvas(this);
            else
                removeHighlightCanvas(this);
            end
        end

        function set.CurrentSpecification(this,spec)
            if isequal(spec,this.CurrentSpecification)
                return;
            end
            this.CurrentSpecification=spec;
            updateHighlight(this);
            actorProps=this.Application.ActorProperties;
            if~isempty(actorProps)&&~isstruct(actorProps)
                update(actorProps);
            end
            notify(this,'SelectionChanged');
        end

        function index=getRoadIndexFromCenters(this,hRoadCenter)
            index=find(hRoadCenter==this.RoadEditPoints,1,'first');
        end

        function tableData=getTableData(this)
            app=this.Application;
            switch this.InteractionMode
                case{'dragRoad','dragRoadEditPoint','none'}
                    id=this.RoadID;
                    if isempty(id)
                        roadSpec=this.CurrentSpecification;
                        if~isa(roadSpec,'driving.internal.scenarioApp.road.Specification')
                            tableData=[];
                            return;
                        end
                    else
                        roadSpec=app.RoadSpecifications(this.RoadID);
                    end

                    if~isa(roadSpec,'driving.internal.scenarioApp.road.RoadGroupArbitrary')
                        tableData=roadSpec.Centers;
                    else
                        tableData=deriveCenters(roadSpec);
                    end
                    if strcmpi(this.InteractionMode,'dragRoad')
                        tableData=tableData+this.DragOffset;
                    end
                case{'dragBarrier','dragBarrierEditPoint'}
                    id=this.BarrierID;
                    if isempty(id)
                        barrierSpec=this.CurrentSpecification;
                        if~isa(barrierSpec,'driving.internal.scenarioApp.BarrierSpecification')
                            tableData=[];
                            return;
                        end
                    else
                        barrierSpec=app.BarrierSpecifications(this.BarrierID);
                    end

                    tableData=barrierSpec.BarrierCenters;
                    if strcmpi(this.InteractionMode,'dragBarrier')
                        tableData=tableData+this.DragOffset;
                    end
                case{'addRoadCenters','addBarrierCenters'}
                    waypoints=this.Waypoints;
                    tableData=num2cell(waypoints);
                    if~isempty(waypoints)
                        zValue=waypoints(end,3);
                    else
                        zValue=0;
                    end
                    tableData=addEmptiesToTable(this,tableData,zValue);
                case 'addActorWaypoints'
                    tableData=this.Waypoints;
                    actor=app.ActorSpecifications(this.ActorID);
                    if isempty(tableData)
                        tableData=actor.Waypoints;
                        if isempty(tableData)
                            tableData=actor.Position;
                            if~isempty(actor.Speed)
                                tableData(end+1)=actor.Speed;
                            else
                                if app.ActorProperties.AddingReverseMotion
                                    tableData(end+1)=-driving.scenario.Path.DefaultReverseSpeed;
                                else
                                    tableData(end+1)=driving.scenario.Path.DefaultSpeed;
                                end
                            end
                        end
                    end
                    if size(actor.WaitTime,1)>0&&numel(actor.Speed)==1
                        actor.Speed=[actor.Speed;repmat(actor.Speed,size(actor.Waypoints,1)-numel(actor.Speed),1)];
                    end
                    if numel(actor.Speed)>0
                        if size(tableData,2)==3
                            speed=actor.Speed;
                            lastSpeed=speed(find(speed~=0,1,'last'));
                            speed=[speed;repmat(lastSpeed,size(tableData,1)-numel(speed),1)];
                            tableData=[tableData,speed];
                        end
                    end
                    if~isempty(actor.WaitTime)
                        if size(tableData,2)==4
                            waitTime=actor.WaitTime;
                            waitTime=[waitTime;zeros(size(tableData,1)-numel(waitTime),1)];
                            tableData=[tableData,waitTime];
                        end
                    else
                        tableData(:,5)=0;
                    end
                    if~isempty(actor.pWaypointsYaw)
                        if size(tableData,2)==5
                            waypointsYaw=actor.pWaypointsYaw;
                            waypointsYaw=[waypointsYaw;NaN(size(tableData,1)-numel(waypointsYaw),1)];
                            tableData=[tableData,waypointsYaw];
                        end
                    end
                    tableData=addEmptiesToTable(this,num2cell(tableData));
                case{'dragActorWaypoint','dragActorWayline'}
                    actor=app.ActorSpecifications(this.ActorID);
                    tableData=actor.Waypoints;
                    if numel(actor.Speed)>1
                        tableData=[tableData,actor.Speed];
                    end
                    if~isempty(actor.WaitTime)
                        if size(tableData,2)==4
                            waitTime=actor.WaitTime;
                            waitTime=[waitTime;zeros(size(tableData,1)-numel(waitTime),1)];
                            tableData=[tableData,waitTime];
                        end
                    else
                        tableData(:,5)=0;
                    end
                    if~isempty(actor.pWaypointsYaw)
                        if size(tableData,2)==5
                            waypointsYaw=actor.pWaypointsYaw;
                            waypointsYaw=[waypointsYaw;NaN(size(tableData,1)-numel(waypointsYaw),1)];
                            tableData=[tableData,waypointsYaw];
                        end
                    end
                    tableData=num2cell(tableData);
                case 'addRoad'
                    tableData=this.Waypoints;
                    if isempty(tableData)&&~isempty(app.RoadSpecifications)&&~isempty(this.RoadID)
                        tableData=app.RoadSpecifications(this.RoadID).Centers;
                    end
                    if isempty(tableData)
                        zValue=0;
                    else
                        zValue=tableData(end,3);
                    end
                    if~isempty(app.RoadSpecifications)&&~isempty(this.RoadID)&&~isempty(app.RoadSpecifications(this.RoadID).pHeading)
                        if size(tableData,2)==3
                            heading=app.RoadSpecifications(this.RoadID).pHeading;
                            heading=[heading;NaN(size(tableData,1)-numel(heading),1)];
                            tableData=[tableData,heading];
                        end
                    end
                    tableData=addEmptiesToTable(this,num2cell(tableData),zValue);
                case 'addBarrier'
                    tableData=this.Waypoints;
                    if isempty(tableData)&&~isempty(app.BarrierSpecifications)&&~isempty(this.BarrierID)
                        tableData=app.BarrierSpecifications(this.BarrierID).BarrierCenters;
                    end
                    if isempty(tableData)
                        zValue=0;
                    else
                        zValue=tableData(end,3);
                    end
                    tableData=addEmptiesToTable(this,num2cell(tableData),zValue);
                otherwise
                    tableData='';
            end
        end

        function updateForSimulationStateChange(this)
            wayPointsVisible=isStopped(this.Application.Simulator)||this.ShowWaypointsDuringSim;
            set(findobj(this.ActorLines(:,1),'type','line'),'Visible',wayPointsVisible);
        end

        function update(this)
            update@driving.internal.scenarioApp.ScenarioView(this);
            if isempty(this.Figure)||isempty(this.Axes)
                return;
            end


            addButtonDownCallback(this);
            addContextMenus(this);
            updateHighlight(this);
            if strcmp(this.InteractionMode,'addRoadCenters')
                createRoadCentersLine(this);
                updateWaypointLine(this);
            end
            updateEgoIndicator(this);
            fixZLim(this);
        end
        function fixZLim(this)
            allZ=get(findobj([this.RoadPatches(:);this.ActorPatches(:);this.ActorLines(:,2)],'-property','ZData'),'ZData');
            if iscell(allZ)
                allZ=cellfun(@(e)e(:),allZ,'UniformOutput',false);
                allZ=vertcat(allZ{:});
            else
                allZ=allZ(:);
            end
            if isempty(allZ)
                allZ=[-1,1];
            end

            set(this.Axes,'ZLim',100*[min(allZ)/100-1,1+max(allZ)/100]);
        end

        function addContextMenus(this)
            addActorContextMenus(this);

            set(this.RoadPatches,'UIContextMenu',this.RoadContextMenu);
            set(this.RoadEditPoints,'UIContextMenu',this.RoadEditPointsContextMenu);

            set(this.BarrierPatches,'UIContextMenu',this.BarrierContextMenu);
            set(this.BarrierEditPoints,'UIContextMenu',this.BarrierEditPointsContextMenu);
        end

        function addActorContextMenus(this)
            waypoints=this.ActorLines(:,1);
            waylines=this.ActorLines(:,2);
            set(this.ActorPatches,'UIContextMenu',this.ActorContextMenu);
            set(waylines(ishghandle(waylines)),'UIContextMenu',this.WaylineContextMenu);
            set(waypoints(ishghandle(waypoints)),'UIContextMenu',this.WaypointsContextMenu);
        end

        function clearPendingAdd(this)

            delete(this.WaypointLine);
            this.WaypointLine=[];
            this.Waypoints=[];
            this.ActorID='';
        end

        function settingsCallback(this,h,~)
            hMenu=this.SettingsMenu;
            menuTags={'EnableRoadInteractivity','ShowRoadEditPointsDuringSim',...
                'ShowWaypointsDuringSim','ShowPoseIndicatorDuringSim','ShowEgoIndicator'};
            if isempty(hMenu)
                hMenu=uicontextmenu(this.Figure,'Tag','ScenarioSettingsMenu');
                createToggleMenu(this,hMenu,menuTags);
                this.SettingsMenu=hMenu;
            end
            updateToggleMenu(this,menuTags);
            drawnow

            set(hMenu,...
                'Position',h.Position(1:2)+[1,0],...
                'Visible','on');
        end

        function val=canAddWaypoints(this)
            val=false;
            spec=this.CurrentSpecification;
            if isa(spec,'driving.internal.scenarioApp.ActorSpecification')
                info=this.Application.ClassSpecifications.getSpecification(spec.ClassID);
                val=strcmp(this.InteractionMode,'none')&&~isempty(this.ActorID)&&info.isMovable;
            end
        end


        function exitInteractionMode(this)
            app=this.Application;
            if strcmp(this.InteractionMode,'addActor')
                this.InteractionMode='none';
                restoreMousePointer(this);
                enableUndoRedo(app);
            elseif any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters','addBarrier','addMultipleBarriers','addBarrierCenters','addActorWaypoints'}))
                if any(strcmp(this.InteractionMode,{'addBarrier','addBarrierCenters'}))
                    delete(this.RoadEdgeSelect(:));
                    this.RoadEdgeSelect=[];
                    delete(this.BarrierRoads(:));
                    this.BarrierRoads=driving.scenario.Road.empty;
                    this.BarrierRoadEdges={};
                    this.BarrierRoadEdgeLines={};
                end
                delete(this.WaypointLine);
                this.WaypointLine=[];
                this.InteractionMode='none';

                if strcmp(this.InteractionMode,'addActorWaypoints')
                    actor=getActorFromScenario(this);
                    actorSpec=app.ActorSpecifications(this.ActorID);
                    actor.Position=actorSpec.Position;
                end
                update(this);
                restoreMousePointer(this);
                resetCursorLine(this);
                enableUndoRedo(app);
            elseif strcmp(this.InteractionMode,'marqueeSelect')
                set(this.Marquee,'Visible',false);
                this.InteractionMode='none';
            elseif strcmp(this.InteractionMode,'rotateActor')
                actor=app.ActorSpecifications(this.ActorID);
                otherActors=this.CurrentSpecification;
                otherActors(otherActors==actor)=[];
                if~isempty(this.CachedYaw)
                    scenarioActor(1)=getActorFromScenario(this,actor);
                    if~isempty(scenarioActor)
                        scenarioActor(1).Yaw=this.CachedYaw(1);
                        actor.Yaw=this.CachedYaw(1);
                        if~isempty(otherActors)
                            for i=1:numel(otherActors)
                                scenarioActor(i+1)=getActorFromScenario(this,otherActors(i));
                                otherActors(i).Yaw=this.CachedYaw(i+1);
                                scenarioActor(i+1).Yaw=this.CachedYaw(i+1);
                            end
                        end
                    end
                end
                this.CachedYaw=[];
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                this.ShouldDirty=false;
                update(this);
                updateActorRotator(this,actor);
                if~isempty(otherActors)
                    for i=1:numel(otherActors)
                        updateActorRotator(this,otherActors(i));
                    end
                end
                enableUndoRedo(app);

            elseif any(strcmp(this.InteractionMode,{'dragActor','dragActorWayline'}))


                actor=app.ActorSpecifications(this.ActorID);

                if~isempty(this.CachedPosition)
                    scenarioActor=getActorFromScenario(this,actor);
                    if~isempty(scenarioActor)
                        scenarioActor.Position=this.CachedPosition(1,:);
                        actor.Position=this.CachedPosition(1,:);
                        if~isempty(this.CachedWaypoints)
                            actor.Waypoints=this.CachedWaypoints;
                            waitTime=actor.WaitTime;
                            waypointsYaw=actor.WaypointsYaw;
                            if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                                if~isempty(waitTime)
                                    trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,waitTime);
                                else
                                    trajectory(scenarioActor,this.CachedWaypoints,actor.Speed);
                                end
                            else
                                if~isempty(waitTime)
                                    trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                                else
                                    trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,'Yaw',waypointsYaw);
                                end
                            end
                        end
                        if isa(scenarioActor.MotionStrategy,'driving.scenario.Path')
                            actor.pWaypointsYaw=scenarioActor.MotionStrategy.getWaypointsYaw;
                        end
                        addButtonDownCallback(this);
                        addContextMenus(this);
                    end
                end
                this.CachedPosition=[];
                this.CachedWaypoints=[];
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                this.ShouldDirty=false;
                update(this);
                enableUndoRedo(app);
            elseif strcmp(this.InteractionMode,'dragActorWaypoint')


                if~isempty(this.CachedWaypoints)
                    scenarioActor=getActorFromScenario(this);
                    if~isempty(scenarioActor)
                        actor=app.ActorSpecifications(this.ActorID);
                        actor.Waypoints=this.CachedWaypoints;
                        waitTime=actor.WaitTime;
                        waypointsYaw=actor.WaypointsYaw;
                        if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                            if~isempty(waitTime)
                                trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,waitTime);
                            else
                                trajectory(scenarioActor,this.CachedWaypoints,actor.Speed);
                            end
                        else
                            if~isempty(waitTime)
                                trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                            else
                                trajectory(scenarioActor,this.CachedWaypoints,actor.Speed,'Yaw',waypointsYaw);
                            end
                        end
                        if isa(scenarioActor.MotionStrategy,'driving.scenario.Path')
                            actor.pWaypointsYaw=scenarioActor.MotionStrategy.getWaypointsYaw;
                        end
                        addButtonDownCallback(this);
                        addContextMenus(this);
                    end
                end
                this.CachedWaypoints=[];
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                this.ShouldDirty=false;
                update(this);
                enableUndoRedo(app);
            elseif any(strcmp(this.InteractionMode,{'dragRoadEditPoint','dragRoad'}))


                resetRoadOutlines(this);
                resetRoadCenterMarker(this);
                if~isempty(this.RoadEditPointCache)
                    roadSpec=app.RoadSpecifications(this.RoadID);
                    applyPvPairs(roadSpec,this.RoadEditPointCache);
                end
                this.CachedWaypoints=[];
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                this.ShouldDirty=false;
                enableUndoRedo(app);
            end
            clearAllMessages(this);
            this.Waypoints=[];
        end

        function commitRoadEdgeBarrier(this,is_ctrl_click)
            if~isempty(this.BarrierRoads)&&~isempty(this.BarrierRoadEdges)&&...
                    any(strcmp(this.InteractionMode,{'addBarrier','addMultipleBarriers','addBarrierCenters'}))

                hApp=this.Application;
                resetCursorLine(this);

                if is_ctrl_click
                    if~strcmp(this.InteractionMode,'addMultipleBarriers')
                        this.InteractionMode='addMultipleBarriers';
                    end
                else
                    this.InteractionMode='none';
                end

                delete(this.WaypointLine);
                this.WaypointLine=[];
                numBarriers=numel(this.BarrierRoads);
                barriers(1:numBarriers)=driving.internal.scenarioApp.BarrierSpecification;
                if isempty(this.BarrierID)
                    for i=1:numBarriers
                        if isempty(barriers(i).Name)

                            barriers(i)=driving.internal.scenarioApp.BarrierSpecification(this.BarrierRoads(i));
                            barrierProps={'Name','ClassID','Width','Height','Mesh','PlotColor',...
                                'BarrierType','RCSPattern','RCSAzimuthAngles','RCSElevationAngles'};
                            for j=1:numel(barrierProps)
                                barriers(i).(barrierProps{j})=this.CurrentBarrier.(barrierProps{j});
                            end
                        end
                        barriers(i).BarrierCenters=trimBarrierCenters(this.BarrierRoadEdgeLines{i});
                        barriers(i).OriginalBarrierCenters=barriers(i).BarrierCenters;
                        barriers(i).Name=getUniqueName(getBarrierAdder(this.Application),barriers(i).Name);
                        pvPairs=getPvPairsForAddRoad(barriers(i),this.BarrierRoads(i),this.BarrierRoadEdges{i});
                        for indx=1:2:numel(pvPairs)
                            barriers(i).(pvPairs{indx})=pvPairs{indx+1};
                        end
                        applyEdit(hApp,driving.internal.scenarioApp.undoredo.AddBarrier(hApp,barriers(i)));
                    end
                    setDirty(hApp);
                end

                delete(this.RoadEdgeSelect(:));
                this.RoadEdgeSelect=[];

                this.BarrierRoads=driving.scenario.Road.empty;
                this.BarrierRoadEdges={};
                this.BarrierRoadEdgeLines={};

                clearAllMessages(this);
                setStatus(this.Application,'');
            end
        end

        function commitWaypoints(this)

            mode=this.InteractionMode;
            hApp=this.Application;
            resetCursorLine(this);
            if any(strcmp(mode,{'addRoad','addRoadCenters'}))

                this.InteractionMode='none';
                delete(this.WaypointLine);
                this.WaypointLine=[];
                road=this.CurrentRoad;
                nPoints=getNumAddPoints(road);
                if size(this.Waypoints,1)>=nPoints(1)
                    if isempty(this.RoadID)

                        pvPairs=getPvPairsForAddPoints(road,this.Waypoints);
                        for indx=1:2:numel(pvPairs)
                            road.(pvPairs{indx})=pvPairs{indx+1};
                        end
                        applyEdit(hApp,driving.internal.scenarioApp.undoredo.AddRoad(hApp,road));
                        setDirty(hApp);
                    else
                        this.ShouldDirty=true;
                        this.CurrentSpecification=this.CurrentRoad;
                        applyRoadPvPairs(this,getPvPairsForAddPoints(road,this.Waypoints));
                    end
                end

                restoreMousePointer(this);
                enableUndoRedo(hApp);
                clearAllMessages(this);
                this.CurrentRoad=[];
            elseif any(strcmp(mode,{'addBarrier','addBarrierCenters'}))

                this.InteractionMode='none';
                delete(this.WaypointLine);
                this.WaypointLine=[];
                barrier=this.CurrentBarrier;
                nPoints=getNumAddPoints(barrier);
                if size(this.Waypoints,1)>=nPoints(1)
                    if isempty(this.BarrierID)

                        pvPairs=getPvPairsForAddPoints(barrier,this.Waypoints);
                        for indx=1:2:numel(pvPairs)
                            barrier.(pvPairs{indx})=pvPairs{indx+1};
                        end
                        applyEdit(hApp,driving.internal.scenarioApp.undoredo.AddBarrier(hApp,barrier));
                        setDirty(hApp);
                    else
                        this.ShouldDirty=true;
                        this.CurrentSpecification=this.CurrentBarrier;
                        applyBarrierPvPairs(this,getPvPairsForAddPoints(barrier,this.Waypoints));
                    end
                end

                restoreMousePointer(this);
                enableUndoRedo(hApp);
                clearAllMessages(this);
                this.CurrentBarrier=[];
            elseif strcmp(mode,'addActorWaypoints')

                delete(this.WaypointLine);
                this.WaypointLine=[];
                waypoints=this.Waypoints;



                this.InteractionMode='none';
                if size(waypoints,1)>1&&(size(waypoints,2)~=3)
                    edit=driving.internal.scenarioApp.undoredo.AddActorWaypoints(...
                        hApp,hApp.ActorSpecifications(this.ActorID),waypoints);
                    try
                        applyEdit(this.Application,edit);
                    catch E
                        if E.identifier=="driving:scenario:ErrorSmoothTrajectory"
                            undo(edit);
                            hApp.ActorSpecifications(this.ActorID).IsSmoothTrajectory=false;
                            this.errorMessage(E.message,E.identifier);
                        end
                    end
                    setDirty(hApp);
                end

                restoreMousePointer(this);
                update(hApp.ActorProperties);
                enableUndoRedo(hApp);
            end
            resetCursorLine(this);
            this.InteractionMode='none';
        end

        function restoreMousePointer(this)

            if~isempty(this.PreviousMousePointer)
                set(this.Figure,'Pointer','arrow');
                this.PreviousMousePointer=[];
            end
        end

        function alignActorsLeftCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignLeft(ind,first);
        end

        function alignActorsRightCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignRight(ind,first);
        end

        function alignActorsTopCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignTop(ind,first);
        end

        function alignActorsHorizMiddleCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignHorizMiddle(ind,first);
        end

        function alignActorsVertMiddleCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignVertMiddle(ind,first);
        end

        function alignActorsBottomCallback(this,~,~)
            current=this.CurrentSpecification;
            first=this.ActorID;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.alignBottom(ind,first);
        end

        function distributeActorsVertCallback(this,~,~)
            current=this.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.distributeVert(ind);
        end

        function distributeActorsHorizCallback(this,~,~)
            current=this.CurrentSpecification;
            ind=zeros(length(current),1);
            for i=1:length(current)
                ind(i)=current(i).ActorID;
            end
            hApp=this.Application;
            actorAligner=getActorAligner(hApp);
            actorAligner.distributeHoriz(ind);
        end

        function addButtonDownCallback(this)






            set(allchild(this.Axes),'ButtonDownFcn',@this.onButtonDown);
        end

        function[tooltip,cp]=getCursorText(this)
            cp=getCurrentPoint(this);
            tooltip=num2str(cp(1))+","+num2str(cp(2));
        end

        function resetCursorLine(this)

            if~isempty(this.CursorLine)&&isvalid(this.CursorLine)
                set(this.CursorLine,'XData',[],'YData',[],'ZData',[]);
            end
        end

        function updateAddActorWaypointsCursorLine(this,cp)
            if nargin<2
                [~,cp]=getCursorText(this);
            end
            app=this.Application;
            actor=app.ActorSpecifications(this.ActorID);
            if isempty(actor)
                return;
            end
            if isempty(this.Waypoints)
                existingWaypoints=actor.Waypoints;
                if isempty(existingWaypoints)
                    existingWaypoints=actor.Position;
                end
                this.Waypoints=existingWaypoints;
            else
                this.Waypoints(1,1:3)=actor.Position;
            end
            updateCursorLine(this,this.Waypoints,cp);
        end

        function updateCursorLine(this,waypoints,cp)


            hLine=this.CursorLine;
            if size(waypoints,1)>=1
                xd=[waypoints(end,1),cp(1)];
                yd=[waypoints(end,2),cp(2)];
                zd=[waypoints(end,3),cp(3)];
                if isempty(hLine)||~ishghandle(hLine)
                    hLine=line(...
                        'XData',[],...
                        'YData',[],...
                        'ZData',[],...
                        'Parent',getAxes(this),...
                        'Tag','CursorLine',...
                        'PickableParts','none',...
                        'Color',[0,0,0],...
                        'LineStyle','--',...
                        'LineWidth',1);
                    this.CursorLine=hLine;
                end


                offset=driving.scenario.internal.AxesOrientation.getOffset(this.Application.AxesOrientation);
                set(hLine,'XData',xd,'YData',yd,'ZData',zd+0.5*offset);
            elseif ishghandle(hLine)
                set(hLine,'XData',[],'YData',[],'ZData',[]);
            end
        end

        function scenarioActor=getActorFromScenario(this,spec)

            if nargin<2
                id=this.ActorID;
            else
                id=spec.ActorID;
            end
            scenarioActors=this.Application.Scenario.Actors;
            actorIDs=[scenarioActors.ActorID];
            scenarioActor=scenarioActors(actorIDs==id);
        end

        function createRoadCentersLine(this)


            if isempty(this.WaypointLine)||~ishghandle(this.WaypointLine)
                this.WaypointLine=line(...
                    'XData',[],...
                    'YData',[],...
                    'Parent',this.Axes,...
                    'Tag','WaypointLine',...
                    'Marker','o',...
                    'MarkerSize',6,...
                    'HitTest','off',...
                    'MarkerEdgeColor','black',...
                    'LineStyle',':',...
                    'LineWidth',1);
            end
        end

        function createActorWaypointsLine(this,existingWaypoints)


            if isempty(this.WaypointLine)||~ishghandle(this.WaypointLine)
                patchColor=get(this.ActorPatches(this.ActorID),'FaceColor');
                this.WaypointLine=line(...
                    'XData',[],...
                    'YData',[],...
                    'ZData',[],...
                    'Parent',this.Axes,...
                    'Tag','WaypointLine',...
                    'Marker','o',...
                    'MarkerSize',6,...
                    'MarkerEdgeColor',patchColor,...
                    'MarkerFaceColor',patchColor,...
                    'Color',patchColor,...
                    'HitTest','off',...
                    'LineStyle','-',...
                    'LineWidth',0.5);
                if nargin>1
                    actor=this.Application.ActorSpecifications(this.ActorID);
                    speed=actor.Speed;
                    waitTime=actor.WaitTime;
                    pwaypointsYaw=actor.pWaypointsYaw;
                    if numel(speed)>1&&numel(waitTime)>1&&numel(pwaypointsYaw)>1
                        existingWaypoints=[existingWaypoints,speed,waitTime,pwaypointsYaw];
                    else
                        if length(speed)==1
                            speed=repmat(speed,size(existingWaypoints,1),1);
                        end
                        existingWaypoints=[existingWaypoints,speed];
                    end
                    this.Waypoints=existingWaypoints;
                end
            end
        end

        function[type,tag,tagPrefix]=getClickedObjectType(~,clickedObj)



            type='';
            tagPrefix='';
            tag='';
            if isprop(clickedObj,'Type')
                tag=clickedObj.Tag;
                switch clickedObj.Type
                    case 'line'
                        if contains(tag,'WaylineActor')
                            type='actorWayline';
                            tagPrefix='WaylineActor';
                        elseif contains(tag,'WaypointActor')
                            type='actorWaypoint';
                            tagPrefix='WaypointActor';
                        elseif strcmp(tag,'RoadEditPoint')
                            type='roadEditPoint';
                            tagPrefix='RoadEditPoint';
                        elseif strcmp(tag,'BarrierEditPoint')
                            type='barrierEditPoint';
                            tagPrefix='BarrierEditPoint';
                        elseif contains(tag,'Road')
                            type='road';
                            tagPrefix='Road';
                        elseif contains(tag,'RotateLine')
                            type='actor';
                            tag=sprintf('ActorPatch%d',clickedObj.UserData.ActorID);
                            tagPrefix='ActorPatch';
                        end
                    case 'patch'
                        if contains(tag,'ActorPatch')
                            type='actor';
                            tagPrefix='ActorPatch';
                        elseif contains(tag,'PoseIndicator')||contains(tag,'EgoIndicator')
                            type='actor';
                            tag=sprintf('ActorPatch%d',clickedObj.UserData.ActorID);
                            tagPrefix='ActorPatch';
                        elseif contains(tag,'BarrierPatch')
                            type='barrier';
                            tagPrefix='BarrierPatch';
                        elseif contains(tag,'Road')
                            type='road';
                            tagPrefix='RoadTilesPatch';
                        end
                end
            end
        end

        function applyAxesLimits(this,hLim,vLim)



            hAxes=this.Axes;
            hAxes.CameraPositionMode='auto';
            hAxes.CameraTargetMode='auto';

            if vLim(1)>vLim(2)||hLim(1)>hLim(2)||vLim(1)==vLim(2)||...
                    hLim(1)==hLim(2)
                return;
            end
            if abs(vLim(1)-vLim(2))<10*eps(vLim(1))||abs(hLim(1)-hLim(2))<10*eps(hLim(1))
                return;
            end
            center(1)=mean(hLim);
            center(2)=mean(vLim);

            if strcmp(this.VerticalAxis,'X')
                center=fliplr(center);
            end

            pos=getpixelposition(this.Axes);

            hUnitsPerPixel=diff(hLim)/pos(3);
            vUnitsPerPixel=diff(vLim)/pos(4);

            unitsPerPixel=hUnitsPerPixel;
            if vUnitsPerPixel>hUnitsPerPixel
                unitsPerPixel=vUnitsPerPixel;
            end

            setCenterAndUnitsPerPixel(this,center,unitsPerPixel);



            if any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters','addActor','addActorWaypoints'}))&&...
                    strcmp(this.Figure.Pointer,'cross')

                [tooltip,cp]=getCursorText(this);

                updateCursorLine(this,this.Waypoints,cp);
                setTooltipString(this,tooltip);
            end
            updatePoseIndicator(this);
            updateActorRotator(this);
            updateEgoIndicator(this);
        end

        function err=showRoadOutlines(this,roadSpec,offset)



            err='';
            try
                [x,y,z]=rbsToXyz(getRoadBoundaries(roadSpec));
            catch ME
                err=ME.message;
                return;
            end
            if nargin>2
                x=x+offset(1);
                y=y+offset(2);
                z=z+offset(3);
            end
            if isempty(this.RoadOutline)

                hAxes=this.Axes;
                roadBorderColor=[0,0,0];
                this.RoadOutline=line(hAxes,x,y,z,...
                    'Tag','RoadOutlineTemp','Color',roadBorderColor,'LineStyle','--');
            else
                set(this.RoadOutline,'XData',x,'YData',y,'ZData',z);
            end
        end

        function err=showBarrierOutlines(this,barrierSpec,offset)



            err='';
            try
                [x,y,z]=rbsToXyz(getBarrierBoundaries(barrierSpec));
            catch ME
                err=ME.message;
                return;
            end
            if nargin>2
                x=x+offset(1);
                y=y+offset(2);
                z=z+offset(3);
            end
            if isempty(this.BarrierOutline)

                hAxes=this.Axes;
                barrierBorderColor=[0,0,0];
                this.BarrierOutline=line(hAxes,x,y,z,...
                    'Tag','BarrierOutlineTemp','Color',barrierBorderColor,...
                    'LineStyle','--');
            else
                set(this.BarrierOutline,'XData',x,'YData',y,'ZData',z);
            end
        end

        function resetRoadOutlines(this)


            delete(this.RoadOutline(ishghandle(this.RoadOutline)));
            this.RoadOutline=matlab.graphics.primitive.Line.empty;
        end

        function resetBarrierOutlines(this)


            delete(this.BarrierOutline(ishghandle(this.BarrierOutline)));
            this.BarrierOutline=matlab.graphics.primitive.Line.empty;
        end

        function showRoadCenterMarker(this,point)


            if isempty(this.RoadCenterMarker)
                hAxes=this.Axes;
                roadCenterlineColor=[1,1,1];
                roadBorderColor=[0,0,0];
                this.RoadCenterMarker=line(hAxes,point(1),point(2),point(3),...
                    'Tag','RoadCenterMarker','LineStyle','none','Marker','o',...
                    'MarkerFaceColor',roadCenterlineColor,'MarkerEdgeColor',roadBorderColor);
            else
                this.RoadCenterMarker.XData=point(1);
                this.RoadCenterMarker.YData=point(2);
                this.RoadCenterMarker.ZData=point(3);
            end
        end

        function showBarrierCenterMarker(this,point)


            if isempty(this.BarrierCenterMarker)
                hAxes=this.Axes;
                barrierCenterlineColor=[1,1,1];
                barrierBorderColor=[0,0,0];
                this.BarrierCenterMarker=line(hAxes,point(1),point(2),point(3),...
                    'Tag','RoadCenterMarker','LineStyle','none','Marker','o','MarkerSize',3,...
                    'MarkerFaceColor',barrierCenterlineColor,'MarkerEdgeColor',barrierBorderColor);
            else
                this.BarrierCenterMarker.XData=point(1);
                this.BarrierCenterMarker.YData=point(2);
                this.BarrierCenterMarker.ZData=point(3);
            end
        end

        function resetRoadCenterMarker(this)

            delete(this.RoadCenterMarker);
            this.RoadCenterMarker=[];
        end

        function resetBarrierCenterMarker(this)

            delete(this.BarrierCenterMarker);
            this.BarrierCenterMarker=[];
        end

        function updateWaypointLine(this)
            waypoints=this.Waypoints;
            if isempty(waypoints)
                return;
            end
            start=1;
            if any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters'}))&&~isempty(this.RoadID)
                road=this.Application.RoadSpecifications(this.RoadID);
                existingRoadCenters=road.Centers;
                if~isempty(existingRoadCenters)
                    start=size(existingRoadCenters,1);
                end
            elseif any(strcmp(this.InteractionMode,{'addBarrier','addBarrierCenters'}))&&~isempty(this.BarrierID)
                barrier=this.Application.BarrierSpecifications(this.BarrierID);
                existingBarrierCenters=barrier.BarrierCenters;
                if~isempty(existingBarrierCenters)
                    start=size(existingBarrierCenters,1);
                end
            elseif any(strcmp(this.InteractionMode,{'addActorWaypoints'}))&&~isempty(this.ActorID)
                actor=this.Application.ActorSpecifications(this.ActorID);
                existingWaypoints=actor.Waypoints;
                if~isempty(existingWaypoints)
                    start=size(existingWaypoints,1);
                end
            end
            set(this.WaypointLine,'XData',waypoints(start:end,1),'YData',waypoints(start:end,2),'ZData',waypoints(start:end,3));
        end


        function[cp,xUnitsPerPixel,yUnitsPerPixel,N]=getCurrentPoint(this)


            [cp,xUnitsPerPixel,yUnitsPerPixel,N]=getCurrentPoint@matlabshared.application.Canvas(this);


            isZNeeded={'addActor','addActorWaypoints','addBarrierCenters','addMultipleBarriers','dragActor','dragActorWaypoint'};
            if any(strcmp(this.InteractionMode,isZNeeded))&&~isempty(this.Application.RoadSpecifications)



                isPointInRoad=this.Application.RoadSpecifications.findRoadWithPoint(cp);



                if~isempty(isPointInRoad)
                    [cp(3),~,~]=getHeightInClickedPoint(this,cp(1:2));
                    cp(3)=round(cp(3),N);
                end
            end
        end

        function[clickedZ,tileID,isOnSuperTile]=getHeightInClickedPoint(this,point)




            obj=this.Application.Scenario;


            validTiles=[obj.RoadTiles.TileID]~=0;
            validRoadTiles=obj.RoadTiles(validTiles);



            clickedZ=0.01;





            [~,index]=sort(sum((point-obj.RoadTileCentroids(validTiles,1:2)).^2,2));
            tileHit=[];
            heights=[];


            searchNumOfTiles=15;
            searchIntervalVar=50;

            isOnSuperTile=false;

            roadTiles=validRoadTiles(index(1:min(numel(index),searchNumOfTiles)));

            for expandSearchCounter=1:4
                for indx=1:numel(roadTiles)




                    if~isempty(tileHit)&&isAbutting(tileHit(end),roadTiles(indx))
                        continue;
                    end
                    if inpolygon(point(1),point(2),roadTiles(indx).Vertices(:,1),roadTiles(indx).Vertices(:,2))
                        tileHit=[tileHit,roadTiles(indx)];







                        distances=1./sqrt((roadTiles(indx).Vertices(:,1)-point(1)).^2+(roadTiles(indx).Vertices(:,2)-point(2)).^2);

                        weights=distances/sum(distances);
                        currHeight=weights'*roadTiles(indx).Vertices(:,3);
                        heights=[heights,currHeight];

                        if size(roadTiles(indx).Vertices(:,1),1)>4
                            isOnSuperTile=true;
                        end
                    end
                end
                if isempty(tileHit)

                    if(numel(index)>searchNumOfTiles)
                        roadTiles=validRoadTiles(index(searchNumOfTiles+1:min(numel(index),searchNumOfTiles+searchIntervalVar)));
                        searchNumOfTiles=searchNumOfTiles+searchIntervalVar;
                    else
                        break;
                    end
                end
            end

            if isempty(tileHit)
                clickedZ=0;
                tileID=[];
            else

                [maxZ,tileIDindx]=max(heights);
                clickedZ=clickedZ+maxZ;
                if any(isnan(clickedZ))
                    clickedZ=0;
                end
                tileID=tileHit(tileIDindx).TileID;
            end
        end
    end

    methods(Hidden)
        function applyRoadPvPairs(this,pvPairs,varargin)
            hApp=this.Application;
            road=this.CurrentSpecification;
            if isempty(pvPairs)
                return;
            elseif numel(pvPairs)==2
                edit=driving.internal.scenarioApp.undoredo.SetRoadProperty(hApp,...
                    road,pvPairs{:},varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleRoadProperties(hApp,...
                    road,pvPairs(1:2:end),pvPairs(2:2:end));
            end
            applyEdit(hApp,edit);

            if this.ShouldDirty
                hApp.setDirty;
                this.ShouldDirty=false;
            end
        end

        function applyBarrierPvPairs(this,pvPairs,varargin)
            hApp=this.Application;
            barrier=this.CurrentSpecification;
            pvPairs=addRoadToBarrierPVPair(pvPairs,barrier);
            if isempty(pvPairs)
                return;
            elseif numel(pvPairs)==2
                edit=driving.internal.scenarioApp.undoredo.SetBarrierProperty(hApp,...
                    barrier,pvPairs{:},varargin{:});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleBarrierProperties(hApp,...
                    barrier,pvPairs(1:2:end),pvPairs(2:2:end));
            end

            applyEdit(hApp,edit);

            if this.ShouldDirty
                hApp.setDirty;
                this.ShouldDirty=false;
            end
        end

        function onFocus(this)
            this.Application.MostRecentCanvas='scenario';
        end

        function onAxesContextMenu(this,h,~)
            happ=this.Application;
            if happ.IsLoading
                return;
            end

            this.ClickLocation=getCurrentPoint(this);

            enableInteractivity=findobj(h,'Tag','ScenarioCanvas.EnableRoadInteractivity');
            addRoad=findobj(h,'Tag','AddRoad');
            pasteItem=findobj(h,'Tag','PasteItem');
            if isempty(addRoad)
                pasteItem=uimenu(h,...
                    'Tag','PasteItem',...
                    'Label',getString(message('Spcuilib:application:Paste')),...
                    'Callback',@this.pasteCallback);
                enableInteractivity=createToggleMenu(this,h,...
                    'EnableRoadInteractivity','Separator','on');
                addRoad=createMenu(h,'AddRoad',@this.addRoadCallback,'Separator','on');
                drawnow;
            end

            this.setRoadInteractivityContextMenu(enableInteractivity);

            if isStopped(happ.Simulator)
                enab='on';
            else
                enab='off';
            end
            if isPasteMenuEnabled(this)
                pasteEnab=enab;
            else
                pasteEnab='off';
            end
            pasteItem.Enable=pasteEnab;


            if~isAddRoadEnabled(this)
                addRoad.Enable=enab;
            else
                addRoad.Enable='off';
            end

            updateActorMenus(this,h);
            this.ClickIndexStale=true;
        end

        function addWaypoints=createActorContextMenus(this,h)
            addWaypoints=createMenu(h,'AddWaypoints',@this.addWaypointsCallback);
            createMenu(h,'AddReverseWaypoints',@this.addReverseWaypointsCallback);
            createClearWaypointsMenu(this,h);
            createMenu(h,'RestoreDefaultYaws',@this.restoreDefaultYawsCallback);
            createCutCopyPasteDeleteMenus(this.Application,h,this);
            alignActors=uimenu(h,'Tag','AlignActors','Label','Align Actors');
            distributeActors=uimenu(h,'Tag','DistributeActors','Label','Distribute Actors');

            createMenu(alignActors,'AlignLeft',@this.alignActorsLeftCallback,'Label','Align Left');
            createMenu(alignActors,'AlignRight',@this.alignActorsRightCallback,'Label','Align Right');
            createMenu(alignActors,'AlignVertCent',@this.alignActorsVertMiddleCallback,'Label','Align Vertical Center');
            createMenu(alignActors,'AlignTop',@this.alignActorsTopCallback,'Label','Align Top');
            createMenu(alignActors,'AlignBottom',@this.alignActorsBottomCallback,'Label','Align Bottom');
            createMenu(alignActors,'AlignHorizCent',@this.alignActorsHorizMiddleCallback,'Label','Align Horizontal Center');

            createMenu(distributeActors,'DistributeVert',@this.distributeActorsVertCallback,'Label','Distribute Vertically');
            createMenu(distributeActors,'DistributeHoriz',@this.distributeActorsHorizCallback,'Label','Distribute Horizontally');
        end

        function onActorContextMenu(this,h,~)
            if this.Application.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end
            addWaypoints=findobj(h,'Tag','AddWaypoints');
            if isempty(addWaypoints)
                addWaypoints=createActorContextMenus(this,h);
                drawnow;
            end
            addReverseWaypoints=findobj(h,'Tag','AddReverseWaypoints');
            alignActors=findobj(h,'Tag','AlignActors');
            distributeActors=findobj(h,'Tag','DistributeActors');
            clearWaypoints=findobj(h,'Tag','ClearWaypoints');
            restoreDefaultYaws=findobj(h,'Tag','RestoreDefaultYaws');
            [cutActor,copyActor,pasteItem,deleteActor]=findCutCopyPasteDeleteMenus(h);

            if length(this.CurrentSpecification)==2
                alignEnab='on';
                distEnab='off';
            elseif length(this.CurrentSpecification)>2
                alignEnab='on';
                distEnab='on';
            else
                alignEnab='off';
                distEnab='off';
            end

            alignActors.Enable=alignEnab;
            distributeActors.Enable=distEnab;

            actors=this.Application.ActorSpecifications;
            spec=actors(index);
            if(isempty(this.CurrentSpecification))||~(numel(this.CurrentSpecification)>1)
                this.CurrentSpecification=spec;
            end
            enab='off';
            clearEnab='off';
            if shouldEnableContextMenus(this,actors)
                enab='on';
                if~all(cellfun(@isempty,{this.CurrentSpecification.Waypoints}))
                    clearEnab='on';
                end
            end
            if getProperty(this.Application.ClassSpecifications,spec.ClassID,'isMovable')&&(numel(this.CurrentSpecification)==1)
                addEnab=enab;
            else
                addEnab='off';
            end
            set([deleteActor,cutActor,copyActor],'Enable',enab);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));
            addWaypoints.Enable=addEnab;
            addReverseWaypoints.Enable=addEnab;
            clearWaypoints.Enable=clearEnab;
            wYawNaN=cellfun(@isnan,{this.CurrentSpecification.WaypointsYaw},'UniformOutput',false);
            wYawEmpty=cellfun(@isempty,{this.CurrentSpecification.WaypointsYaw});
            if~all(wYawEmpty)&&any(cellfun(@any,wYawNaN))
                restoreDefaultYaws.Enable='on';
            else
                restoreDefaultYaws.Enable='off';
            end
            this.ClickIndexStale=true;
        end

        function onWaylineContextMenu(this,h,~)
            if this.Application.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end

            actors=this.Application.ActorSpecifications;
            this.CurrentSpecification=actors(index);

            addWaypoint=findobj(h,'Tag','AddWaypoint');
            addWaypoints=findobj(h,'Tag','AddWaypoints');
            addReverseWaypoints=findobj(h,'Tag','AddReverseWaypoints');
            clearWaypoints=findobj(h,'Tag','ClearWaypoints');
            [cutActor,copyActor,pasteItem,deleteActor]=findCutCopyPasteDeleteMenus(h);
            if isempty(addWaypoint)
                addWaypoint=createMenu(h,'AddWaypoint',@this.addWaypointCallback);
                addWaypoints=createMenu(h,'AddWaypoints',@this.addWaypointsCallback);
                addReverseWaypoints=createMenu(h,'AddReverseWaypoints',@this.addReverseWaypointsCallback);
                clearWaypoints=createClearWaypointsMenu(this,h);
                [cutActor,copyActor,pasteItem,deleteActor]=createCutCopyPasteDeleteMenus(this.Application,h,this);
                drawnow;
            end
            if shouldEnableContextMenus(this,actors)
                enab='on';
            else
                enab='off';
            end
            set([addWaypoint,addWaypoints,addReverseWaypoints,clearWaypoints,cutActor,copyActor,deleteActor],'Enable',enab);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));
            this.ClickIndexStale=true;
        end

        function onWaypointsContextMenu(this,h,~)
            if this.Application.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end


            restoreYawEnable='off';
            if shouldEnableContextMenus(this,this.Application.ActorSpecifications)
                enab='on';
                hApp=this.Application;
                actor=hApp.ActorSpecifications(this.ClickIndex);
                waypoints=actor.Waypoints;
                restoreIndex=actor.findClosestIndex(waypoints,this.InitialPoint);
                waypointsYaw=actor.WaypointsYaw;
                if~isempty(waypointsYaw)&&~isnan(waypointsYaw(restoreIndex))
                    restoreYawEnable='on';
                else
                    restoreYawEnable='off';
                end
            else
                enab='off';
            end
            deleteWaypoint=findobj(h,'Tag','DeleteWaypoint');
            addWaypoints=findobj(h,'Tag','AddWaypoints');
            addReverseWaypoints=findobj(h,'Tag','AddReverseWaypoints');
            clearWaypoints=findobj(h,'Tag','ClearWaypoints');
            restoreDefaultYaw=findobj(h,'Tag','RestoreDefaultYaw');
            if isempty(deleteWaypoint)
                deleteWaypoint=createMenu(h,'DeleteWaypoint',@this.deleteWaypointCallback);
                addWaypoints=createMenu(h,'AddWaypoints',@this.addWaypointsCallback);
                addReverseWaypoints=createMenu(h,'AddReverseWaypoints',@this.addReverseWaypointsCallback);
                clearWaypoints=createClearWaypointsMenu(this,h);
                restoreDefaultYaw=createMenu(h,'RestoreDefaultYaw',@this.restoreDefaultYawCallback);
                drawnow
            end
            set([deleteWaypoint,addWaypoints,addReverseWaypoints,clearWaypoints],'Enable',enab);
            restoreDefaultYaw.Enable=restoreYawEnable;
        end

        function onBarrierContextMenu(this,~,~)
            app=this.Application;
            if app.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end

            h=this.BarrierContextMenu;

            barriers=this.Application.BarrierSpecifications;
            currentBarrier=barriers(index);
            this.CurrentSpecification=currentBarrier;
            schema=getBarrierContextMenuSchema(currentBarrier,this.ClickLocation);
            delete(this.CustomBarrierContextMenus);
            menus=[];
            sim=app.Simulator;
            if isempty(sim)
                stopped=true;
            else
                stopped=isStopped(app.Simulator);
            end
            for indx=1:numel(schema)
                sc=schema(indx);
                enab=sc.enable;
                if~stopped
                    enab='off';
                end
                menus(indx)=createMenu(h,sc.tag,@this.barrierContextMenuCallback,...
                    'Label',sc.label,...
                    'UserData',sc.callback,...
                    'Enable',enab,...
                    'Position',indx);
            end
            this.CustomBarrierContextMenus=menus;

            [cutBarrier,copyBarrier,pasteItem,deleteBarrier,~,addBarrierCenter]=findCutCopyPasteDeleteMenus(h);

            barriers=this.Application.BarrierSpecifications;
            this.CurrentSpecification=barriers(index);
            if isempty(cutBarrier)
                [cutBarrier,copyBarrier,pasteItem,deleteBarrier]=createCutCopyPasteDeleteMenus(this.Application,h,this);
                pasteItem.Callback=@this.pasteCallback;
            end

            drawnow
            cutBarrier.Separator=~isempty(schema);
            shouldEnable=shouldEnableContextMenus(this,barriers);
            set([cutBarrier,copyBarrier],'Enable',shouldEnable);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));
            set(deleteBarrier,'Enable',shouldEnable);

            if~isempty(addBarrierCenter)
                addBarrierCenter.Enable=shouldEnable&&shouldEnableAddBarrierCenter(this.CurrentSpecification);
            end

            this.ClickIndexStale=true;
        end

        function onBarrierEditPointsContextMenu(this,h,~)
            if this.Application.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end

            barriers=this.Application.BarrierSpecifications;
            this.CurrentSpecification=barriers(index);
            schema=getEditPointContextMenuSchema(barriers(index),this.BarrierEditPointId);
            delete(this.CustomEditPointContextMenus);
            for indx=1:numel(schema)
                sc=schema(indx);
                menus(indx)=createMenu(h,sc.tag,@this.editBarrierPointContextMenuCallback,...
                    'Label',sc.label,...
                    'UserData',sc.callback,...
                    'Enable',sc.enable,...
                    'Position',indx);
            end
            this.CustomEditPointContextMenus=menus;

            [cutBarrier,copyBarrier,pasteItem,deleteBarrier]=findCutCopyPasteDeleteMenus(h);
            if isempty(cutBarrier)
                [cutBarrier,copyBarrier,pasteItem,deleteBarrier]=createCutCopyPasteDeleteMenus(this.Application,h,this);
            end


            drawnow

            deleteBarrierEnab='off';

            if shouldEnableContextMenus(this,barriers)
                deleteBarrierEnab='on';
            end

            set(deleteBarrier,'Enable',deleteBarrierEnab);
            set([cutBarrier,copyBarrier],'Enable',deleteBarrierEnab);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));

            this.ClickIndexStale=true;
        end

        function onRoadContextMenu(this,~,~)
            app=this.Application;
            if app.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end

            h=this.RoadContextMenu;

            roads=this.Application.RoadSpecifications;
            currentRoad=roads(index);
            this.CurrentSpecification=currentRoad;
            schema=getRoadContextMenuSchema(currentRoad,this.ClickLocation);
            delete(this.CustomRoadContextMenus);
            menus=[];
            stopped=isStopped(app.Simulator);
            for indx=1:numel(schema)
                sc=schema(indx);
                enab=sc.enable;
                if~stopped
                    enab='off';
                end
                menus(indx)=createMenu(h,sc.tag,@this.roadContextMenuCallback,...
                    'Label',sc.label,...
                    'UserData',sc.callback,...
                    'Enable',enab,...
                    'Position',indx);
            end
            this.CustomRoadContextMenus=menus;

            [cutRoad,copyRoad,pasteItem,deleteRoad,addRoadCenter]=findCutCopyPasteDeleteMenus(h);
            enableInteractivity=findobj(h,'Tag','ScenarioCanvas.EnableRoadInteractivity');

            if isempty(cutRoad)
                [cutRoad,copyRoad,pasteItem,deleteRoad]=createCutCopyPasteDeleteMenus(this.Application,h,this);
                pasteItem.Callback=@this.pasteCallback;
                enableInteractivity=createToggleMenu(this,h,...
                    'EnableRoadInteractivity','Separator','on');
            end

            drawnow

            cutRoad.Separator=~isempty(schema);
            shouldEnable=this.EnableRoadInteractivity&&shouldEnableContextMenus(this,roads);
            set([cutRoad,copyRoad],'Enable',shouldEnable);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));
            set(deleteRoad,'Enable',shouldEnable);
            if isa(currentRoad,'driving.internal.scenarioApp.road.OpenDRIVEArbitrary')
                isRoadCenterEnable=IsEnableLanes(this.CurrentSpecification);
                set(addRoadCenter,'Enable',isRoadCenterEnable);
            end

            if~isempty(addRoadCenter)
                addRoadCenter.Enable=shouldEnable&&shouldEnableAddRoadCenter(this.CurrentSpecification);
            end

            this.setRoadInteractivityContextMenu(enableInteractivity);

            updateActorMenus(this,h,true);
            this.ClickIndexStale=true;
        end

        function onRoadEditPointsContextMenu(this,h,~)
            if this.Application.IsLoading
                return;
            end

            index=determineClickIndexForContextMenu(this);
            if isempty(index)||isnan(index)
                return;
            end

            roads=this.Application.RoadSpecifications;
            this.CurrentSpecification=roads(index);
            schema=getEditPointContextMenuSchema(roads(index),this.RoadEditPointId);
            delete(this.CustomEditPointContextMenus);
            if~isempty(schema)
                for indx=1:numel(schema)
                    sc=schema(indx);
                    menus(indx)=createMenu(h,sc.tag,@this.editPointContextMenuCallback,...
                        'Label',sc.label,...
                        'UserData',sc.callback,...
                        'Enable',sc.enable,...
                        'Position',indx);
                end
                this.CustomEditPointContextMenus=menus;
            end
            [cutRoad,copyRoad,pasteItem,deleteRoad]=findCutCopyPasteDeleteMenus(h);
            if isempty(cutRoad)
                [cutRoad,copyRoad,pasteItem,deleteRoad]=createCutCopyPasteDeleteMenus(this.Application,h,this);
            end


            drawnow

            deleteRoadEnab='off';

            if shouldEnableContextMenus(this,roads)
                deleteRoadEnab='on';
            end

            set(deleteRoad,'Enable',deleteRoadEnab);
            set([cutRoad,copyRoad],'Enable',deleteRoadEnab);
            set(pasteItem,'Enable',isPasteMenuEnabled(this));

            updateActorMenus(this,h,true);
            this.ClickIndexStale=true;
        end

        function setRoadInteractivityContextMenu(this,hMenu)
            if this.EnableRoadInteractivity
                hMenu.Label=getString(message('driving:scenarioApp:DisableRoadInteractivityContextMenuLabel'));
            else
                hMenu.Label=getString(message('driving:scenarioApp:EnableRoadInteractivityContextMenuLabel'));
            end
            hMenu.Checked='off';
        end

        function roadContextMenuCallback(this,h,~)
            road=this.CurrentSpecification;
            try
                h.UserData(road,this,this.ClickLocation);
            catch me
                errorMessage(this,me.message,me.identifier);
            end
        end

        function barrierContextMenuCallback(this,h,~)
            barrier=this.CurrentSpecification;
            try
                h.UserData(barrier,this,this.ClickLocation);
            catch me
                errorMessage(this,me.message,me.identifier);
            end
        end

        function editPointContextMenuCallback(this,h,~)
            road=this.CurrentSpecification;
            try
                h.UserData(road,this,this.RoadEditPointId);
            catch me
                errorMessage(this,me.message,me.identifier);
            end
        end

        function editBarrierPointContextMenuCallback(this,h,~)
            barrier=this.CurrentSpecification;
            try
                h.UserData(barrier,this,this.BarrierEditPointId);
            catch me
                errorMessage(this,me.message,me.identifier);
            end
        end

        function elevatedRoadJunctionTimerCallback(this,~)
            this.warningMessage(getString(message('driving:scenarioApp:RoadJunctionHeightCalculationWarning')),'RoadJunctionHeightCalculationWarning','FontSize',10);
            drawnow
            t=timer('StartDelay',8.0,...
                'Tag','RoadJunctionInvalidHeight',...
                'TimerFcn',@this.dismissElevatedRoadJunctionTimerCallback,...
                'StopFcn',@this.dismissElevatedRoadJunctionTimerCallback);
            start(t);

        end

        function dismissElevatedRoadJunctionTimerCallback(this,t,~)
            try
                matlabshared.application.deleteTimer(t);
                this.removeMessage('RoadJunctionHeightCalculationWarning');
            catch
            end
        end

        function clearWaypoints=createClearWaypointsMenu(this,h)
            clearWaypoints=createMenu(h,'ClearWaypoints',@this.clearWaypointsCallback);
        end

        function b=shouldEnableContextMenus(this,specifications)
            if~isempty(this.CurrentSpecification)
                if isa(this.CurrentSpecification,'driving.internal.scenarioApp.ActorSpecification')
                    if~ismember(this.ClickIndex,[this.CurrentSpecification.ActorID])
                        index=this.ClickIndex;
                    else
                        index=[this.CurrentSpecification.ActorID];
                    end
                else
                    index=this.ClickIndex;
                end
            else
                index=this.ClickIndex;
            end
            b=~isempty(index)&&all(~isnan(index));
            if b
                this.CurrentSpecification=specifications(index);
                b=b&&isStopped(this.Application.Simulator);
            end
        end

        function index=determineClickIndexForContextMenu(this)
            if this.ClickIndexStale
                this.ClickLocation=getCurrentPoint(this);
                index=determineClickIndex(this);
            else
                index=this.ClickIndex;
            end
        end

        function index=determineClickIndex(this,hsrc,position)
            if nargin<2
                hsrc=hittest(this.Figure);
            end
            if nargin<3
                position=this.ClickLocation;
            end
            [index,this.RoadEditPointId,this.BarrierEditPointId]=graphicalObjectToIndex(this,hsrc,position);
            this.ClickIndex=index;
            this.ClickIndexStale=false;
        end

        function b=canAddRoadCenter(this)
            location=this.ClickLocation;

            hApp=this.Application;
            roadSpec=hApp.RoadSpecifications(this.ClickIndex);

            [centers,pointIndex]=insertIntoClothoid(roadSpec.Centers,location);
            bankAngle=roadSpec.BankAngle;
            if numel(bankAngle)>1
                bankAngle=calculateBankAngleVector(bankAngle,pointIndex);
            end
            b=isempty(driving.internal.scenarioApp.road.Arbitrary.validateCenters(centers,roadSpec.Width,bankAngle));
        end

        function b=isPasteMenuEnabled(this)
            app=this.Application;
            buffer=app.CopyPasteBuffer;
            b=isPasteEnabled(app)&&...
                (isa(buffer,'driving.internal.scenarioApp.ActorSpecification')||...
                isa(buffer,'driving.internal.scenarioApp.BarrierSpecification')||...
                isa(buffer,'driving.internal.scenarioApp.road.Specification'));
        end

        function b=isAddRoadEnabled(this)
            app=this.Application;
            b=app.Scenario.IsOpenDRIVERoad;
        end

        function addWaypointCallback(this,~,~)
            actorIndex=this.ClickIndex;

            actorSpec=this.Application.ActorSpecifications(actorIndex);
            [waypoints,pointIndex]=actorSpec.insertIntoClothoid(actorSpec.Waypoints,this.ClickLocation,actorSpec.Speed);


            if~isempty(this.Application.RoadSpecifications)&&~isempty(this.Application.RoadSpecifications.findRoadWithPoint(waypoints(pointIndex+1,1:2)))
                waypoints(pointIndex+1,3)=round(getHeightInClickedPoint(this,waypoints(pointIndex+1,1:2)),1);
            end


            speed=actorSpec.Speed;
            params={'Waypoints'};
            values={waypoints};

            if numel(speed)>1
                if pointIndex==numel(speed)
                    speed=[speed;speed(end)];
                else
                    speed=[speed(1:pointIndex);(speed(pointIndex)+speed(pointIndex+1))/2;speed(pointIndex+1:end)];
                end
                params=[params,{'Speed'}];
                values=[values,{speed}];
            end


            waitTime=actorSpec.WaitTime;
            if~isempty(waitTime)
                if pointIndex==numel(waitTime)
                    waitTime=[waitTime;0];
                else
                    waitTime=[waitTime(1:pointIndex);0;waitTime(pointIndex+1:end)];
                end
                params=[params,{'WaitTime'}];
                values=[values,{waitTime}];
            end


            waypointsYaw=actorSpec.WaypointsYaw;
            if~isempty(waypointsYaw)
                if pointIndex==numel(waypointsYaw)
                    waypointsYaw=[waypointsYaw;NaN];
                else
                    waypointsYaw=[waypointsYaw(1:pointIndex);NaN;waypointsYaw(pointIndex+1:end)];
                end
                params=[params,{'WaypointsYaw'}];
                values=[values,{waypointsYaw}];
            end

            hApp=this.Application;

            if numel(params)==1
                edit=driving.internal.scenarioApp.undoredo.SetActorProperty(hApp,actorSpec,params{1},values{1});
            else
                edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actorSpec,params,values);
            end
            applyEdit(hApp,edit);
            hApp.setDirty;
        end

        function addRoadCallback(this,~,~)
            addViaWaypoints(getRoadAdder(this.Application),...
                driving.internal.scenarioApp.road.Arbitrary(this.ClickLocation));
        end

        function addBarrierCallback(this,classSpec,~)

            spec=driving.internal.scenarioApp.BarrierSpecification(this.ClickLocation);
            spec.initializePropertiesFromClassSpecification(classSpec);
            addViaWaypoints(getBarrierAdder(this.Application),spec);
        end

        function addBarrierToRoadCallback(this,classSpec,roadEdge)

            if this.Application.Scenario.UpdateRoadIntersectionsForBarriers
                getRoadIntersectionPointsFromMergedTiles(this.Application.Scenario);
            end

            roadID=find(this.Application.RoadSpecifications==this.CurrentSpecification);
            scenario=this.Application.Scenario;
            roadObj=driving.scenario.Road(scenario.RoadSegments(roadID));

            availableRoadEdgeLines=findAvailableSegmentsForRoadEdge(this,roadObj,roadEdge);
            if~isempty(availableRoadEdgeLines)
                for i=1:numel(availableRoadEdgeLines)

                    spec=driving.internal.scenarioApp.BarrierSpecification(roadObj);
                    spec.RoadEdge=roadEdge;
                    spec.initializePropertiesFromClassSpecification(classSpec);
                    spec.OriginalBarrierCenters=trimBarrierCenters(availableRoadEdgeLines{i});

                    spec.Name=getUniqueName(getBarrierAdder(this.Application),spec.Name);

                    hApp=this.Application;
                    applyEdit(hApp,driving.internal.scenarioApp.undoredo.AddBarrier(hApp,spec));
                end
                setDirty(hApp);
            else

                id='driving:scenarioApp:RoadEdgeContainsBarriers';
                errorMessage(this,getString(message(id)),id);
                return;
            end
        end

        function deleteWaypointCallback(this,~,~)

            hApp=this.Application;
            actor=hApp.ActorSpecifications(this.ClickIndex);
            waitTime=actor.WaitTime;
            waypoints=actor.Waypoints;
            speed=actor.Speed;
            waypointsYaw=actor.WaypointsYaw;
            pWaypointsYaw=actor.pWaypointsYaw;

            deleteIndex=actor.findClosestIndex(waypoints,this.InitialPoint);


            if~isempty(speed)&&numel(speed)>1
                testSpeed=speed;
                testSpeed(deleteIndex)=[];
                try
                    driving.scenario.Path.validateSpeed(testSpeed);
                catch E
                    errorMessage(this,E.message,E.identifier);
                    return;
                end
            end
            waypoints(deleteIndex,:)=[];
            if size(waypoints,1)>1
                dupes=actor.findDuplicateWaypoints(waypoints);
                waypoints(dupes,:)=[];
                if~isempty(waitTime)
                    waitTime(deleteIndex,:)=[];


                    waitTime(dupes-1,:)=[];
                end
                if~isempty(waypointsYaw)
                    waypointsYaw(deleteIndex,:)=[];
                    waypointsYaw(dupes-1,:)=[];
                end
                if~isempty(pWaypointsYaw)
                    pWaypointsYaw(deleteIndex,:)=[];
                    pWaypointsYaw(dupes-1,:)=[];
                end
            end
            if size(waypoints,1)==1
                waypoints=[];
                speed=speed(1);
                waitTime=[];
                waypointsYaw=[];
                pWaypointsYaw=[];
            end

            if numel(speed)==1
                if isempty(waitTime)
                    if isempty(waypointsYaw)&&isempty(pWaypointsYaw)
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','pWaypointsYaw'},{waypoints,speed,pWaypointsYaw});
                    else
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','WaypointsYaw','pWaypointsYaw','Speed'},{waypoints,waypointsYaw,pWaypointsYaw,speed});
                    end
                else
                    if isempty(waypointsYaw)&&isempty(pWaypointsYaw)
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','Waypoints','WaitTime','pWaypointsYaw'},{waypoints,speed,waypoints,waitTime,pWaypointsYaw});
                    else
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','Waypoints','WaitTime','Waypoints','WaypointsYaw','Waypoints','pWaypointsYaw'},...
                            {waypoints,speed,waypoints,waitTime,waypoints,waypointsYaw,waypoints,pWaypointsYaw});
                    end
                end
            else
                speed(deleteIndex)=[];
                speed(dupes-1)=[];
                if isempty(waitTime)
                    if isempty(waypointsYaw)&&isempty(pWaypointsYaw)
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,{'Waypoints','Speed'},{waypoints,speed});
                    else
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','Waypoints','WaypointsYaw','Waypoints','pWaypointsYaw'},...
                            {waypoints,speed,waypoints,waypointsYaw,waypoints,pWaypointsYaw});
                    end
                else
                    if isempty(waypointsYaw)&&isempty(pWaypointsYaw)
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','Waypoints','WaitTime'},{waypoints,speed,waypoints,waitTime});
                    else
                        edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(hApp,actor,...
                            {'Waypoints','Speed','Waypoints','WaitTime','Waypoints','WaypointsYaw','Waypoints','pWaypointsYaw'},...
                            {waypoints,speed,waypoints,waitTime,waypoints,waypointsYaw,waypoints,pWaypointsYaw});
                    end
                end
            end

            applyEdit(hApp,edit);
            hApp.setDirty;
        end

        function clearWaypointsCallback(this,~,~)
            hApp=this.Application;
            actor=[];
            for i=1:numel(this.CurrentSpecification)
                if~isempty(this.CurrentSpecification(i).Waypoints)
                    actor=[actor,this.CurrentSpecification(i)];
                end
            end
            nProps=cell(numel(actor),8);

            for iObj=1:numel(actor)
                nProps{iObj,1}=[];
                nProps{iObj,2}=actor(iObj).Speed(1);
                nProps{iObj,3}=[];
                nProps{iObj,4}=[];
                nProps{iObj,5}=[];
                nProps{iObj,6}=0;
                nProps{iObj,7}=Inf;
                nProps{iObj,8}=0;
            end

            applyEdit(hApp,driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                hApp,actor,{'Waypoints','Speed','WaitTime','WaypointsYaw','pWaypointsYaw',...
                'EntryTime','ExitTime','Yaw'},nProps));
            hApp.setDirty;
            notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actor,'Waypoints'));
        end

        function restoreDefaultYawCallback(this,~,~)
            hApp=this.Application;
            actor=hApp.ActorSpecifications(this.ClickIndex);
            waypoints=actor.Waypoints;
            restoreIndex=actor.findClosestIndex(waypoints,this.InitialPoint);
            waypointsYaw=actor.WaypointsYaw;
            if~isempty(waypointsYaw)
                waypointsYaw(restoreIndex)=NaN;
                edit=driving.internal.scenarioApp.undoredo.SetActorProperty(hApp,actor,'WaypointsYaw',waypointsYaw);
                applyEdit(hApp,edit);
                hApp.setDirty;
            end
        end

        function restoreDefaultYawsCallback(this,~,~)
            hApp=this.Application;
            actor=[];
            for i=1:numel(this.CurrentSpecification)
                if~isempty(this.CurrentSpecification(i).WaypointsYaw)
                    actor=[actor,this.CurrentSpecification(i)];
                end
            end
            edit=driving.internal.scenarioApp.undoredo.SetActorProperty(hApp,actor,'WaypointsYaw',[]);
            applyEdit(hApp,edit);
            hApp.setDirty;
        end

        function performDoubleClickOnRoad(this)

            hApp=this.Application;
            index=this.ClickIndex;
            if isempty(index)||isnan(index)
                return
            end
            roadSpec=hApp.RoadSpecifications(this.ClickIndex);
            try
                pvPairs=getPvPairsForDoubleClick(roadSpec,this.ClickLocation);
            catch ME
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            applyRoadPvPairs(this,pvPairs);
        end

        function performDoubleClickOnBarrier(this)

            hApp=this.Application;
            index=this.ClickIndex;
            if isempty(index)||isnan(index)
                return
            end
            barrierSpec=hApp.BarrierSpecifications(this.ClickIndex);
            try
                pvPairs=getPvPairsForDoubleClick(barrierSpec,this.ClickLocation);
            catch ME
                errorMessage(this,ME.message,ME.identifier);
                return;
            end
            applyBarrierPvPairs(this,pvPairs);
        end

        function deleteCallback(this,~,~)
            designer=this.Application;
            spec=this.CurrentSpecification;
            if isa(spec,'driving.internal.scenarioApp.road.Specification')
                edit=driving.internal.scenarioApp.undoredo.DeleteRoad(designer,this.ClickIndex);
            elseif isa(spec,'driving.internal.scenarioApp.BarrierSpecification')
                edit=driving.internal.scenarioApp.undoredo.DeleteBarrier(designer,this.ClickIndex);
            else
                edit=driving.internal.scenarioApp.undoredo.DeleteActor(designer,[spec.ActorID]);
            end
            applyEdit(designer,edit);
        end

        function pasteCallback(this,~,~)
            pasteItem(this.Application,this.ClickLocation);
        end

        function updateActorMenus(this,h,isRoadMenu)
            if nargin<3
                isRoadMenu=false;
            end
            hMenus=h.UserData;
            classes=this.Application.ClassSpecifications;
            allIds=getAllIds(classes);
            vehicles=[];
            others=[];
            barriers=[];

            for id=allIds
                spec=getSpecification(classes,id);
                if spec.isVehicle
                    vehicles=[vehicles,spec];%#ok<*AGROW>
                elseif~strcmp(spec.BarrierType,'None')
                    barriers=[barriers,spec];
                else
                    others=[others,spec];
                end
            end

            menuIndex=1;


            addActorCategory(vehicles);
            addActorCategory(others);
            addActorCategory(barriers);

            delete(hMenus(menuIndex:end));
            hMenus(menuIndex:end)=[];
            set(h,'UserData',hMenus);

            if isStopped(this.Application.Simulator)
                enab='on';
            else
                enab='off';
            end
            set(hMenus,'Enable',enab);


            function addActorCategory(specs)
                sep='on';
                for indx=1:numel(specs)
                    spec=specs(indx);

                    if menuIndex>numel(hMenus)
                        if strcmp(spec.BarrierType,'None')
                            hMenus(menuIndex)=uimenu(h,'Callback',@this.addActorCallback);
                        elseif isRoadMenu
                            hMenus(menuIndex)=uimenu(h);
                            addLeft=createMenu(hMenus(menuIndex),'AddLeft',...
                                matlabshared.application.makeCallback(@this.addBarrierToRoadCallback,spec,'left'),...
                                'Separator','on');
                            addRight=createMenu(hMenus(menuIndex),'AddRight',...
                                matlabshared.application.makeCallback(@this.addBarrierToRoadCallback,spec,'right'),...
                                'Separator','off');
                            addBarrierCenters=createMenu(hMenus(menuIndex),'AddBarrierCenters',...
                                matlabshared.application.makeCallback(@this.addBarrierCallback,spec),'Separator','off');
                            addLeft.Enable='on';
                            addRight.Enable='on';
                            addBarrierCenters.Enable='on';
                        else
                            hMenus(menuIndex)=uimenu(h,'Callback',matlabshared.application.makeCallback(@this.addBarrierCallback,spec));
                        end
                    end
                    set(hMenus(menuIndex),...
                        'Label',getString(message('driving:scenarioApp:AddActorMenuLabel',spec.name)),...
                        'UserData',spec,...
                        'Separator',sep);
                    menuIndex=menuIndex+1;
                    sep='off';
                end
            end
        end

        function addActorCallback(this,h,~)
            spec=h.UserData;

            designer=this.Application;
            clickLocation=this.ClickLocation;


            isPointInRoad=this.Application.RoadSpecifications.findRoadWithPoint(this.ClickLocation);



            if~isempty(isPointInRoad)
                [height,~,~]=getHeightInClickedPoint(this,this.ClickLocation(1:2));
                height=round(height,1);
                clickLocation=[this.ClickLocation(1:2),height];
            end


            if isempty(spec.PlotColor)
                spec.PlotColor=driving.scenario.Actor.getDefaultColorForActorID(designer.ActorCount+1);
            end

            edit=driving.internal.scenarioApp.undoredo.AddActor(designer,...
                'PlotColor',spec.PlotColor,...
                'Position',clickLocation,...
                'Name',getUniqueName(getActorAdder(designer),spec.name),...
                'Length',spec.Length,...
                'Width',spec.Width,...
                'Height',spec.Height,...
                'Speed',spec.Speed,...
                'ClassID',spec.id,...
                'AssetType',spec.AssetType,...
                'RCSElevationAngles',spec.RCSElevationAngles,...
                'RCSAzimuthAngles',spec.RCSAzimuthAngles,...
                'RCSPattern',spec.RCSPattern);
            applyEdit(designer,edit);
            id=numel(designer.ActorSpecifications);
            this.ActorID=id;
            this.ClickIndex=id;
        end

        function addWaypointsCallback(this,~,~)
            setReverseMotion(this.Application.ActorProperties,0);
            addWaypoints(getActorAdder(this.Application),this.ClickIndex);
        end

        function addReverseWaypointsCallback(this,~,~)
            setReverseMotion(this.Application.ActorProperties,1);
            addWaypoints(getActorAdder(this.Application),this.ClickIndex);
        end

        function removeWaypointsCallback(this,~,~)
            designer=this.Application;
            edit=driving.internal.scenarioApp.undoredo.SetActorProperty(designer,...
                designer.ActorSpecifications(this.ClickIndex),'Waypoints',[]);
            applyEdit(designer,edit);
        end

        function updateHighlight(this)
            spec=this.CurrentSpecification;
            hLine=this.RoadHighlight;
            set(hLine,'Visible','off');
            actorPatches=this.ActorPatches;
            currentActor=this.ActorHighlight;
            barrierPatches=this.BarrierPatches;
            currentBarrier=this.BarrierHighlight;
            if isempty(actorPatches)||~isempty(currentActor)&&any(currentActor>numel(actorPatches))
                this.ActorHighlight=[];
                currentActor=[];
            end
            for indx=1:numel(currentActor)
                p=actorPatches(currentActor(indx));
                set(p,'EdgeColor',get(p,'FaceColor')*0.8,'LineWidth',0.5);
            end
            if isempty(barrierPatches)||~isempty(currentBarrier)&&currentBarrier>numel(barrierPatches)
                this.BarrierHighlight=[];
                currentBarrier=[];
            end
            b=barrierPatches(currentBarrier);
            set(b,'EdgeColor',get(b,'FaceColor')*0.8,'LineWidth',0.5);
            app=this.Application;
            if isRunning(app.Simulator)
                return;
            end
            if~isempty(spec)

                if isa(spec,'driving.internal.scenarioApp.road.Specification')&&~any(strcmp(this.InteractionMode,{'addRoad','addBarrier'}))
                    if~any(spec==app.RoadSpecifications)
                        this.CurrentSpecification=[];
                        return;
                    end

                    if this.EnableRoadInteractivity
                        rgb=[0,154,225]/255;
                    else
                        rgb=[128,128,128]/255;
                    end

                    if isempty(hLine)||~ishghandle(hLine)
                        hLine=line(getAxes(this),...
                            'LineWidth',2,...
                            'Tag','RoadHighlight',...
                            'UIContextMenu',this.RoadContextMenu);
                        this.RoadHighlight=hLine;
                    end
                    set(hLine,'Color',rgb);
                    [x,y,z]=rbsToXyz(getRoadBoundaries(spec));
                    offset=driving.scenario.internal.AxesOrientation.getOffset(app.AxesOrientation);
                    set(hLine,'Visible','on','XData',x,'YData',y,'ZData',z+0.1*offset);

                elseif isa(spec,'driving.internal.scenarioApp.ActorSpecification')
                    index=[spec.ActorID];
                    if any(numel(this.ActorPatches)>=index)
                        set(this.ActorPatches(index),'EdgeColor',this.HighlightColor,'LineWidth',1.5);
                    end
                    this.ActorHighlight=index;

                    updatePoseIndicator(this,spec(end));

                elseif isa(spec,'driving.internal.scenarioApp.BarrierSpecification')
                    index=find(spec==app.BarrierSpecifications,1);

                    if numel(this.BarrierPatches)>=index
                        set(this.BarrierPatches(index),'EdgeColor',this.HighlightColor,'LineWidth',1);
                    end
                    this.BarrierHighlight=index;
                end
            end
        end

        function onEgoCarIdChanged(this,~,~)
            updateEgoIndicator(this);
        end

        function onSimulatorStateChanged(this,~,~)
            updatePoseIndicator(this);
            updateActorRotator(this);
        end

        function updateEgoIndicator(this)
            if~this.ShowEgoIndicator
                delete(this.EgoIndicator);
                this.EgoIndicator=matlab.graphics.GraphicsPlaceholder.empty;
                return;
            end
            opts=getPlotActorsOptions(this);
            opts.FullPaint=true;
            app=this.Application;
            index=app.EgoCarId;
            hAxes=this.Axes;
            opts.ActorIndicators=index;
            opts.UnitsPerPixel=this.UnitsPerPixel;
            opts.ZTop=hAxes.ZLim(2)-1;
            oldei=this.EgoIndicator;
            ei=driving.scenario.internal.plotActorIndicators(app.Scenario.Actors,hAxes,this.EgoIndicator,opts);
            if~isempty(index)&&isempty(oldei)
                set(findobj(ei),...
                    'Tag','EgoIndicator',...
                    'UserData',app.ActorSpecifications(index),...
                    'UIContextMenu',this.ActorContextMenu,...
                    'ButtonDownFcn',@this.onButtonDown);
            end
            this.EgoIndicator=ei;
        end

        function updatePoseIndicator(this,hover)


            if nargin<2
                hover=[];
            end
            anchor=this.PoseIndicator;
            if isempty(hover)&&isempty(this.CurrentSpecification)
                set(anchor,'Visible','off');
                return;
            end
            if isempty(anchor)
                props={this.Axes,'LineWidth',1.5,...
                    'EdgeColor',this.HighlightColor,...
                    'UIContextMenu',this.ActorContextMenu};
                anchor=[
                    patch(props{:},'Tag','PoseIndicatorCurrent')
                    patch(props{:},'Tag','PoseIndicatorHover')
                    ];
                this.PoseIndicator=anchor;
            end

            current=this.CurrentSpecification;
            if~isa(current,'driving.internal.scenarioApp.ActorSpecification')
                current=[];
            end
            set(anchor,'Visible','off');
            app=this.Application;
            if isRunning(app.Simulator)&&~this.ShowPoseIndicatorDuringSim
                return;
            end
            if isempty(current)
                anchor(1)=[];
            end
            for iSpec=1:numel(current)
                specs=[current(iSpec),hover];
                for indx=1:numel(specs)

                    spec=specs(indx);
                    actor=this.getActorFromScenario(spec);


                    if isempty(actor)
                        continue;
                    end

                    wh=min(actor.Width,actor.Length);
                    whpix=wh/this.UnitsPerPixel-4;
                    if whpix>14
                        xypix=[-5,-7;-5,7;8,0;-5,-7];
                        xy=xypix*this.UnitsPerPixel;
                        xy=rotate2d(xy,-actor.Yaw)+actor.Position(1:2);
                        if this.ShowEgoIndicator&&any(spec.ActorID==app.EgoCarId)
                            z=this.Axes.ZLim(2)-0.5;
                        else
                            z=spec.Position(3)+spec.Height+actor.Length*abs(sin(spec.Pitch))+0.1;
                        end
                        set(anchor(indx),'Visible','on',...
                            'FaceColor',spec.PlotColor,...
                            'UserData',spec,...
                            'XData',xy(:,1),...
                            'YData',xy(:,2),...
                            'ZData',repmat(z,4,1));
                    end
                end
            end
        end

        function updateActorRotator(this,spec)



            app=this.Application;
            if nargin<2||isRunning(app.Simulator)
                spec=[];
            end
            rotator=this.ActorRotator;
            poseIndicator=this.PoseIndicator;



            if isempty(poseIndicator)||...
                    strcmp(poseIndicator(2).Visible,'off')||...
                    isempty(spec)
                set(rotator,'Visible','off');
                return;
            end
            if isempty(rotator)
                color=this.HighlightColor;
                rotator(1)=line(this.Axes,...
                    'Color',color,...
                    'Tag','RotateLine',...
                    'UIContextMenu',this.ActorContextMenu,...
                    'LineWidth',1.5);
                rotator(2)=line(this.Axes,...
                    'Color',color,...
                    'Marker','o',...
                    'MarkerSize',10,...
                    'Tag','RotateNode',...
                    'MarkerFaceColor',color);
                this.ActorRotator=rotator;
                addButtonDownCallback(this);
            end



            xy=[8,0;58,0]*this.UnitsPerPixel;
            actorDims=dimensions(getActorFromScenario(this));



            xy(2,1)=min(actorDims.Length/2-actorDims.OriginOffset(1),xy(2,1));


            actor=this.getActorFromScenario(spec);
            xy=rotate2d(xy,-actor.Yaw)+actor.Position(1:2);

            if this.ShowEgoIndicator&&any(spec.ActorID==app.EgoCarId)
                z=this.Axes.ZLim(2)-0.4;
            else

                z=actor.Position(3)+actor.Height+actorDims.Length*abs(sin(actor.Pitch))+0.1;
            end
            set(rotator,'Visible','on','UserData',spec);
            set(rotator(1),'XData',xy(:,1),'YData',xy(:,2),'ZData',repmat(z,2,1)-0.1);



            set(rotator(2),'XData',xy(2,1),'YData',xy(2,2),'ZData',z);
        end

        function pasteItem(this,item,varargin)
            edit=[];
            app=this.Application;
            if isa(item,'driving.internal.scenarioApp.ActorSpecification')


                actorAdder=getActorAdder(app);

                if nargin<3
                    for i=1:numel(item)
                        offset=[item(i).Length/3,item(i).Width,0];
                        item(i).Position=item(i).Position-offset;
                        if~isempty(item(i).Waypoints)
                            item(i).Waypoints=item(i).Waypoints-offset;
                        end
                        newItem(i)=copy(item(i));
                        newItem(i).Name=actorAdder.getUniqueName(newItem(i).Name);
                    end




                elseif nargin>2
                    location=varargin{1};
                    centroid=mean(vertcat(item.Position));
                    newItem=copy(item);
                    for i=1:numel(item)
                        if i==1
                            newItem(i).Position=location;
                            centroid=location-item(i).Position;
                            if~isempty(newItem(i).Waypoints)
                                offset=item(i).Position-location;
                                newItem(i).Waypoints=newItem(i).Waypoints-offset;
                            end
                        else
                            newItem(i).Position=centroid+item(i).Position;
                            if~isempty(newItem(i).Waypoints)
                                offset=item(i).Position-newItem(i).Position;
                                newItem(i).Waypoints=newItem(i).Waypoints-offset;
                            end
                        end
                        newItem(i).Name=actorAdder.getUniqueName(newItem(i).Name);
                    end
                end
                edit=driving.internal.scenarioApp.undoredo.PasteActor(app,newItem);
            elseif isa(item,'driving.internal.scenarioApp.road.Specification')
                pvPairs=getPvPairsForPaste(item,varargin{:});
                applyPvPairs(item,pvPairs);




                newItem=copy(item);
                roadAdder=getRoadAdder(app);
                newItem.Name=roadAdder.getUniqueName(newItem.Name);
                edit=driving.internal.scenarioApp.undoredo.PasteRoad(app,newItem);
            elseif isa(item,'driving.internal.scenarioApp.BarrierSpecification')
                pvPairs=getPvPairsForPaste(item,varargin{:});
                applyPvPairs(item,pvPairs);




                newItem=copy(item);
                barrierAdder=getBarrierAdder(app);
                newItem.Name=barrierAdder.getUniqueName(newItem.Name);
                edit=driving.internal.scenarioApp.undoredo.PasteBarrier(app,newItem);
            end
            if~isempty(edit)
                focusOnComponent(this);
                applyEdit(app,edit);
            end
        end

        function[index,roadEditPointId,barrierEditPointId]=graphicalObjectToIndex(this,hsrc,position)
            tag=hsrc.Tag;
            roadEditPointId=[];
            barrierEditPointId=[];
            if strncmp(tag,'RoadTilesPatch',14)


                app=this.Application;
                roadSpecs=app.RoadSpecifications;
                spec=this.CurrentSpecification;
                if isa(spec,'driving.internal.scenarioApp.road.Specification')&&isPointInRoad(spec,position)
                    index=find(spec==roadSpecs);
                else
                    [~,index]=findRoadWithPoint(roadSpecs,position);
                end
                return;
            elseif strncmp(tag,'RoadEditPoint',11)
                index=find(this.Application.RoadSpecifications==hsrc.UserData);
                [~,xUnitsPerPixel]=getCurrentPoint(this);
                roadEditPointId=getEditPointId(hsrc.UserData,position,xUnitsPerPixel,2);
                return;
            elseif strncmp(tag,'BarrierEditPoint',11)
                index=find(this.Application.BarrierSpecifications==hsrc.UserData);
                [~,xUnitsPerPixel]=getCurrentPoint(this);
                barrierEditPointId=getEditPointId(hsrc.UserData,position,xUnitsPerPixel,2);
                return;
            elseif strncmp(tag,'ActorPatch',10)
                tag(1:10)=[];
                tag(strfind(tag,'_'):end)=[];
            elseif strncmp(tag,'BarrierPatch',12)
                tag(1:12)=[];
                tag(strfind(tag,'_'):end)=[];
            elseif strncmp(tag,'WaylineActor',12)
                tag(1:12)=[];
            elseif strncmp(tag,'WaypointActor',13)
                tag(1:13)=[];
            elseif any(strcmp(tag,{'RotateLine','RotateNode','EgoIndicator','PoseIndicatorHover','PoseIndicatorCurrent'}))
                actor=hsrc.UserData;
                index=actor.ActorID;
                return;
            end
            index=str2double(tag);
        end
    end

    methods(Access=protected)

        function fig=createFigure(this,varargin)
            fig=createFigure@driving.internal.scenarioApp.ScenarioView(this,varargin{:});
            pb=createPushButton(this,fig,'ScenarioSettings',@this.settingsCallback,...
                'TooltipString',getString(message('driving:scenarioApp:ScenarioCanvasSettingsDescription')),...
                'CData',getIcon(this.Application,'settings'),...
                'Position',[5,5,20,20]);
            this.RoadInteractivityDisabledMessage=createLabel(this,fig,...
                'DisabledRoadInteractivityMessage',...
                'Visible',~this.EnableRoadInteractivity);
            this.RoadInteractivityDisabledMessage.Position=[...
                pb.Position(1)*2+pb.Position(3),...
                pb.Position(1),...
                matlabshared.application.layout.AbstractLayout.getMinimumWidth(this.RoadInteractivityDisabledMessage),...
                min(this.RoadInteractivityDisabledMessage.Extent(4)-3,pb.Position(4))];
        end

        function onNewActorObjects(this)
            addButtonDownCallback(this);
            addActorContextMenus(this);
        end

        function k=createKeyboard(this)
            k=driving.internal.scenarioApp.ScenarioCanvasKeyboard(this);
        end

        function cancelButtonDown(this,~,~)


            if strncmp(this.InteractionMode,'drag',4)
                this.InteractionMode='none';
                resetRoadOutlines(this);
            end
        end

        function performButtonDown(this,hSrc,ev)


            this.DragOffset=[0,0,0];
            if~ishghandle(hSrc)
                hSrc=hittest(this.Figure);
                if~ishghandle(hSrc)
                    return;
                end
            end
            app=this.Application;
            if app.IsLoading
                return;
            end
            if isStopped(app.Simulator)
                disableUndoRedo(app);
            elseif strcmp(this.InteractionMode,'dragRoad')
                return
            end
            reenableUndoRedo=false;


            this.CachedWaypoints=[];
            this.CachedPosition=[];


            h_fig=this.Figure;
            stype=get(h_fig,'SelectionType');

            is_double_click=strcmp(stype,'open')&&~any(strcmp(this.Keyboard.PressedModifier,'shift'));
            is_right_click=strcmp(stype,'alt')&&~all(strcmp(this.Keyboard.PressedKey,'control'));
            is_left_click=strcmp(stype,'normal');
            is_shift_click=strcmp(stype,'extend')||...
                (strcmp(stype,'open')||strcmp(stype,'normal'))&&any(strcmp(this.Keyboard.PressedModifier,'shift'));
            is_ctrl_click=strcmp(stype,'alt')&&any(strcmp(this.Keyboard.PressedKey,'control'));


            isAddingActor=is_left_click&&strcmp(this.InteractionMode,'addActor');
            isAddingBarrier=is_left_click&&any(strcmp(this.InteractionMode,{'addBarrier','addMultipleBarriers','addBarrierCenters'}));
            isAddingRoad=is_left_click&&any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters'}));
            isAddingActorWaypoints=is_left_click&&strcmp(this.InteractionMode,'addActorWaypoints');
            isRemovingWaypoints=is_shift_click&&any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters','addBarrier','addBarrierCenters','addActorWaypoints'}));
            isCommittingWaypoints=(is_double_click||is_right_click)&&...
                any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters','addBarrier','addBarrierCenters','addActorWaypoints'}));
            noCurrentInteraction=strcmp(this.InteractionMode,'none');
            isDraggingActor=false;
            isDraggingActorWaypoint=false;
            isDraggingActorWayline=false;
            isDraggingRoad=false;
            isDraggingRoadCenter=false;
            isDraggingBarrier=false;
            isDraggingBarrierCenter=false;
            isRotatingActor=false;


            isMarqueeSelect=strcmp(stype,'extend')&&noCurrentInteraction;


            [position,xUnitsPerPixel]=getCurrentPoint(this);
            this.ClickLocation=position;
            this.IsDoubleClick=is_double_click;



            hClickedObject=hittest(h_fig);
            isAxesInteraction=noCurrentInteraction&&ishghandle(hSrc,'axes');
            if~isAxesInteraction&&(noCurrentInteraction||strncmp(this.InteractionMode,'drag',4))



                determineClickIndex(this,hClickedObject,this.InitialPoint);
                if is_right_click
                    enableUndoRedo(app);
                    return;
                end
                [type,tag,tagPrefix]=this.getClickedObjectType(ev.Source);
                isClickedOnRotate=strcmp(tag,'RotateNode');
                isClickedOnActor=strcmp(type,'actor');
                isClickedOnActorWayline=strcmp(type,'actorWayline');
                isClickedOnActorWaypoints=strcmp(type,'actorWaypoint');
                isClickedOnRoad=strcmp(type,'road');
                isClickedOnRoadEditPoint=strcmp(type,'roadEditPoint');
                isClickedOnBarrier=strcmp(type,'barrier');
                isClickedOnBarrierEditPoint=strcmp(type,'barrierEditPoint');
                if isClickedOnRotate
                    isRotatingActor=true;
                    current=hClickedObject.UserData;
                    this.ActorID=find(current==app.ActorSpecifications);
                    updateActorRotator(this,current);
                    if~isempty(this.CurrentSpecification)
                        if~ismember(this.ActorID,[this.CurrentSpecification.ActorID])
                            this.Application.ActorProperties.SpecificationIndex=this.ActorID;
                            current=app.ActorSpecifications(this.ActorID);
                        else
                            current=this.CurrentSpecification;
                        end
                    end

                elseif isClickedOnActor||isClickedOnActorWaypoints||isClickedOnActorWayline
                    isMultiSelect=is_ctrl_click&&isClickedOnActor;
                    newID=str2double(extractAfter(tag,tagPrefix));
                    this.ActorID=newID;

                    actorProps=app.ActorProperties;
                    cActor=app.ActorSpecifications(this.ActorID);
                    current=this.CurrentSpecification;
                    this.CurrentIndexToRemove=[];
                    if isa(current,'driving.internal.scenarioApp.ActorSpecification')
                        if isMultiSelect
                            indx=find(current==cActor,1,'first');
                            if isempty(indx)
                                current=[current,cActor];
                            else
                                this.CurrentIndexToRemove=indx;
                            end
                        elseif~ismember(cActor,current)
                            current=cActor;
                        else
                            this.CurrentIndexToRemove=find(current~=cActor);
                        end
                    else
                        current=cActor;
                    end
                    if isempty(current)
                        actorProps.SpecificationIndex=1;
                    else
                        actorProps.SpecificationIndex=[current.ActorID];
                    end


                    if(numel(current)==1)
                        actorProps.focusOnComponent;
                        if~is_double_click
                            this.focusOnComponent;
                        end
                    end
                    if isClickedOnActorWayline
                        if isOverWaypoint(this,cActor,this.InitialPoint)
                            isClickedOnActorWaypoints=true;
                            isClickedOnActorWayline=false;
                        end
                    end

                    isDraggingActor=isClickedOnActor;
                    isDraggingActorWaypoint=isClickedOnActorWaypoints;
                    isDraggingActorWayline=isClickedOnActorWayline;
                elseif isClickedOnRoad||isClickedOnRoadEditPoint
                    if this.EnableRoadInteractivity



                        roadSpecs=app.RoadSpecifications;
                        if isClickedOnRoad
                            spec=this.CurrentSpecification;
                            if isa(spec,'driving.internal.scenarioApp.road.Specification')&&isPointInRoad(spec,position)
                                current=spec;
                                this.RoadID=find(spec==roadSpecs);
                            else
                                [current,this.RoadID]=findRoadWithPoint(roadSpecs,position);
                            end
                        else
                            current=hClickedObject.UserData;
                            this.RoadID=find(current==roadSpecs);
                            this.RoadEditPointId=getEditPointId(current,position,xUnitsPerPixel,1);
                        end
                        if~isempty(this.RoadID)

                            newID=this.RoadID;

                            roadProps=app.RoadProperties;
                            if~isequal(roadProps.SpecificationIndex,newID)

                                app.RoadProperties.SpecificationIndex=newID;
                                update(app.RoadProperties);
                            end

                            focusOnComponent(roadProps);
                            if~is_double_click
                                this.focusOnComponent;
                            end
                        end
                        isDraggingRoad=isClickedOnRoad;
                        isDraggingRoadCenter=isClickedOnRoadEditPoint;
                    else


                        isAxesInteraction=true;
                        current=[];
                    end
                elseif isClickedOnBarrier||isClickedOnBarrierEditPoint
                    if isClickedOnBarrier
                        this.BarrierID=str2double(extractAfter(tag,tagPrefix));
                        current=app.BarrierSpecifications(this.BarrierID);
                    else
                        current=hClickedObject.UserData;
                        this.BarrierID=find(current==app.BarrierSpecifications);
                        this.BarrierEditPointId=getEditPointId(current,position,xUnitsPerPixel,1);
                    end

                    barrierProps=app.BarrierProperties();
                    barrierProps.SpecificationIndex=this.BarrierID;
                    update(barrierProps);

                    focusOnComponent(barrierProps);
                    if~is_double_click
                        this.focusOnComponent;
                    end
                    isDraggingBarrier=isClickedOnBarrier;
                    isDraggingBarrierCenter=isClickedOnBarrierEditPoint;
                else
                    reenableUndoRedo=true;
                    current=[];
                end
                this.CurrentSpecification=current;
            end

            if isAxesInteraction
                if is_right_click
                    menu=this.AxesContextMenu;
                    this.onAxesContextMenu(menu);
                    set(menu,...
                        'Position',h_fig.CurrentPoint,...
                        'Visible',true);
                    return
                end
                if~is_shift_click&&~is_ctrl_click
                    this.InteractionMode='pan';
                    this.PanHasOccurred=false;
                    return
                end
            end

            if~isStopped(app.Simulator)
                return;
            end



            if isCommittingWaypoints&&~is_right_click
                [~,isSameAsLastWaypointIndex]=driving.internal.scenarioApp.Specification.getMatchingPointIndex(position,this.Waypoints,xUnitsPerPixel);
                if~isSameAsLastWaypointIndex
                    newPt=[position(1),position(2),position(3)];
                    if size(this.Waypoints,2)==4
                        newPt(end+1)=this.Waypoints(end,4);
                    end
                    newWaypoints=[this.Waypoints;newPt];
                    if~any(strcmp(this.InteractionMode,{'addRoad','addRoadCenters'}))||...
                            isempty(driving.internal.scenarioApp.road.Arbitrary.validateCenters(newWaypoints))
                        this.Waypoints=newWaypoints;
                    end
                end
            end

            if isMarqueeSelect
                marqueeLine=this.Marquee;
                if isempty(marqueeLine)||~ishghandle(marqueeLine)
                    marqueeLine=line(this.Axes,...
                        'LineStyle','--');
                    this.Marquee=marqueeLine;
                end
                set(marqueeLine,'Visible',true,'XData',[],'YData',[]);
                this.InteractionMode='marqueeSelect';
            elseif isAddingActor

                actor=this.CurrentActor;
                if isfield(actor,'Position')&&iscell(actor.Position)
                    if any(cellfun(@ischar,actor.Position))
                        actor=rmfield(actor,'Position');
                    end
                end
                if~isfield(actor,'Position')&&isfield(actor,'Waypoints')
                    actor.Position=actor.Waypoints(1,1:3);
                end
                pvPairs=matlabshared.application.structToPVPairs(actor);
                edit=driving.internal.scenarioApp.undoredo.AddActor(app,...
                    'Position',position,pvPairs{:});
                applyEdit(app,edit);
                id=numel(app.ActorSpecifications);
                this.ActorID=id;
                this.ClickIndex=id;
                if position(3)>0.2
                    checkForRoadJunctionNotification(this,position)
                end


                this.InteractionMode='none';

                restoreMousePointer(this);
                setStatus(app,'');
                reenableUndoRedo=true;
                this.HasUserNotClicked=false;
            elseif isAddingRoad

                createRoadCentersLine(this);
                waypoints=this.Waypoints;


                [~,isSameAsLastWaypointIndex]=this.CurrentRoad.getMatchingPointIndex(position,waypoints,xUnitsPerPixel);


                if isSameAsLastWaypointIndex
                    return;
                end



                isLooping=this.CurrentRoad.isWaypointLooping([waypoints;position],xUnitsPerPixel);
                if isLooping
                    position=waypoints(1,:);
                end
                roadProperties=app.RoadProperties;
                if roadProperties.InteractiveMode
                    zValue=getAddRoadCentersZValue(roadProperties);
                else
                    zValue=[];
                end
                if isempty(zValue)
                    if isempty(waypoints)
                        zValue=0;
                    else
                        zValue=waypoints(end,3);
                    end
                end
                newWaypoints=[waypoints;position(1),position(2),zValue];
                nWaypoints=size(newWaypoints,1);

                current=this.CurrentRoad;
                if nWaypoints>2
                    bankAngle=current.BankAngle;
                    if~isscalar(bankAngle)
                        bankAngle=[bankAngle,bankAngle(end)];
                    end
                    nHeadings=size(current.Heading,1);
                    headingAngle=[current.Heading;NaN(nWaypoints-nHeadings,1)];
                    if isempty(headingAngle)||all(isnan(headingAngle))
                        me=driving.internal.scenarioApp.road.Arbitrary.validateCenters(newWaypoints,current.Width,bankAngle);
                    else
                        me=driving.internal.scenarioApp.road.Arbitrary.validateCenters(newWaypoints,current.Width,bankAngle,headingAngle);
                    end
                    if isempty(me)
                        clearAllMessages(this);
                    else
                        errorMessage(this,me.message,me.identifier);
                        return
                    end
                end
                this.Waypoints=newWaypoints;
                notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(current,'Centers'));
                nPoints=getNumAddPoints(this.CurrentRoad);
                if nPoints(2)<=size(newWaypoints,1)
                    commitWaypoints(this);
                else

                    resetCursorLine(this);

                    updateWaypointLine(this);
                    setStatus(app,getString(message('driving:scenarioApp:CommitRoadCentersMessage')));
                end
                this.HasUserNotClicked=false;
            elseif isAddingBarrier

                delete(this.RoadEdgeSelect(:));
                this.RoadEdgeSelect=[];
                if~strcmp(this.InteractionMode,'addBarrier')
                    this.InteractionMode='addBarrier';
                end

                delete(this.BarrierRoads(:));
                this.BarrierRoads=driving.scenario.Road.empty;
                this.BarrierRoadEdges={};
                this.BarrierRoadEdgeLines={};

                createRoadCentersLine(this);
                waypoints=this.Waypoints;


                [~,isSameAsLastWaypointIndex]=this.CurrentBarrier.getMatchingPointIndex(position,waypoints,xUnitsPerPixel);


                if isSameAsLastWaypointIndex
                    return;
                end



                isLooping=this.CurrentBarrier.isWaypointLooping([waypoints;position],xUnitsPerPixel);
                if isLooping
                    position=waypoints(1,:);
                end
                if isempty(waypoints)
                    zValue=0;
                else

                    if~isempty(this.Application.RoadSpecifications)&&~isempty(this.Application.RoadSpecifications.findRoadWithPoint(waypoints(end,1:2)))
                        waypoints(end,3)=round(getHeightInClickedPoint(this,waypoints(end,1:2)),1);
                    end
                    zValue=waypoints(end,3);
                end
                newWaypoints=[waypoints;position(1),position(2),zValue];
                nWaypoints=size(newWaypoints,1);

                current=this.CurrentBarrier;
                current.Name=getUniqueName(getBarrierAdder(this.Application),current.Name);
                if nWaypoints>2
                    bankAngle=current.BankAngle;
                    if~isscalar(bankAngle)
                        bankAngle=[bankAngle,bankAngle(end)];
                    end
                    me=driving.internal.scenarioApp.BarrierSpecification.validateCenters(newWaypoints,current.Width,bankAngle);
                    if isempty(me)
                        clearAllMessages(this);
                    else
                        errorMessage(this,me.message,me.identifier);
                        return
                    end
                end
                this.Waypoints=newWaypoints;
                notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(current,'Centers'));
                nPoints=getNumAddPoints(this.CurrentBarrier);
                if nPoints(2)<=size(newWaypoints,1)
                    commitWaypoints(this);
                else

                    resetCursorLine(this);

                    updateWaypointLine(this);
                    setStatus(app,getString(message('driving:scenarioApp:CommitBarrierCentersMessage')));
                end
                this.HasUserNotClicked=false;
            elseif isAddingActorWaypoints

                actor=app.ActorSpecifications(this.ActorID);
                existingWaypoints=actor.Waypoints;
                if isempty(existingWaypoints)
                    existingWaypoints=actor.Position;
                end
                createActorWaypointsLine(this,existingWaypoints);
                if size(this.Waypoints,2)>=4
                    allSpeeds=actor.Speed;
                    speed=allSpeeds(find(allSpeeds~=0,1,'last'));
                    if this.Application.ActorProperties.AddingReverseMotion





                        if abs(speed)>20
                            speed=-abs(driving.scenario.Path.DefaultReverseSpeed);
                        else
                            speed=-abs(speed);
                        end
                        if this.Waypoints(end,4)>0
                            if size(this.Waypoints,1)==1
                                this.Waypoints(end,4)=speed;
                            elseif this.Waypoints(end-1,4)~=0
                                this.Waypoints(end,4)=0;
                            else
                                speed=0;
                            end
                        end
                    else



                        speed=abs(speed);
                        if isempty(speed)
                            speed=driving.scenario.Path.DefaultSpeed;
                        end
                        if this.Waypoints(end,4)<0
                            if size(this.Waypoints,1)==1
                                this.Waypoints(end,4)=speed;
                            elseif this.Waypoints(end-1,4)~=0
                                this.Waypoints(end,4)=0;
                            else
                                speed=0;
                            end
                        end
                    end
                else
                    speed=driving.scenario.Path.DefaultSpeed;
                end
                if size(this.Waypoints,2)>=5
                    waitTime=0;
                    if size(this.Waypoints,2)==6
                        pWaypointsYaw=NaN;
                    else
                        pWaypointsYaw=[];
                    end
                else
                    waitTime=[];
                    pWaypointsYaw=[];
                end

                waypoints=[this.Waypoints;position(1),position(2),position(3),speed,waitTime,pWaypointsYaw];


                if~isempty(actor.findDuplicateWaypoints(waypoints))
                    return
                end
                this.Waypoints=waypoints;
                notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actor,'Waypoints'));

                resetCursorLine(this);

                start=size(existingWaypoints,1);
                set(this.WaypointLine,'XData',this.Waypoints(start:end,1),'YData',this.Waypoints(start:end,2),'ZData',this.Waypoints(start:end,3));
                setStatus(app,getString(message('driving:scenarioApp:CommitWaypointsMessage')));
                this.HasUserNotClicked=false;
            elseif isRemovingWaypoints
                if~isempty(this.Waypoints)

                    if strncmp(this.InteractionMode,'addRoad',7)
                        start=1;
                        id=this.RoadID;
                        if~isempty(id)
                            road=app.RoadSpecifications(id);
                            existingRoadCenters=road.Centers;
                            if~isempty(existingRoadCenters)
                                start=size(existingRoadCenters,1);
                            end
                        end
                        if size(this.Waypoints,1)>start
                            this.Waypoints(end,:)=[];
                        end
                        if~isempty(id)
                            notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(road,'Centers'));
                        end
                    elseif strncmp(this.InteractionMode,'addBarrier',7)
                        start=1;
                        id=this.BarrierID;
                        if~isempty(id)
                            barrier=app.BarrierSpecifications(id);
                            existingBarrierCenters=barrier.Centers;
                            if~isempty(existingBarrierCenters)
                                start=size(existingBarrierCenters,1);
                            end
                        end
                        if size(this.Waypoints,1)>start
                            this.Waypoints(end,:)=[];
                        end
                        if~isempty(id)
                            notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(barrier,'Centers'));
                        end
                    else
                        actor=app.ActorSpecifications(this.ActorID);
                        existingWaypoints=actor.Waypoints;
                        if isempty(existingWaypoints)
                            existingWaypoints=actor.Position;
                        end
                        start=size(existingWaypoints,1);
                        if size(this.Waypoints,1)>start
                            this.Waypoints(end,:)=[];
                        end
                        notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actor,'Waypoints'));
                    end
                end
                if~isempty(this.WaypointLine)&&~isempty(this.Waypoints)

                    set(this.WaypointLine,'XData',this.Waypoints(start:end,1),'YData',this.Waypoints(start:end,2),'ZData',this.Waypoints(start:end,3));

                    updateCursorLine(this,this.Waypoints,position);
                end
            elseif isCommittingWaypoints

                commitWaypoints(this);
                setStatus(app,'');
                reenableUndoRedo=true;
            elseif isRotatingActor
                this.InteractionMode='rotateActor';
                if~this.IsDraggingStart
                    this.IsDraggingStart=true;
                end
                reenableUndoRedo=true;
            elseif isDraggingActor

                this.InteractionMode='dragActor';
                if~this.IsDraggingStart
                    this.IsDraggingStart=true;
                end
                reenableUndoRedo=true;
            elseif isDraggingActorWaypoint

                actor=app.ActorSpecifications(this.ActorID);
                this.CurrentSpecification=actor;
                if~isempty(actor.Waypoints)
                    K=actor.getMatchingPointIndex(position,actor.Waypoints,xUnitsPerPixel);
                    if~isempty(K)
                        this.WaypointIndex=K;
                        this.InteractionMode='dragActorWaypoint';
                        if~this.IsDraggingStart
                            this.IsDraggingStart=true;
                        end
                    end
                end
            elseif isDraggingActorWayline
                this.CurrentSpecification=app.ActorSpecifications(this.ActorID);
                if is_double_click
                    this.ClickLocation=this.InitialPoint;
                    addWaypointCallback(this);
                else

                    this.InteractionMode='dragActorWayline';
                    if~this.IsDraggingStart
                        this.IsDraggingStart=true;
                    end
                end
            elseif isDraggingRoadCenter

                id=getEditPointId(current,position,xUnitsPerPixel,1);
                if isempty(id)
                    this.InteractionMode='none';
                    return;
                end
                this.RoadEditPointId=id;
                this.InteractionMode='dragRoadEditPoint';
                if~this.IsDraggingStart
                    this.IsDraggingStart=true;
                end
            elseif isDraggingRoad
                if is_double_click
                    this.ClickLocation=this.InitialPoint;
                    performDoubleClickOnRoad(this);
                    this.InteractionMode='none';
                else

                    this.InteractionMode='dragRoad';
                    if~this.IsDraggingStart
                        this.IsDraggingStart=true;
                    end
                end
            elseif isDraggingBarrierCenter

                id=getEditPointId(current,position,xUnitsPerPixel,1);
                if isempty(id)
                    this.InteractionMode='none';
                    return;
                end
                this.BarrierEditPointId=id;
                this.InteractionMode='dragBarrierEditPoint';
                if~this.IsDraggingStart
                    this.IsDraggingStart=true;
                end
            elseif isDraggingBarrier
                if is_double_click
                    this.ClickLocation=this.InitialPoint;
                    performDoubleClickOnRoad(this);
                    this.InteractionMode='none';
                else

                    this.InteractionMode='dragBarrier';
                    if~this.IsDraggingStart
                        this.IsDraggingStart=true;
                    end
                end
            end
            if reenableUndoRedo
                enableUndoRedo(app);
            end
        end

        function onRoadEdgeHighlightButtonDown(this,roadEdgeLines,roadEdges,roads)

            h_fig=this.Figure;
            stype=get(h_fig,'SelectionType');
            is_ctrl_click=strcmp(stype,'alt')||any(strcmp(this.Keyboard.PressedModifier,'control'));

            if any(strcmp(this.InteractionMode,{'addBarrier','addMultipleBarriers','addBarrierCenters'}))
                this.BarrierRoads(end+1:end+numel(roads))=roads;
                this.BarrierRoadEdges(end+1:end+numel(roads))=roadEdges;
                this.BarrierRoadEdgeLines(end+1:end+numel(roads))=roadEdgeLines;
                commitRoadEdgeBarrier(this,is_ctrl_click);
                this.HasUserNotClicked=false;
            end
        end

        function performMouseMove(this,~,ev)



            app=this.Application;
            if~isvalid(app)||app.IsLoading
                return;
            end
            if~isempty(this.RoadEdgeHighlight)
                set(this.RoadEdgeHighlight(:),'Visible','off');
            end
            hFig=getFigure(this);
            if useAppContainer(app)
                doc=this.FigureDocument;
                if isempty(doc)||doc.Showing
                    selected=app.Window.AppContainer.SelectedChild;
                    if~isempty(selected)&&isfield(selected,'tag')&&~strcmp(selected.tag,'ScenarioCanvas')
                        focusOnComponent(this);
                    end
                end
            else
                shh=get(0,'ShowHiddenHandles');
                set(0,'ShowHiddenHandles','on');
                if~isequal(hFig,get(0,'CurrentFigure'))
                    focusOnComponent(this);
                end
                set(0,'ShowHiddenHandles',shh);
            end
            tooltip='';
            interp='none';
            hoverActor=[];
            shouldDrawnow=false;
            if isvalid(ev)&&isprop(ev,'HitObject')&&~isempty(ev.HitObject)
                hitObject=ev.HitObject;
                currPointer=hFig.Pointer;
                tag=hitObject.Tag;
                isSimStopped=isStopped(app.Simulator);
                isValidHit=~isempty(hitObject)&&isvalid(hitObject)&&...
                    ~any(strcmp(hitObject.Type,{'text'}))&&isSimStopped;
                iMode=this.InteractionMode;
                if isValidHit&&any(strcmp(iMode,{'addRoad','addRoadCenters','addBarrier','addMultipleBarriers','addBarrierCenters','addActor','addActorWaypoints'}))

                    hFig.Pointer='cross';
                    this.PreviousMousePointer=currPointer;
                    currPt=getCurrentPoint(this);

                    if~strncmp(tag,'Barrier',7)&&any(strcmp(iMode,{'addBarrier','addMultipleBarriers'}))&&isempty(this.Waypoints)
                        hFig=this.Figure;
                        multiHighlight=any(strcmp(get(hFig,'CurrentModifier'),'shift'))||...
                            any(strcmp(this.Keyboard.PressedModifier,'shift'));
                        [road,roadEdgeLines,roadEdges]=getRoadEdgeLineForBarrier(app.Scenario.RoadSegments,currPt,app.BarrierSpecifications,multiHighlight);
                        if~isempty(road)
                            this.Figure.Pointer='hand';
                            this.PreviousMousePointer=currPointer;

                            roads(1:numel(roadEdges))=driving.scenario.Road(road);

                            numSegments=numel(roadEdges);
                            numHighlights=numel(this.RoadEdgeHighlight);
                            if numHighlights>numSegments
                                delete(this.RoadEdgeHighlight(numSegments+1:end));
                                this.RoadEdgeHighlight(numSegments+1:end)=[];
                            elseif numHighlights<numSegments
                                for i=numHighlights+1:numSegments
                                    this.RoadEdgeHighlight(i)=line(getAxes(this),'LineWidth',4.5);
                                end
                            end
                            rgb=[0,154,225]/255;
                            for i=1:numSegments
                                hLine=this.RoadEdgeHighlight(i);
                                if isempty(hLine)||~ishghandle(hLine)
                                    hLine=line(getAxes(this),'LineWidth',4.5);
                                end
                                [x,y,z]=rbsToXyz(roadEdgeLines(i));
                                offset=driving.scenario.internal.AxesOrientation.getOffset(app.AxesOrientation);
                                set(hLine,'Visible','on','XData',x,'YData',y,'ZData',z+0.1*offset,'Color',rgb,...
                                    'ButtonDownFcn',matlabshared.application.makeCallback(@this.onRoadEdgeHighlightButtonDown,roadEdgeLines,roadEdges,roads));
                            end
                        end
                    else

                        [tooltip,cp]=getCursorText(this);



                        if any(strcmp(iMode,{'addRoad','addRoadCenters','addBarrier','addBarrierCenters'}))
                            updateCursorLine(this,this.Waypoints,cp);
                        elseif strcmp(iMode,'addActorWaypoints')
                            updateAddActorWaypointsCursorLine(this,cp);


                            if app.ActorProperties.AddingReverseMotion
                                tooltip=tooltip+" "+getString(message('driving:scenarioApp:ReverseTooltip'));
                            else
                                tooltip=tooltip+" "+getString(message('driving:scenarioApp:ForwardTooltip'));
                            end
                        end
                    end
                elseif isValidHit&&strcmp(iMode,'marqueeSelect')
                    marqueeLine=this.Marquee;
                    oPoint=this.ClickLocation;
                    cPoint=getCurrentPoint(this);
                    set(marqueeLine,...
                        'XData',[oPoint(1),cPoint(1),cPoint(1),oPoint(1),oPoint(1)],...
                        'YData',[oPoint(2),oPoint(2),cPoint(2),cPoint(2),oPoint(2)]);
                    newIds=getMarqueeSelectIds(this,oPoint,cPoint);

                    updateHighlight(this);
                    set(this.ActorPatches(newIds),'EdgeColor',this.HighlightColor,'LineWidth',1.5);
                    this.ActorHighlight=newIds;
                elseif isValidHit&&strcmp(iMode,'rotateActor')
                    this.CurrentIndexToRemove=[];
                    [~,cp]=getCursorText(this);
                    actor=app.ActorSpecifications(this.ActorID);
                    otherActors=this.CurrentSpecification;
                    otherActors(otherActors==actor)=[];

                    if this.IsDraggingStart
                        this.CachedYaw=actor.Yaw;
                        if~isempty(otherActors)
                            for i=1:numel(otherActors)
                                this.CachedYaw(i+1,:)=otherActors(i).Yaw;
                            end
                        end
                        this.IsDraggingStart=false;
                    end
                    op=actor.Position;
                    y=cp(2)-op(2);
                    x=cp(1)-op(1);
                    newYaw=atand(y/x);
                    if x<0
                        if y<0
                            newYaw=newYaw-180;
                        else
                            newYaw=newYaw+180;
                        end
                    end
                    roundFactor=1;
                    if isequal(this.Keyboard.PressedModifier,{'control'})
                        roundFactor=15;
                    end
                    newYaw=round(newYaw/roundFactor)*roundFactor;
                    scenarioActor(1)=getActorFromScenario(this,actor);
                    if~isempty(otherActors)
                        for i=1:numel(otherActors)
                            scenarioActor(i+1)=getActorFromScenario(this,otherActors(i));
                        end
                    end
                    Diff=newYaw-scenarioActor(1).Yaw;

                    scenarioActor(1).Yaw=newYaw;
                    actor.Yaw=newYaw;

                    waypoints=actor.Waypoints;
                    if~isempty(waypoints)
                        waitTime=actor.WaitTime;
                        if(actor.Speed(1)<0)
                            actor.pWaypointsYaw(1)=actor.Yaw-180;
                        else
                            actor.pWaypointsYaw(1)=actor.Yaw;
                        end

                        if all(isnan(actor.WaypointsYaw))||isempty(actor.WaypointsYaw)
                            actor.WaypointsYaw=nan(numel(actor.pWaypointsYaw),1);
                            actor.WaypointsYaw(1)=actor.pWaypointsYaw(1);
                        else
                            actor.WaypointsYaw(1)=actor.pWaypointsYaw(1);
                        end

                        waypointsYaw=actor.WaypointsYaw;

                        if~isempty(waitTime)
                            trajectory(scenarioActor(1),actor.Waypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                        else
                            trajectory(scenarioActor(1),actor.Waypoints,actor.Speed,'Yaw',waypointsYaw);
                        end
                    end

                    if~isempty(otherActors)
                        for i=1:numel(otherActors)
                            if isempty(otherActors(i).Waypoints)
                                otherActors(i).Yaw=otherActors(i).Yaw+Diff;
                                scenarioActor(i+1).Yaw=scenarioActor(i+1).Yaw+Diff;
                            else
                                otherActors(i).Yaw=otherActors(i).pWaypointsYaw(1)+Diff;
                                scenarioActor(i+1).Yaw=otherActors(i).pWaypointsYaw(1)+Diff;
                                waitTime=otherActors(i).WaitTime;

                                if(otherActors(i).Speed(1)<0)
                                    otherActors(i).pWaypointsYaw(1)=otherActors(i).Yaw-180;
                                else
                                    otherActors(i).pWaypointsYaw(1)=otherActors(i).Yaw;
                                end

                                if all(isnan(otherActors(i).WaypointsYaw))||isempty(otherActors(i).WaypointsYaw)
                                    otherActors(i).WaypointsYaw=nan(numel(otherActors(i).pWaypointsYaw),1);
                                    otherActors(i).WaypointsYaw(1)=otherActors(i).pWaypointsYaw(1);
                                else
                                    otherActors(i).WaypointsYaw(1)=otherActors(i).pWaypointsYaw(1);
                                end
                                waypointsYaw=otherActors(i).WaypointsYaw;
                                if~isempty(waitTime)
                                    trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed,waitTime,'Yaw',waypointsYaw);
                                else
                                    trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed,'Yaw',waypointsYaw);
                                end
                            end
                        end
                    end
                    tooltip=deg2str(newYaw);
                    interp='tex';
                    updateActor(app.EgoCentricView,[this.CurrentSpecification.ActorID]);
                    updateActor(this,[this.CurrentSpecification.ActorID]);
                    hoverActor=actor;


                    notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.CurrentSpecification,'Yaw'));
                    shouldDrawnow=true;

                elseif isValidHit&&strcmp(iMode,'dragActor')
                    this.CurrentIndexToRemove=[];

                    actor=app.ActorSpecifications(this.ActorID);
                    scenarioActor=getActorFromScenario(this,actor);

                    if~isempty(scenarioActor)


                        otherActors=this.CurrentSpecification;
                        otherActors(otherActors==actor)=[];
                        if~isempty(otherActors)
                            for i=1:numel(otherActors)
                                scenarioActor(i+1)=getActorFromScenario(this,otherActors(i));
                            end
                        end

                        waypoints=actor.Waypoints;
                        speed=actor.Speed;
                        ip=this.InitialPoint(1:2);
                        if(speed(1)<0)
                            rYaw=scenarioActor(1).Yaw-180;
                        else
                            rYaw=scenarioActor(1).Yaw;
                        end
                        if this.IsDraggingStart



                            distance=ip-scenarioActor(1).Position(1:2);
                            rotated=rotate2d(distance,rYaw);

                            this.CachedOffset=rotated;
                            this.CachedPosition=scenarioActor(1).Position;
                            this.CachedWaypoints=waypoints;

                            if~isempty(otherActors)
                                for i=1:numel(otherActors)
                                    distance=ip-scenarioActor(i+1).Position(1:2);
                                    rotated=rotate2d(distance,scenarioActor(i+1).Yaw);
                                    this.CachedPosition=[this.CachedPosition;scenarioActor(i+1).Position];
                                    this.CachedOffset=[this.CachedOffset;rotated];
                                end
                            end

                            this.IsDraggingStart=false;
                        end

                        if isempty(waypoints)
                            iterations=1;
                        else
                            iterations=10;
                        end

                        yaw=-rYaw;
                        diff=1;
                        mousePos=getCurrentPoint(this);
                        offset=this.CachedOffset(1,:);
                        n=1;




                        testwaypoints=waypoints;
                        motions=driving.scenario.Path.validateSpeed(speed);
                        if~isempty(motions)
                            testwaypoints=testwaypoints(1:motions(1),:);
                        end

                        while diff>0.1&&n<=iterations
                            n=n+1;
                            rotated=rotate2d(offset,yaw);

                            cp=mousePos-[rotated,0];
                            if isempty(waypoints)||~isempty(actor.WaypointsYaw)
                                break;
                            end
                            testwaypoints(1,:)=cp;
                            newyaw=-rad2deg(matlabshared.tracking.internal.scenario.clothoidG2fitMissingCourse(testwaypoints,nan(size(testwaypoints,1),1)));
                            diff=abs(newyaw(1)-yaw);
                            yaw=newyaw(1);
                        end



                        if diff>10
                            cp=mousePos;
                        end

                        scenarioActor(1).Position=cp;
                        actor.Position=cp;



                        if~isempty(waypoints)
                            waypoints(1,:)=cp;
                            actor.Waypoints=waypoints;
                            waitTime=actor.WaitTime;
                            waypointsYaw=actor.WaypointsYaw;

                            if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                                if~isempty(waitTime)
                                    trajectory(scenarioActor(1),actor.Waypoints,actor.Speed,waitTime);
                                else
                                    trajectory(scenarioActor(1),actor.Waypoints,actor.Speed);
                                end
                            else
                                if~isempty(waitTime)
                                    trajectory(scenarioActor(1),actor.Waypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                                else
                                    trajectory(scenarioActor(1),actor.Waypoints,actor.Speed,'Yaw',waypointsYaw);
                                end
                            end
                            if~isempty(actor.pWaypointsYaw)
                                if(actor.Speed(1)<0)
                                    scenarioActor(1).Yaw=actor.pWaypointsYaw(1)-180;
                                    actor.Yaw=actor.pWaypointsYaw(1)-180;
                                else
                                    scenarioActor(1).Yaw=actor.pWaypointsYaw(1);
                                    actor.Yaw=actor.pWaypointsYaw(1);
                                end
                            end
                        end

                        if isa(scenarioActor(1).MotionStrategy,'driving.scenario.Path')
                            actor.pWaypointsYaw=scenarioActor(1).MotionStrategy.getWaypointsYaw;
                        end

                        if~isempty(otherActors)
                            centroid=cp-this.CachedPosition(1,:);
                            for i=1:numel(otherActors)
                                otherActors(i).Position=centroid+this.CachedPosition(i+1,:);
                                scenarioActor(i+1).Position=otherActors(i).Position;

                                if~isempty(otherActors(i).Waypoints)
                                    otherActors(i).Waypoints(1,:)=otherActors(i).Position;
                                    waitTime=otherActors(i).WaitTime;
                                    waypointsYaw=otherActors(i).WaypointsYaw;

                                    if~isempty(otherActors(i).pWaypointsYaw)
                                        if(otherActors(i).Speed(1)<0)
                                            scenarioActor(i+1).Yaw=otherActors(i).pWaypointsYaw(1)-180;
                                            otherActors(i).Yaw=otherActors(i).pWaypointsYaw(1)-180;
                                        else
                                            scenarioActor(i+1).Yaw=otherActors(i).pWaypointsYaw(1);
                                            otherActors(i).Yaw=otherActors(i).pWaypointsYaw(1);
                                        end
                                    end

                                    if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                                        if~isempty(waitTime)
                                            trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed,waitTime);
                                        else
                                            trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed);
                                        end
                                    else
                                        if~isempty(waitTime)
                                            trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed,waitTime,'Yaw',waypointsYaw);
                                        else
                                            trajectory(scenarioActor(i+1),otherActors(i).Waypoints,otherActors(i).Speed,'Yaw',waypointsYaw);
                                        end
                                    end
                                end
                            end
                        end
                        updateActor(app.EgoCentricView,[this.CurrentSpecification.ActorID]);
                        updateActor(this,[this.CurrentSpecification.ActorID],true);
                        this.ShouldDirty=true;
                        hoverActor=actor;
                        notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.CurrentSpecification,'Position'));
                        notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.CurrentSpecification,'Waypoints'));
                        tooltip=getCursorText(this);
                        shouldDrawnow=true;
                    end

                elseif isValidHit&&strcmp(iMode,'dragActorWaypoint')

                    scenarioActor=getActorFromScenario(this);
                    if~isempty(scenarioActor)&&~isempty(this.WaypointIndex)
                        actor=app.ActorSpecifications(this.ActorID);
                        waypoints=actor.Waypoints;


                        if this.IsDraggingStart
                            this.CachedWaypoints=waypoints;
                            this.IsDraggingStart=false;
                        end


                        cp=getCurrentPoint(this);
                        if~isempty(waypoints)


                            waypoints(this.WaypointIndex,:)=cp;
                            actor.Waypoints=waypoints;
                            waitTime=actor.WaitTime;
                            waypointsYaw=actor.WaypointsYaw;
                            if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                                if~isempty(waitTime)
                                    trajectory(scenarioActor,waypoints,actor.Speed,waitTime);
                                else
                                    trajectory(scenarioActor,waypoints,actor.Speed);
                                end
                            else
                                if~isempty(waitTime)
                                    trajectory(scenarioActor,waypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                                else
                                    trajectory(scenarioActor,waypoints,actor.Speed,'Yaw',waypointsYaw);
                                end
                            end
                        end
                        if isa(scenarioActor.MotionStrategy,'driving.scenario.Path')
                            actor.pWaypointsYaw=scenarioActor.MotionStrategy.getWaypointsYaw;
                        end
                        updateActor(app.EgoCentricView,this.ActorID);
                        updateActor(this,this.ActorID,true);
                        this.ShouldDirty=true;
                        notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actor,'Waypoints'));
                        tooltip=getCursorText(this);
                        shouldDrawnow=true;
                    end
                elseif isValidHit&&strcmp(iMode,'dragActorWayline')
                    scenarioActor=getActorFromScenario(this);
                    if~isempty(scenarioActor)
                        actor=app.ActorSpecifications(this.ActorID);
                        waypoints=actor.Waypoints;


                        if this.IsDraggingStart||isempty(this.CachedWaypoints)
                            this.CachedPosition=actor.Position;
                            this.CachedWaypoints=waypoints;
                            this.IsDraggingStart=false;
                        end
                        cp=getCurrentPoint(this);
                        actor.Waypoints=this.CachedWaypoints+cp-this.InitialPoint;
                        waitTime=actor.WaitTime;
                        waypointsYaw=actor.WaypointsYaw;
                        if all(isnan(waypointsYaw))||isempty(waypointsYaw)
                            if~isempty(waitTime)
                                trajectory(scenarioActor,waypoints,actor.Speed,waitTime);
                            else
                                trajectory(scenarioActor,waypoints,actor.Speed);
                            end
                        else
                            if~isempty(waitTime)
                                trajectory(scenarioActor,waypoints,actor.Speed,waitTime,'Yaw',waypointsYaw);
                            else
                                trajectory(scenarioActor,waypoints,actor.Speed,'Yaw',waypointsYaw);
                            end
                        end
                        if isa(scenarioActor.MotionStrategy,'driving.scenario.Path')
                            actor.pWaypointsYaw=scenarioActor.MotionStrategy.getWaypointsYaw;
                        end
                        updateActor(this,this.ActorID,true);
                        this.ShouldDirty=true;
                        notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(actor,'Waypoints'));
                        shouldDrawnow=true;
                    end

                elseif isValidHit&&strcmp(iMode,'dragRoadEditPoint')

                    editPointId=this.RoadEditPointId;
                    if isempty(editPointId)
                        return;
                    end
                    roadID=this.RoadID;
                    roadSpec=app.RoadSpecifications(roadID);
                    if this.IsDraggingStart
                        this.RoadEditPointCache=getPvPairsCacheForEditPointDrag(roadSpec);
                        this.IsDraggingStart=false;
                    end


                    [cp,xUnitsPerPixel]=getCurrentPoint(this);

                    pvPairs=getPvPairsForEditPointDrag(roadSpec,editPointId,cp,xUnitsPerPixel);

                    lkgPvPairs=getPvPairsCacheForEditPointDrag(roadSpec);
                    applyPvPairs(roadSpec,pvPairs);

                    err=showRoadOutlines(this,roadSpec);
                    if isempty(err)
                        clearAllMessages(this);
                        this.RoadEditPointDragPvPairs=pvPairs;
                    else
                        applyPvPairs(roadSpec,lkgPvPairs);
                        errorMessage(this,err,'');
                    end




                    showRoadCenterMarker(this,cp);
                    this.ShouldDirty=true;
                    notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(roadSpec,'Centers'));
                    tooltip=getCursorText(this);
                    shouldDrawnow=true;
                elseif isValidHit&&strcmp(iMode,'dragRoad')


                    if isempty(this.RoadID)
                        onButtonUp(this);
                        return
                    end

                    roadSpec=app.RoadSpecifications(this.RoadID);

                    if this.IsDraggingStart
                        this.IsDraggingStart=false;
                    end


                    offset=getCurrentPoint(this)-this.InitialPoint;
                    this.DragOffset=offset;
                    showRoadOutlines(this,roadSpec,offset);
                    this.ShouldDirty=true;
                    notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(roadSpec,'Centers'));
                    shouldDrawnow=true;
                elseif isValidHit&&strcmp(iMode,'dragBarrierEditPoint')

                    editPointId=this.BarrierEditPointId;
                    if isempty(editPointId)
                        return;
                    end
                    barrierID=this.BarrierID;
                    barrierSpec=app.BarrierSpecifications(barrierID);
                    if this.IsDraggingStart
                        this.BarrierEditPointCache=getPvPairsCacheForEditPointDrag(barrierSpec);
                        this.IsDraggingStart=false;
                    end


                    [cp,xUnitsPerPixel]=getCurrentPoint(this);

                    pvPairs=getPvPairsForEditPointDrag(barrierSpec,editPointId,cp,xUnitsPerPixel);

                    lkgPvPairs=getPvPairsCacheForEditPointDrag(barrierSpec);

                    applyPvPairs(barrierSpec,pvPairs);

                    err=showBarrierOutlines(this,barrierSpec);
                    if isempty(err)
                        clearAllMessages(this);
                        this.BarrierEditPointDragPvPairs=pvPairs;
                    else
                        applyPvPairs(barrierSpec,lkgPvPairs);
                        errorMessage(this,err,'');
                    end




                    showBarrierCenterMarker(this,cp);
                    this.ShouldDirty=true;
                    notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(barrierSpec,'Centers'));
                    tooltip=getCursorText(this);
                    shouldDrawnow=true;
                elseif isValidHit&&strcmp(iMode,'dragBarrier')


                    if isempty(this.BarrierID)
                        onButtonUp(this);
                        return
                    end

                    barrierSpec=app.BarrierSpecifications(this.BarrierID);

                    if this.IsDraggingStart
                        this.IsDraggingStart=false;
                    end


                    offset=getCurrentPoint(this)-this.InitialPoint;
                    this.DragOffset=offset;
                    showBarrierOutlines(this,barrierSpec,offset);
                    this.ShouldDirty=true;
                    notify(this,'PropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(barrierSpec,'Centers'));
                    shouldDrawnow=true;
                elseif isValidHit&&contains(tag,'RoadEditPoint')



                    road=hitObject.UserData;
                    [cp,~,UnitsPerPixel]=getCurrentPoint(this);

                    pt=getEditPointId(road,cp,UnitsPerPixel);

                    if isempty(pt)
                        tooltip=road.Name;
                    else
                        tooltip=getString(message('driving:scenarioApp:RoadCenterTooltip',road.Name,pt));
                    end

                    this.Figure.Pointer='circle';
                    this.PreviousMousePointer=currPointer;
                elseif isValidHit&&contains(tag,'BarrierEditPoint')



                    barrier=hitObject.UserData;
                    [cp,~,UnitsPerPixel]=getCurrentPoint(this);

                    pt=getEditPointId(barrier,cp,UnitsPerPixel);

                    if isempty(pt)
                        tooltip=barrier.Name;
                    else
                        tooltip=getString(message('driving:scenarioApp:RoadCenterTooltip',barrier.Name,pt));
                    end

                    this.Figure.Pointer='circle';
                    this.PreviousMousePointer=currPointer;
                elseif isValidHit&&contains(tag,{'ActorPatch','Road','BarrierPatch','RoadHighlight','RotateLine','RotateNode','EgoIndicator','PoseIndicator'})


                    pointer='hand';
                    if contains(tag,'Road')
                        spec=this.CurrentSpecification;
                        cp=getCurrentPoint(this);
                        if~isa(spec,'driving.internal.scenarioApp.road.Specification')||~isPointInRoad(spec,cp)
                            spec=findRoadWithPoint(app.RoadSpecifications,cp);
                        end

                        if isempty(spec)||strcmp(iMode,'pan')
                            tooltip='';
                        else
                            tooltip=spec.Name;
                        end

                        if isempty(spec)||~this.EnableRoadInteractivity
                            pointer=currPointer;
                        end
                    elseif contains(tag,'Barrier')
                        index=graphicalObjectToIndex(this,hitObject);
                        barrier=app.BarrierSpecifications(index);
                        this.BarrierID=index;
                        tooltip=barrier.Name;
                    else
                        allActorSpecs=app.ActorSpecifications;
                        if contains(tag,'ActorPatch')
                            index=graphicalObjectToIndex(this,hitObject);
                            actor=allActorSpecs(index);
                        else
                            actor=hitObject.UserData;
                            index=find(actor==allActorSpecs,1,'first');
                        end
                        this.ActorID=index;
                        hoverActor=actor;
                        tooltip=actor.Name;
                        if contains(tag,'RotateNode')
                            scenarioActor=getActorFromScenario(this,actor);
                            if~isempty(scenarioActor)
                                interp='tex';
                                tooltip=getString(message('driving:scenarioApp:RotateActorTooltip',tooltip,deg2str(scenarioActor.Yaw)));
                            end
                        elseif contains(tag,'PoseIndicator')
                            scenarioActor=getActorFromScenario(this,actor);
                            interp='tex';
                            pos=scenarioActor.Position;
                            tooltip=getString(message('driving:scenarioApp:PoseIndicatorTooltip',tooltip,num2str(pos(1)),num2str(pos(2)),deg2str(scenarioActor.Yaw)));
                        elseif isequal(index,app.EgoCarId)
                            tooltip=sprintf('%s (%s)',tooltip,getString(message('driving:scenarioApp:EgoCarText')));
                        end
                    end
                    this.Figure.Pointer=pointer;
                    this.PreviousMousePointer=currPointer;
                elseif isValidHit&&contains(tag,{'WaylineActor','WaypointActor'})



                    if contains(tag,'WaylineActor')
                        actorID=str2double(extractAfter(tag,"WaylineActor"));
                    else
                        actorID=str2double(extractAfter(tag,"WaypointActor"));
                    end
                    actor=app.ActorSpecifications(actorID);
                    tooltip=actor.Name;
                    if isequal(actorID,app.EgoCarId)
                        tooltip=sprintf('%s (%s)',tooltip,getString(message('driving:scenarioApp:EgoCarText')));
                    end
                    [cp,xUnitsPerPixel]=getCurrentPoint(this);
                    if isOverWaypoint(this,actor,cp)||contains(tag,'WaypointActor')
                        K=actor.getMatchingPointIndex(cp,actor.Waypoints,xUnitsPerPixel);
                        if isempty(K)


                            restoreMousePointer(this);
                        else



                            actors=app.ActorSpecifications;
                            isSpawn=arrayfun(@(thisActor)any(thisActor.EntryTime>0),actors);
                            isDespawn=arrayfun(@(thisActor)any(thisActor.ExitTime<inf),actors);
                            isWait=arrayfun(@(thisActor)any(thisActor.WaitTime>0),actors);
                            if any(isSpawn)||any(isDespawn)||any(isWait)
                                scenarioActor=getActorFromScenario(this,actor);
                                arrivalTimes=scenarioActor.MotionStrategy.ArrivalTimes;
                                tooltip=getString(message('driving:scenarioApp:ActorWaypointTimeTooltip',actor.Name,num2str(K),num2str(arrivalTimes(K),'%g')));
                            else
                                tooltip=getString(message('driving:scenarioApp:ActorWaypointTooltip',actor.Name,num2str(K)));
                            end
                            this.Figure.Pointer='circle';
                            this.PreviousMousePointer=currPointer;
                        end
                    else
                        this.Figure.Pointer='hand';
                        this.PreviousMousePointer=currPointer;
                    end
                elseif strcmp(this.InteractionMode,'pan')
                    iPoint=this.InitialPoint;
                    cPoint=getCurrentPoint(this);
                    if isequal(size(iPoint),size(cPoint))
                        drag=this.InitialPoint-getCurrentPoint(this);
                        this.Center=this.Center+drag(1:2);
                        updateLimits(this);
                        this.PanHasOccurred=true;
                    end
                else
                    updateCursorLine(this,[]);

                    restoreMousePointer(this);
                end
            end
            updatePoseIndicator(this,hoverActor);
            updateActorRotator(this,hoverActor);
            setTooltipString(this,tooltip,interp);
            this.ClickIndexStale=true;
            if shouldDrawnow
                drawnow limitrate;
            end
        end

        function performButtonUp(this,~,~)


            app=this.Application;
            reenableUndoRedo=false;
            isPan=strcmp(this.InteractionMode,'pan');
            if this.IsDoubleClick||isPan
                this.InteractionMode='none';
                reenableUndoRedo=true;
            end
            if isPan&&~this.PanHasOccurred
                if~isempty(this.CurrentSpecification)&&isa(this.CurrentSpecification,'driving.internal.scenarioApp.ActorSpecification')
                    app.ActorProperties.SpecificationIndex=this.CurrentSpecification(end).ActorID;
                end
                this.CurrentSpecification=[];
                update(app.ActorProperties);
            end
            iMode=this.InteractionMode;
            if any(strcmp(iMode,{'dragActor','dragActorWaypoint','dragActorWayline'}))
                indexToRemove=this.CurrentIndexToRemove;
                indexToRemove(indexToRemove>numel(this.CurrentSpecification))=[];
                if~isempty(indexToRemove)
                    this.CurrentSpecification(indexToRemove)=[];
                    update(app.ActorProperties);
                end
                edit=[];
                actor=app.ActorSpecifications(this.ActorID);
                if strcmp(iMode,'dragActor')
                    otherActors=this.CurrentSpecification;
                    otherActors(otherActors==actor)=[];
                    if~isempty(this.CachedPosition)

                        pActor=[actor;otherActors(:)];
                        for i=1:numel(pActor)
                            oldPos{i}=this.CachedPosition(i,:);
                            newPos{i}=pActor(i).Position;
                            zPos(i)=newPos{i}(3)>0.2;
                            if isempty(pActor(i).Waypoints)
                                nWaypoints{i}=[];
                                oWaypoints{i}=[];
                            else
                                way=pActor(i).Waypoints;
                                nWaypoints{i}=way;
                                way(1,:)=oldPos{i};
                                oWaypoints{i}=way;
                            end
                        end
                        if isequal(newPos,oldPos)
                            edit=[];
                        else
                            edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                                app,pActor,{'Position','Waypoints'},[newPos;nWaypoints]',[oldPos;oWaypoints]');
                        end

                        if any(zPos)
                            indx=find(zPos==1);
                            for i=1:numel(indx)
                                checkForRoadJunctionNotification(this,newPos{indx(i),:});
                            end
                        end
                    end
                else

                    if isempty(this.CachedWaypoints)
                        edit=[];
                    else
                        edit=driving.internal.scenarioApp.undoredo.SetActorProperty(...
                            app,actor,'Waypoints',actor.Waypoints,this.CachedWaypoints);
                    end
                end
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                if~isempty(edit)
                    addEditNoApply(app,edit);
                    notify(app,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(edit.Object,edit.Property));
                    if~isempty(actor.Waypoints)
                        clearCaches(this.Application.Simulator);
                    end
                end
                if this.ShouldDirty
                    app.setDirty;
                    this.ShouldDirty=false;
                end



                addButtonDownCallback(this);
                addContextMenus(this);
                updateActorRotator(this,actor);
                updateBirdsEyePlot(app);
                reenableUndoRedo=true;
            elseif strcmp(iMode,'marqueeSelect')

                ids=getMarqueeSelectIds(this);

                app=this.Application;
                this.CurrentSpecification=app.ActorSpecifications(ids);

                actorProps=app.ActorProperties;
                if isempty(ids)
                    actorProps.SpecificationIndex=1;
                else
                    actorProps.SpecificationIndex=ids;
                end
                update(actorProps);

                set(this.Marquee,'Visible',false);
                this.InteractionMode='none';
            elseif strcmp(iMode,'rotateActor')



                actor=app.ActorSpecifications(this.ActorID);
                otherActors=this.CurrentSpecification;
                otherActors(otherActors==actor)=[];
                rActor=[actor;otherActors(:)];
                newYaw=[rActor.Yaw]';
                if isempty(this.CachedYaw)
                    edit=[];
                elseif~all(cellfun(@isempty,{rActor.Waypoints}))
                    for i=1:numel(rActor)
                        nYaw{i}=rActor(i).Yaw;
                        oYaw{i}=this.CachedYaw(i);
                        if isempty(rActor(i).Waypoints)
                            nwYaw{i}=[];
                            owYaw{i}=[];
                        else
                            wYaw=rActor(i).pWaypointsYaw;
                            nwYaw{i}=wYaw;
                            if(rActor(i).Speed<0)
                                wYaw(1)=this.CachedYaw(i)-180;
                            else
                                wYaw(1)=this.CachedYaw(i);
                            end
                            owYaw{i}=wYaw;
                        end
                    end
                    edit=driving.internal.scenarioApp.undoredo.SetMultipleActorProperties(...
                        app,rActor,{'Yaw','WaypointsYaw'},[nYaw;nwYaw]',[oYaw;owYaw]');
                else
                    edit=driving.internal.scenarioApp.undoredo.SetActorProperty(...
                        app,rActor,'Yaw',newYaw,this.CachedYaw);
                end

                this.InteractionMode='none';
                this.IsDraggingStart=false;

                if~isempty(edit)
                    addEditNoApply(app,edit);
                    notify(app,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(edit.Object,edit.Property));
                end
                if this.ShouldDirty
                    app.setDirty;
                    this.ShouldDirty=false;
                end
                updateBirdsEyePlot(app);
                updateActor(this,[rActor.ActorID],true);
                for i=1:numel(actor)
                    updateActorRotator(this,rActor(i));
                end
                reenableUndoRedo=true;

                updateHighlight(this);

            elseif any(strcmp(iMode,{'dragRoadEditPoint','dragRoad'}))

                clearAllMessages(this);
                resetRoadOutlines(this);
                resetRoadCenterMarker(this);
                update(app.RoadProperties);
                roadSpec=app.RoadSpecifications(this.RoadID);
                oldValues={};
                if strcmp(iMode,'dragRoad')
                    offset=getCurrentPoint(this)-this.InitialPoint;
                    if all(offset==0)||isempty(offset)
                        pvPairs={};
                    else
                        pvPairs=getPvPairsForDrag(roadSpec,offset);
                    end
                elseif isempty(this.RoadEditPointId)
                    pvPairs={};
                else
                    pvPairs=this.RoadEditPointDragPvPairs;
                    oldValues=this.RoadEditPointCache(2:2:end);
                    if numel(oldValues)>2
                        oldValues={oldValues};
                    elseif isempty(oldValues)
                        oldValues={};
                    end
                end
                isStarted=~this.IsDraggingStart;
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                if isStarted
                    applyRoadPvPairs(this,pvPairs,oldValues{:});
                end
                reenableUndoRedo=true;

            elseif any(strcmp(iMode,{'dragBarrierEditPoint','dragBarrier'}))

                clearAllMessages(this);
                resetBarrierOutlines(this);
                resetBarrierCenterMarker(this);
                update(app.BarrierProperties());
                barrierSpec=app.BarrierSpecifications(this.BarrierID);
                oldValues={};
                if strcmp(iMode,'dragBarrier')
                    offset=getCurrentPoint(this)-this.InitialPoint;
                    if all(offset==0)
                        pvPairs={};
                    else
                        pvPairs=getPvPairsForDrag(barrierSpec,offset);
                    end
                elseif isempty(this.BarrierEditPointId)
                    pvPairs={};
                else
                    pvPairs=this.BarrierEditPointDragPvPairs;
                    oldValues=this.BarrierEditPointCache(2:2:end);
                    if numel(oldValues)>2
                        oldValues={oldValues};
                    elseif isempty(oldValues)
                        oldValues={};
                    end
                end
                this.InteractionMode='none';
                this.IsDraggingStart=false;
                applyBarrierPvPairs(this,pvPairs,oldValues{:});
                reenableUndoRedo=true;
            end
            if reenableUndoRedo
                enableUndoRedo(app);
            end
            if~strcmp(get(getFigure(this),'SelectionType'),'open')||strcmp(this.Keyboard.PressedKey,'shift')
                focusOnComponent(this);
            end
            this.ClickIndexStale=true;
        end

        function updateHelperTextForLimits(this,~,~)
            updateHelpText(this);
        end

        function updateHelpText(this)

            hText=this.HelpText;
            if isempty(hText)||~ishghandle(hText)||isempty(hText.UserData)
                return;
            end
            hAxes=hText.Parent;
            hText.String=matlabshared.application.wrapText(hText.UserData,hText,hAxes);
            hText.Position=[mean(hAxes.XLim),mean(hAxes.YLim),hAxes.ZLim(2)];
        end

        function b=isOverWaypoint(this,actor,point)
            [x,y]=getHVUnitsPerPixel(this);
            if x<y
                x=y;
            end

            distance=sqrt(sum(((actor.Waypoints-point)/x).^2,2));
            b=any(distance<6);
        end

        function b=getShowRoadEditPoints(this)
            isSimStopped=isStopped(this.Application.Simulator);
            b=(this.ShowRoadEditPointsDuringSim&&~isSimStopped)...
                ||(this.EnableRoadInteractivity&&isSimStopped);
            if b
                b=this.ShowRoadEditPoints;
            end
        end

        function b=getShowWaypoints(this)
            b=this.ShowWaypointsDuringSim||isStopped(this.Application.Simulator);
        end

        function checkForRoadJunctionNotification(this,newPos)
            [~,~,isOnSuperTile]=getHeightInClickedPoint(this,newPos(1:2));
            bannerTimer=timerfind('Tag','RoadJunctionInvalidHeight');
            if isOnSuperTile
                if isempty(bannerTimer)
                    this.elevatedRoadJunctionTimerCallback();
                end
            else
                if~isempty(bannerTimer)
                    stop(bannerTimer);
                end
            end
        end

        function tableData=addEmptiesToTable(this,tableData,zValue)
            if nargin<3
                zValue=0;
            end
            nextRow={'','',zValue};
            if size(tableData,2)>=4
                speed=vertcat(tableData{:,4});
                lastSpeed=speed(find(speed~=0,1,'last'));
                if this.Application.ActorProperties.AddingReverseMotion



                    if abs(lastSpeed)>20
                        lastSpeed=-driving.scenario.Path.DefaultReverseSpeed;
                    else
                        lastSpeed=-abs(lastSpeed);
                    end
                else
                    lastSpeed=abs(lastSpeed);
                end
                nextRow=[nextRow,{lastSpeed}];
            end

            if size(tableData,2)==5
                nextRow=[nextRow,{0}];
            end


            if size(tableData,2)==6
                nextRow=[nextRow,{0},{''}];
            end
            tableData=[tableData;nextRow];
        end

        function ids=findActorIDsInBox(this,point1,point2)
            if nargin<3
                point2=getCurrentPoint(this);
            end
            if nargin<2
                point1=this.ClickLocation;
            end
            x1=min(point1(1),point2(1));
            x2=max(point1(1),point2(1));
            y1=min(point1(2),point2(2));
            y2=max(point1(2),point2(2));

            actors=this.Application.ActorSpecifications;
            ids=false(1,numel(actors));
            for indx=1:numel(actors)
                pos=actors(indx).Position;
                if pos(1)>x1&&pos(1)<x2&&pos(2)>y1&&pos(2)<y2
                    ids(indx)=true;
                end
            end
            ids=find(ids);
        end

        function newIds=getMarqueeSelectIds(this,varargin)
            ids=findActorIDsInBox(this,varargin{:});
            currentSpecs=this.CurrentSpecification;
            if isempty(currentSpecs)||~isa(currentSpecs,'driving.internal.scenarioApp.ActorSpecification')
                currentIds=[];
            else
                currentIds=[currentSpecs.ActorID];
            end
            [~,a,b]=union(currentIds,ids);
            newIds=[currentIds(a),ids(b)];
        end

        function availableRoadEdgeLines=findAvailableSegmentsForRoadEdge(this,road,roadEdge)
            roadSegment=this.Application.Scenario.RoadSegments(road.RoadID);
            switch roadEdge
                case 'left'
                    if~isempty(roadSegment.LeftNonOverlappingSegments)
                        availableSegments=roadSegment.LeftNonOverlappingSegments;
                    else
                        availableSegments={roadSegment.LeftBoundary};
                    end
                case 'right'
                    if~isempty(roadSegment.RightNonOverlappingSegments)
                        availableSegments=roadSegment.RightNonOverlappingSegments;
                    else
                        availableSegments={roadSegment.RightBoundary};
                    end
            end
            occupiedIdxs=[];
            for i=1:numel(this.Application.BarrierSpecifications)
                spec=this.Application.BarrierSpecifications(i);
                if isequal(spec.Road,road)&&strcmp(spec.RoadEdge,roadEdge)
                    segmentMatch=cellfun(@(x)isequal(trimBarrierCenters(x),spec.BarrierCenters),...
                        availableSegments,'UniformOutput',true);
                    occupiedIdxs=[occupiedIdxs,find(segmentMatch==true)];
                end
            end
            availableIdxs=setdiff(1:numel(availableSegments),occupiedIdxs);
            availableRoadEdgeLines=availableSegments(availableIdxs);
        end
    end
end

function pvPairs=addRoadToBarrierPVPair(pvPairs,barrier)
if isempty(pvPairs)
    return;
end
if any(strcmp(pvPairs,'BarrierCenters'))
    barrier.BarrierCentersChanged=true;
    if~isempty(barrier.Road)
        pvPairs{end+1}='Road';
        pvPairs{end+1}=[];
        pvPairs{end+1}='RoadEdge';
        pvPairs{end+1}=[];
    end
end
end

function menu=createMenu(h,tag,cb,varargin)

menu=uimenu(h,...
    'Tag',tag,...
    'Callback',cb,...
    varargin{:});

if isempty(menu.Label)
    menu.Label=getString(message(['driving:scenarioApp:',tag,'Label']));
end

end

function[x,y,z]=rbsToXyz(rbs)

rbs=[rbs;repmat({[NaN,NaN,NaN]},1,numel(rbs))];

xyz=vertcat(rbs{:});
x=xyz(:,1);
y=xyz(:,2);
z=xyz(:,3);
x(end)=[];
y(end)=[];
z(end)=[];

end

function[cut,copy,paste,delete,addRoadCenter,addBarrierCenter]=findCutCopyPasteDeleteMenus(h)

cut=findobj(h,'Tag','CutItem');
copy=findobj(h,'Tag','CopyItem');
paste=findobj(h,'Tag','PasteItem');
delete=findobj(h,'Tag','DeleteItem');
addRoadCenter=findobj(h,'Tag','AddRoadCenter');
addBarrierCenter=findobj(h,'Tag','AddBarrierCenter');
end

function applyPvPairs(object,pvPairs)

for indx=1:2:numel(pvPairs)
    object.(pvPairs{indx})=pvPairs{indx+1};
end

end

function xy=rotate2d(xy,yaw)

xy=xy*[cosd(yaw),-sind(yaw);sind(yaw),cosd(yaw)];

end

function str=deg2str(deg)
str=[num2str(deg),'{\circ}'];
end

function[road,roadEdgeLine,roadEdge]=getRoadEdgeLineForBarrier(roadSegments,point,barrierSpecs,multiHighlight)
segments={};
segmentLocations={};
roadIDs=[];

road=[];
roadEdgeLine={};
roadEdge={};

if isempty(roadSegments)
    return;
end


for i=1:numel(roadSegments)
    currentRoad=roadSegments(i);
    if~isempty(currentRoad.LeftNonOverlappingSegments)
        segments=[segments,currentRoad.LeftNonOverlappingSegments];
        num=numel(currentRoad.LeftNonOverlappingSegments);
        [segmentLocations{end+1:end+num}]=deal('left');
        roadIDs(end+1:end+num)=currentRoad.RoadID;
    else
        segments{end+1}=currentRoad.LeftBoundary;
        segmentLocations{end+1}='left';
        roadIDs(end+1)=currentRoad.RoadID;
    end
    if~isempty(currentRoad.RightNonOverlappingSegments)
        segments=[segments,currentRoad.RightNonOverlappingSegments];
        num=numel(currentRoad.RightNonOverlappingSegments);
        [segmentLocations{end+1:end+num}]=deal('right');
        roadIDs(end+1:end+num)=currentRoad.RoadID;
    else
        segments{end+1}=currentRoad.RightBoundary;
        segmentLocations{end+1}='right';
        roadIDs(end+1)=currentRoad.RoadID;
    end
end


occupiedIdxs=[];
for i=1:numel(barrierSpecs)
    segmentMatch=cellfun(@(x)isequal(trimBarrierCenters(x),barrierSpecs(i).BarrierCenters),...
        segments,'UniformOutput',true);
    occupiedIdxs=[occupiedIdxs,find(segmentMatch==true)];
end
segments(occupiedIdxs)=[];
segmentLocations(occupiedIdxs)=[];
roadIDs(occupiedIdxs)=[];


minDist=@(x)min(sum((x(:,1:2)-point(:,1:2)).^2,2));
distances=cellfun(minDist,segments);
[~,minIdx]=min(distances);


if distances(minIdx)<1
    if multiHighlight

        edge=segmentLocations{minIdx};
        roadID=roadIDs(minIdx);

        edgeIdxs=find(contains(segmentLocations,edge));
        roadIDIdxs=find(roadIDs==roadID);
        newIdxs=intersect(edgeIdxs,roadIDIdxs);
        roadEdgeLine=segments(newIdxs);
        roadEdge=segmentLocations(newIdxs);
        road=roadSegments(roadID);
    else
        roadEdgeLine=segments(minIdx);
        roadEdge=segmentLocations(minIdx);
        road=roadSegments(roadIDs(minIdx));
    end
end
end

function trimmedBarrierCenters=trimBarrierCenters(barrierCenters)



barrierCenters=round(barrierCenters,3);
isCollinear=rank(barrierCenters(2:end,:)-barrierCenters(1,:))==1;

if isCollinear
    trimmedBarrierCenters=[barrierCenters(1,:);barrierCenters(end,:)];
else
    numBarrierCenters=size(barrierCenters,1);
    if numBarrierCenters<=10
        separator=ceil(0.2*numBarrierCenters);
    else
        separator=ceil(0.1*numBarrierCenters);
    end
    trimmedIdxs=1:separator:numBarrierCenters;
    if~any(trimmedIdxs==numBarrierCenters)
        trimmedIdxs=[trimmedIdxs,numBarrierCenters];
    end
    trimmedBarrierCenters=barrierCenters(trimmedIdxs,:);
end
end



