classdef ScenarioView<fusion.internal.scenarioApp.component.BaseComponent

    properties(SetAccess=protected,Hidden)
        ScenarioPlotter=[]
        GroundPlotter=[]
        CoveragePlotter=[]
        DetectionPlotter=[]
        DetectionHistoryPlotter=[]
        GroundPatch=matlab.graphics.primitive.Patch.empty
        IndicatorBtn=matlab.ui.controls.ToolbarStateButton.empty
        SnapXYBtn=matlab.ui.controls.ToolbarStateButton.empty
        SnapXZBtn=matlab.ui.controls.ToolbarStateButton.empty
        SnapYZBtn=matlab.ui.controls.ToolbarStateButton.empty
        CoverageBtn=matlab.ui.controls.ToolbarStateButton.empty
        GroundBtn=matlab.ui.controls.ToolbarStateButton.empty
        TrajectoryBtn=matlab.ui.controls.ToolbarStateButton.empty
        Axes=[]
        AxesPanel=matlab.ui.container.Panel.empty
        IndicationPanel=matlab.ui.container.Panel.empty
        OrientationIndicator=[]
        ScrubberPanel=matlab.ui.container.Panel.empty
        Scrubber=[]
WindowMouseMotionListener
AxesViewListener
PanButton
RotateButton
ZoomInValueChangedFcn
ZoomOutValueChangedFcn
CameraButtonDownFcn
    end

    methods
        function this=ScenarioView(varargin)
            this@fusion.internal.scenarioApp.component.BaseComponent(varargin{:});


            addToolbarBtns(this);

            this.ScenarioPlotter=fusion.internal.scenarioApp.plotter.ScenarioPlotter(this.Axes);
            this.ScenarioPlotter.PlatformPositionTag='platform.position.xyz';
            this.ScenarioPlotter.PlatformExtentTag='platform.extent.xyz';
            this.ScenarioPlotter.TrajectoryTag='trajectory.xyz';
            this.ScenarioPlotter.WaypointsTag='waypoints.xyz';
            this.ScenarioPlotter.ShowTrajectories=true;
            this.ScenarioPlotter.ShowWaypoints=true;
            this.ScenarioPlotter.ShowCurrentWaypoint=true;
            this.GroundPlotter=fusion.internal.scenarioApp.plotter.ScenarioPlotter(this.Axes);
            this.GroundPlotter.ProjectOntoXYPlane=true;
            this.GroundPlotter.GreyMode=true;
            this.GroundPlotter.PlatformPositionTag='platform.position.xys';
            this.GroundPlotter.PlatformExtentTag='platform.extent.xys';
            this.GroundPlotter.TrajectoryTag='trajectory.xys';
            this.GroundPlotter.WaypointsTag='waypoints.xys';
            this.CoveragePlotter=fusion.internal.scenarioApp.plotter.CoveragePlotter(this.Axes);
            this.DetectionPlotter=fusion.internal.scenarioApp.plotter.DetectionPlotter(this.Axes);
            this.DetectionHistoryPlotter=fusion.internal.scenarioApp.plotter.DetectionPlotter(this.Axes);
            this.DetectionHistoryPlotter.FaceAlpha=0.2;
            updateIndicator(this);
        end

        function update(this,resetLimits)

            platforms=this.Application.getPlatforms();
            current=this.Application.getCurrentPlatform;
            playbackEntry=this.Application.currentPlaybackEntry;
            playbackHistory=this.Application.previousPlaybackEntries(10);

            this.CoveragePlotter.Visible='off';


            updateGround(this,platforms,current,playbackEntry);

            updatePlatformPoses(this,platforms,current,playbackEntry);

            updateCurrentWaypoint(this);

            if nargin==1
                resetLimits=true;
            end
            [xLim,yLim,zLim]=autoLimits(this,resetLimits);

            updateDetections(this,playbackHistory);

            updateGroundPlane(this,xLim,yLim);


            updateSensorCoverage(this,playbackEntry);

            updateScrubber(this,playbackEntry);

            restoreLimits(this,xLim,yLim,zLim);
        end

        function updateCurrentWaypoint(this)
            current=this.Application.getCurrentPlatform;
            currentWaypoint=this.Application.getCurrentWaypoint;

            if this.Application.EnableGround
                this.GroundPlotter.updateCurrentWaypoint(current,currentWaypoint);
            else
                this.GroundPlotter.updateCurrentWaypoint(current,0);
            end
            this.ScenarioPlotter.updateCurrentWaypoint(current,currentWaypoint);
        end

        function onTrajectoryChanged(this)
            update(this);
        end

        function updateSimulation(this)
            update(this);
        end

        function onSensorDeleted(this,toDelete)
            clear(this.CoveragePlotter,toDelete);
        end

        function onRecordSelected(this)
            update(this,false);
        end

        function onPlaybackStarted(this)



            resetSensorCoverages(this);
            clear(this.DetectionPlotter);
            clear(this.DetectionHistoryPlotter);
            update(this,false);
        end

        function onPlaybackRestarted(this)



            resetSensorCoverages(this);
            clear(this.DetectionPlotter);
            clear(this.DetectionHistoryPlotter);
            update(this,false);
        end

        function onPlaybackStopped(this)
            resetSensorCoverages(this);
            clear(this.DetectionPlotter);
            clear(this.DetectionHistoryPlotter);
            update(this,false);
        end

        function onRecordStarted(this)
            totalTime=this.Application.getSimulationTotalTime();
            setTotalTime(this.Scrubber,totalTime);
            resize(this);
        end

        function onRecordLogged(this)
            updateRecordSpan(this);
        end

        function setTimeStatus(this,timeStr)
            setTimeStatus(this.Scrubber,timeStr);
        end
    end

    methods(Access=protected)
        function updateDetections(this,records)
            if isempty(records)
                clear(this.DetectionPlotter);
                clear(this.DetectionHistoryPlotter);
            else
                current=records(end);
                history=records(1:end-1);
                this.DetectionPlotter.plotDetections(current.DetectionPositions);
                this.DetectionHistoryPlotter.plotDetections(vertcat(history.DetectionPositions))
            end
        end

        function updateGroundPlane(this,xLim,yLim)
            this.GroundBtn.Value=this.Application.EnableGround;
            if this.Application.EnableGround
                if isempty(this.GroundPatch)
                    this.GroundPatch=patch(this.Axes,xLim([1,1,2,2]),yLim([1,2,2,1]),zeros(1,4),[.5,.5,.5],'FaceAlpha',.1,'EdgeAlpha',.1,'XLimInclude','off','YLimInclude','off','tag','groundplane');
                else
                    set(this.GroundPatch,'XData',xLim([1,1,2,2]),'YData',yLim([1,2,2,1]),'ZData',zeros(1,4));
                end
            else
                delete(this.GroundPatch)
                this.GroundPatch=[];
            end
        end

        function updatePlatformPoses(this,platforms,current,playbackEntry)
            this.TrajectoryBtn.Value=this.Application.EnableTrajectories;
            this.ScenarioPlotter.ShowTrajectories=this.Application.EnableTrajectories;
            this.ScenarioPlotter.ShowWaypoints=this.Application.EnableTrajectories&this.Application.EnableWaypoints;
            this.ScenarioPlotter.ShowCurrentWaypoint=this.Application.EnableTrajectories&this.Application.EnableWaypoints;
            this.ScenarioPlotter.HighlightCurrentPlatform=isPlaybackStopped(this.Application);
            this.ScenarioPlotter.update(platforms,current,playbackEntry);
        end

        function updateGround(this,platforms,current,playbackEntry)
            this.GroundPlotter.ShowTrajectories=this.Application.EnableTrajectories;
            this.GroundPlotter.ShowWaypoints=this.Application.EnableTrajectories&this.Application.EnableWaypoints;
            this.GroundPlotter.ShowCurrentWaypoint=this.Application.EnableTrajectories&this.Application.EnableWaypoints;
            this.GroundPlotter.HighlightCurrentPlatform=isPlaybackStopped(this.Application);
            if this.Application.EnableGround
                this.GroundPlotter.update(platforms,current,playbackEntry);
            else
                this.GroundPlotter.clear;
            end
        end

        function updateSensorCoverage(this,playbackEntry)
            editMode=isempty(playbackEntry);
            this.CoverageBtn.Value=this.Application.EnableCoverage;
            if~this.Application.EnableCoverage||(~editMode&&strcmp(playbackEntry.SimulationMode,'nodetections'))
                this.CoveragePlotter.Visible='off';
            else
                this.CoveragePlotter.Visible='on';
                if editMode


                    clear(this.CoveragePlotter);
                end
                [sensors,platformPositions,platformOrientations]=getDataForCoveragePlotter(this,playbackEntry);
                this.CoveragePlotter.plotCoverage(sensors,platformPositions,platformOrientations);
            end
        end

        function updateScrubber(this,playbackEntry)
            if isempty(playbackEntry)
                setCurrentTime(this.Scrubber,0);
            else
                setCurrentTime(this.Scrubber,playbackEntry.SimulationTime);
            end
            updateRecordSpan(this);
        end

        function updateRecordSpan(this)
            [recordStart,recordStop,totalTime]=recordLimits(this.Application);
            if isnan(recordStart)||isnan(recordStop)
                hide(this.Scrubber);
            else
                setTotalTime(this.Scrubber,totalTime);
                setRecordTime(this.Scrubber,recordStop);
                show(this.Scrubber);
                update(this.Scrubber);
            end
        end

        function setLimMode(this,mode)
            hax=this.Axes;
            hax.XLimMode=mode;
            hax.YLimMode=mode;
            hax.ZLimMode=mode;
        end

        function[xLim,yLim,zLim]=autoLimits(this,resetLimits)
            if~resetLimits

                [xLim,yLim,zLim]=cacheLimits(this);
                setLimMode(this,'auto');
            else

                setLimMode(this,'auto');
                [xLim,yLim,zLim]=cacheLimits(this);
                zLim=zLim-zLim(2);


                [xLim,yLim,zLim]=storeDefaultViewLimits(this,xLim,yLim,zLim);
            end
        end

        function[xlim,ylim,zlim]=cacheLimits(this)
            hax=this.Axes;
            xlim=hax.XLim;
            ylim=hax.YLim;
            zlim=hax.ZLim;
        end

        function restoreLimits(this,xlim,ylim,zlim)
            hax=this.Axes;
            hax.XLim=xlim;
            hax.YLim=ylim;
            hax.ZLim=zlim;
        end

        function[xlim,ylim,zlim]=storeDefaultViewLimits(this,xlim,ylim,zlim)


            hax=this.Axes;
            xlim=increaseLims(xlim,1.05);
            ylim=increaseLims(ylim,1.05);
            zlim=increaseLims(zlim,1.05);
            setappdata(hax,'xlim',xlim);
            setappdata(hax,'ylim',ylim);
            setappdata(hax,'zlim',zlim);

            function newLims=increaseLims(oldLims,incr)
                center=mean(oldLims);
                range=diff(oldLims);
                newLims=center+[-0.5,0.5]*range.*incr;
            end
        end
    end

    methods(Access=protected)
        function resetSensorCoverages(this)
            [sensors,positions,orientations]=getDataForCoveragePlotter(this,[]);
            for s=1:numel(sensors)
                resetLookAngle(sensors(s));
            end
            this.CoveragePlotter.plotCoverage(sensors,positions,orientations);

        end

        function[sensors,positions,orientations]=getDataForCoveragePlotter(this,record)
            sensors=this.Application.getAllSensors;
            num=numel(sensors);
            positions=zeros(num,3);
            orientations=zeros(num,3);
            if isempty(record)
                for i=1:num
                    platform=this.Application.getPlatformByID(sensors(i).PlatformID);
                    positions(i,:)=platform.Position;
                    orientations(i,:)=platform.Orientation;
                end
            else
                toDelete=[];
                for i=1:num
                    sensor=sensors(i);

                    platform=this.Application.getPlatformByID(sensors(i).PlatformID);
                    sid=platform.SimID;
                    lookangles=record.LookAngles(record.LookAngles(:,1)==sensor.ID,[2,3]);
                    sensor.LookAngle=lookangles';
                    ind=find([record.Poses.PlatformID]==sid);
                    if isempty(ind)


                        toDelete=[toDelete,i];%#ok<AGROW>
                        continue
                    end
                    positions(i,:)=record.Poses(ind).Position;
                    orientations(i,:)=fliplr(eulerd(record.Poses(ind).Orientation,'ZYX','frame'));
                end
                sensors(toDelete)=[];
                positions(toDelete,:)=[];
                orientations(toDelete,:)=[];
            end

        end
    end

    methods(Access=protected)
        function addToolbarBtns(this)

            axtoolbar(this.Axes,{'zoomin','zoomout','rotate','pan','restoreview'},'Visible','on');

            hApp=this.Application;

            tb=this.Axes.Toolbar;
            resetBtn=findobj(tb,'Tag','restoreview');
            resetBtn.ButtonPushedFcn=@(e,d)localReset(this,e,d);

            rotateBtn=findobj(tb,'Tag','rotate');
            rotateBtn.Tag='localrotate';
            rotateBtn.ValueChangedFcn=@(e,d)localRotate(this,e,d);
            this.RotateButton=rotateBtn;

            panBtn=findobj(tb,'Tag','pan');
            panBtn.Tag='localpan';
            panBtn.ValueChangedFcn=@(e,d)localPan(this,e,d);
            this.PanButton=panBtn;

            zoomInBtn=findobj(tb,'Tag','zoomin');
            this.ZoomInValueChangedFcn=zoomInBtn.ValueChangedFcn;
            zoomInBtn.ValueChangedFcn=@(e,d)localZoomIn(this,e,d);

            zoomOutBtn=findobj(tb,'Tag','zoomout');
            this.ZoomOutValueChangedFcn=zoomOutBtn.ValueChangedFcn;
            zoomOutBtn.ValueChangedFcn=@(e,d)localZoomOut(this,e,d);

            dd=matlab.ui.controls.ToolbarDropdown;
            dd.Icon=iconFile(this,'cube_16.png');
            dd.Parent=tb;



            zbtn=matlab.ui.controls.ToolbarPushButton;
            zbtn.Icon=iconFile(this,'cube_top_16.png');
            zbtn.ButtonPushedFcn=hApp.initCallback(@this.viewZCallback);
            zbtn.Tooltip=msgString(this,'ViewZ');
            ybtn=matlab.ui.controls.ToolbarPushButton;
            ybtn.Icon=iconFile(this,'cube_left_16.png');
            ybtn.ButtonPushedFcn=hApp.initCallback(@this.viewYCallback);
            ybtn.Tooltip=msgString(this,'ViewY');
            xbtn=matlab.ui.controls.ToolbarPushButton;
            xbtn.Icon=iconFile(this,'cube_right_16.png');
            xbtn.ButtonPushedFcn=hApp.initCallback(@this.viewXCallback);
            xbtn.Tooltip=msgString(this,'ViewX');
            dd.addChild(zbtn);
            dd.addChild(ybtn);
            dd.addChild(xbtn);



            abtn=axtoolbarbtn(tb,'state');
            abtn.Icon=iconFile(this,'xyz_axes_16.png');
            abtn.ValueChangedFcn=hApp.initCallback(@this.indicatorCallback);
            abtn.Value=hApp.EnableIndicator;
            abtn.Tooltip=msgString(this,'ViewIndicator');

            covbtn=axtoolbarbtn(tb,'state');
            covbtn.Icon=iconFile(this,'coverage_16.png');
            covbtn.ValueChangedFcn=hApp.initCallback(@this.coverageCallback);
            covbtn.Value=hApp.EnableCoverage;
            covbtn.Tooltip=msgString(this,'CoverageDescription');

            grndbtn=axtoolbarbtn(tb,'state');
            grndbtn.Icon=iconFile(this,'ground_16.png');
            grndbtn.ValueChangedFcn=hApp.initCallback(@this.groundCallback);
            grndbtn.Value=hApp.EnableGround;
            grndbtn.Tooltip=msgString(this,'GroundDescription');

            trajbtn=axtoolbarbtn(tb,'state');
            trajbtn.Icon=iconFile(this,'trajectory_16.png');
            trajbtn.ValueChangedFcn=hApp.initCallback(@this.trajectoriesCallback);
            trajbtn.Value=hApp.EnableTrajectories;
            trajbtn.Tooltip=msgString(this,'TrajectoryDescription');

            this.SnapXYBtn=zbtn;
            this.SnapXZBtn=ybtn;
            this.SnapYZBtn=xbtn;
            this.IndicatorBtn=abtn;
            this.CoverageBtn=covbtn;
            this.GroundBtn=grndbtn;
            this.TrajectoryBtn=trajbtn;

        end

        function fig=createFigure(this,varargin)
            fig=createFigure@fusion.internal.scenarioApp.component.BaseComponent(this,varargin{:});

            this.AxesPanel=uipanel(fig,'Position',[0,0,fig.Position(3:4)],'Units','pixels','BorderType','none','AutoResizeChildren','off');
            this.Axes=axes('Parent',this.AxesPanel,'Tag',[lower(getTag(this)),'Axes'],'OuterPosition',[0,0,1,1]);

            hAxes=this.Axes;
            axis(hAxes,'vis3d');
            set(hAxes,...
            'Projection','orthographic',...
            'ZLimMode','auto',...
            'Color',[0.94,0.94,0.94],...
            'Position',[0,0,1,1]);


            hAxes.XAxis.Visible='off';
            hAxes.YAxis.Visible='off';
            hAxes.ZAxis.Visible='off';
            axis(hAxes,'vis3d');
            view(hAxes,3);


            set(hAxes,...
            'CameraPositionMode','auto',...
            'CameraTargetMode','auto',...
            'CameraUpVectorMode','auto',...
            'CameraViewAngleMode','auto',...
            'YDir','reverse',...
            'ZDir','reverse');


            hAxes.Camera.TransparencyMethodHint='objectsort';

            z=zoom(fig);
            setAxes3DPanAndZoomStyle(z,hAxes,'camera')
            z.ButtonDownFilter=@this.buttonDownFilter;

            this.IndicationPanel=uipanel(fig,'Units','pixels','BorderType','none','AutoResizeChildren','off');
            this.OrientationIndicator=fusion.internal.scenarioApp.plotter.OrientationIndicator(this.IndicationPanel,this.Axes);
            this.AxesPanel.Position=[0,this.OrientationIndicator.PanelHeight,fig.Position(3:4)];

            this.ScrubberPanel=uipanel('Parent',fig,'Units','pixels','Visible','off','BorderType','none','AutoResizeChildren','off');
            this.Scrubber=fusion.internal.scenarioApp.plotter.TimeScrubber(this.ScrubberPanel);
            this.Scrubber.CallbackFcn=@this.scrubberCallback;
        end
    end

    methods
        function tag=getTag(~)
            tag='ScenarioView';
        end

        function resize(this)
            if~isempty(this.Figure)

                h=0;
                figPos=this.Figure.Position;
                if matlab.lang.OnOffSwitchState(this.ScrubberPanel.Visible)
                    h=this.ScrubberPanel.Position(4);
                    this.ScrubberPanel.Position=[0,0,figPos(3),h];
                end

                if this.Application.EnableIndicator
                    indicatorH=this.OrientationIndicator.PanelHeight;
                    this.IndicationPanel.Position=[0,h,figPos(3),indicatorH];
                    h=h+indicatorH;
                end
                this.AxesPanel.Position=[0,h,figPos(3),max(0,figPos(4)-h)];


                if matlab.lang.OnOffSwitchState(this.ScrubberPanel.Visible)
                    update(this.Scrubber);
                end

                if this.Application.EnableIndicator
                    indicate(this.OrientationIndicator);
                end
            end

        end

        function updateIndicator(this)
            this.IndicationPanel.Visible=matlab.lang.OnOffSwitchState(this.Application.EnableIndicator);
            resize(this);
        end

        function setViewAngle(this,az,el)
            view(this.Axes,[az,el]);
        end

        function viewScenarioXY(this)
            setViewAngle(this,0,90);
        end

        function viewScenarioXZ(this)
            setViewAngle(this,0,0);
        end

        function viewScenarioYZ(this)
            setViewAngle(this,90,0);
        end


    end

    methods(Access=private)
        function viewXCallback(this,~,~)
            viewScenarioYZ(this.Application);
        end

        function viewYCallback(this,~,~)
            viewScenarioXZ(this.Application);
        end

        function viewZCallback(this,~,~)
            viewScenarioXY(this.Application);
        end

        function groundCallback(this,~,evt)
            toggleViewGroundPlane(this.Application,evt.Value);
        end

        function trajectoriesCallback(this,~,evt)
            toggleViewTrajectories(this.Application,evt.Value);
        end

        function coverageCallback(this,~,evt)
            toggleViewCoverageArea(this.Application,evt.Value);
        end

        function indicatorCallback(this,~,evt)
            toggleViewIndicator(this.Application,evt.Value);
        end

        function scrubberCallback(this,newTime)
            setNewSimulationTime(this.Application,newTime);
        end

        function flag=buttonDownFilter(~,src,~)

            flag=any(strcmp(src.Tag,{'SliderKnob','PastRange','FutureRange'}));
        end

        function localReset(this,~,d)

            hax=d.Axes;
            matlab.graphics.controls.internal.resetHelper(hax,false);


            view(this.Axes,-37.5,30);


            [xLim,yLim,zLim]=autoLimits(this,true);
            restoreLimits(this,xLim,yLim,zLim);
        end

        function newLims=increaseLims(~,oldLims,incr)
            center=mean(oldLims);
            range=diff(oldLims);
            newLims=center+[-0.5,0.5]*range.*incr;
        end

        function cameraButtonDownFilter(this,src,evt)
            hSrc=hittest(src);
            if~buttonDownFilter(this,hSrc)
                this.CameraButtonDownFcn(src,evt);
            end
        end

        function localRotate(this,~,d)
            this.PanButton.Value='off';
            if matlab.lang.OnOffSwitchState(d.Value)
                cameratoolbar(this.Figure,'SetMode','orbit');
                this.CameraButtonDownFcn=this.Figure.WindowButtonDownFcn;
                this.Figure.WindowButtonDownFcn=@(e,d)cameraButtonDownFilter(this,e,d);
            else
                cameratoolbar(this.Figure,'SetMode','nomode');
            end
        end

        function localPan(this,~,d)
            this.RotateButton.Value='off';
            if matlab.lang.OnOffSwitchState(d.Value)
                cameratoolbar(this.Figure,'SetMode','dollyhv');
                this.CameraButtonDownFcn=this.Figure.WindowButtonDownFcn;
                this.Figure.WindowButtonDownFcn=@(e,d)cameraButtonDownFilter(this,e,d);
            else
                cameratoolbar(this.Figure,'SetMode','nomode');
            end
        end

        function localZoomIn(this,e,d)
            this.RotateButton.Value='off';
            this.PanButton.Value='off';
            this.ZoomInValueChangedFcn(e,d);
        end

        function localZoomOut(this,e,d)
            this.RotateButton.Value='off';
            this.PanButton.Value='off';
            this.ZoomOutValueChangedFcn(e,d);
        end
    end
end
