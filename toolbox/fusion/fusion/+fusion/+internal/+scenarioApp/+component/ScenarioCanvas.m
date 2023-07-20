classdef ScenarioCanvas<fusion.internal.scenarioApp.component.BaseComponent&...
    matlabshared.application.Canvas&...
    matlabshared.application.Zoom




    properties(SetAccess=protected,Hidden)
XYAxes
XYPlotter
XYAxesHelpText

TZAxes
TZPlotter

PlatformToAdd

ContextClickLocation

CanvasModes
CanvasMode
    end

    properties(Hidden)

ActiveCanvas
CachedPosition
CachedCenter
CachedTrajectory
CachedWaypoint
CachedContextMenuState
    end

    properties(Dependent)
CurrentWaypoint
XYCenter
XYUnitsPerPixel
TZCenter
TZUnitsPerPixel
    end

    properties(Constant,Hidden)
        TZScaleFactor=1.2
        XYScaleFactor=2.2
        WaypointScaleFactor=1.05
        MinViewRange=1e-9
        MaxViewRange=Inf
    end

    properties(Transient)
        XYWaypointHelpShown=false;
    end

    methods
        function this=ScenarioCanvas(varargin)
            this@fusion.internal.scenarioApp.component.BaseComponent(varargin{:});
            this@matlabshared.application.Canvas();

            initializeScrollZoom(this);

            createCanvasModes(this);
            createContextMenus(this);
        end

        function tag=getTag(~)
            tag='ScenarioCanvas';
        end

        function ax=getAxes(this)
            ax=this.ActiveCanvas;
            if isempty(ax)
                ax=hittest(this.Figure);
            end
            if~ishghandle(ax,'axes')
                ax=this.XYAxes;
            end
        end

        function fig=getFigure(this)
            fig=this.Figure;
        end

        function appendWaypoints(this)
            currentPlatform=this.Application.getCurrentPlatform;
            if~isempty(currentPlatform)
                this.CachedTrajectory=currentPlatform.TrajectorySpecification;
                this.ActiveCanvas=this.XYAxes;
                setCanvasMode(this.CanvasMode,'AddWaypoints');
                focusOnComponent(this);
            end
        end

        function updatePlatforms(this)
            platforms=this.Application.getPlatforms;
            current=this.Application.getCurrentPlatform;
            playbackEntry=currentPlaybackEntry(this.Application);

            this.XYPlotter.update(platforms,current,playbackEntry);
            this.TZPlotter.update(platforms,current);
        end

        function updateCurrentWaypoint(this)
            current=this.Application.getCurrentPlatform;
            currentWaypoint=this.Application.getCurrentWaypoint;

            this.XYPlotter.updateCurrentWaypoint(current,currentWaypoint);
            this.TZPlotter.updateCurrentWaypoint(current,currentWaypoint);
        end


        function update(this)
            updatePlatforms(this);
            updateCurrentWaypoint(this);
            updateLimits(this);
        end

        function onCurrentWaypointChanged(this)
            updateCurrentWaypoint(this)
            zoomCurrentWaypoint(this);
        end

        function onNewPlatformSelected(this)
            setCanvasMode(this.CanvasMode,'Explore');

            update(this);

            if~currentPlatformInXYAxes(this)
                zoomXYScene(this);
            end

            if~currentPlatformInTZAxes(this)
                zoomTZScene(this);
            end
        end

        function onPlatformsChanged(this)
            setCanvasMode(this.CanvasMode,'Explore');

            update(this);

            if~currentPlatformInXYAxes(this)
                zoomXYScene(this);
            end

            if~currentPlatformInTZAxes(this)
                zoomTZScene(this);
            end
        end

        function onTrajectoryChanged(this)
            update(this);
            mode=this.Application.CanvasMode;
            if strcmp(mode,'AddWaypoints')
                zoomLastWaypoint(this);
            elseif startsWith(mode,'DragWaypoint')||startsWith(mode,'DragPlatform')
                zoomCurrentWaypoint(this);
            elseif startsWith(mode,'DragTrajectory')
                zoomEscapedPoint(this);
            end
        end

        function onPlatformDeleted(this)
            setCanvasMode(this.CanvasMode,'Explore');
        end

        function onPlaybackRestarted(this)
            updatePlatforms(this);
        end

        function onViewModelLoaded(this)
            zoomXYScene(this);
            zoomTZScene(this);
            p=zoom(this.TZAxes);
            p.Enable='off';
        end

        function flag=currentPlatformInXYAxes(this)
            currentPlatform=this.Application.getCurrentPlatform;
            if~isempty(currentPlatform)
                pos=currentPlatform.Position;
                xLim=this.XYAxes.XLim;
                yLim=this.XYAxes.YLim;
                flag=issorted([xLim(1),pos(1),xLim(2)])&&...
                issorted([yLim(1),pos(2),yLim(2)]);
            else
                flag=true;
            end
        end

        function flag=currentPlatformInTZAxes(this)
            currentPlatform=this.Application.getCurrentPlatform;
            if~isempty(currentPlatform)
                pos=currentPlatform.Position;
                yLim=this.TZAxes.YLim;
                flag=issorted([yLim(1),pos(3),yLim(2)]);
            else
                flag=true;
            end
        end

        function idx=get.CurrentWaypoint(this)
            idx=getCurrentWaypoint(this.Application);
        end

        function set.CurrentWaypoint(this,idx)
            setCurrentWaypoint(this.Application,idx);
        end

        function center=get.XYCenter(this)
            center=this.Application.XYCanvasCenter;
        end

        function unitsPerPixel=get.XYUnitsPerPixel(this)
            unitsPerPixel=this.Application.XYCanvasUnitsPerPixel;
        end

        function center=get.TZCenter(this)
            center=this.Application.TZCanvasCenter;
        end

        function unitsPerPixel=get.TZUnitsPerPixel(this)
            unitsPerPixel=this.Application.TZCanvasUnitsPerPixel;
        end

        function[cp,hUnitsPerPixel,vUnitsPerPixel]=getCurrentPoint(this,shouldNotRound)

            hAxes=getAxes(this);
            cp=get(hAxes,'CurrentPoint');
            cp=cp([1,3,5]);




            cp(3)=0;
            if nargout>1||nargin<2||~shouldNotRound
                [hUnitsPerPixel,vUnitsPerPixel]=getHVUnitsPerPixel(this);
                N1=getRoundingFactor(this,hUnitsPerPixel);
                N2=getRoundingFactor(this,vUnitsPerPixel);

                cp(1)=round(cp(1),N1);
                cp(2)=round(cp(2),N2);
            end
        end

        function setTooltipString(this,newString)
            setScenarioCanvasTooltipString(this.Application,newString);
        end

        function updateTooltipString(this)
            newString=this.Application.TooltipString;
            tooltip=this.hTooltip;
            hAxes=this.ActiveCanvas;

            if isempty(hAxes)
                delete(tooltip)
                return
            end

            if isempty(newString)
                if~isempty(tooltip)&&ishghandle(tooltip)
                    set(tooltip,'Visible','off');
                end
            else
                if~isempty(tooltip)&&ishghandle(tooltip)&&tooltip.Parent~=hAxes
                    delete(tooltip);
                    tooltip=[];
                end

                if isempty(tooltip)||~ishghandle(tooltip)
                    tooltip=text(hAxes,...
                    'Tag','Tooltip',...
                    'HitTest','off',...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom',...
                    'BackgroundColor',[253,253,204]/255,...
                    'Visible','off');
                    this.hTooltip=tooltip;
                end
                set(tooltip,'Parent',hAxes);

                if nargin<3
                    interpreter='none';
                end

                tooltip.Interpreter=interpreter;
                [cp,~,vUnitsPerPixel]=getCurrentPoint(this);

                top=hAxes.YLim(1);
                indx=2;

                modifier=[0,0,0];
                if cp(indx)<top+20*vUnitsPerPixel
                    modifier(indx)=50*vUnitsPerPixel;
                else
                    modifier(indx)=-20*vUnitsPerPixel;
                end
                pos=cp+modifier;
                set(tooltip,'Position',pos,'Visible','on','String',newString);
            end
        end

        function updateCanvasMode(this)
            mode=this.Application.CanvasMode;
            this.CanvasMode=this.CanvasModes(mode);
            update(this.CanvasMode);
            updateXYAxesHelpText(this);
            updateContextMenus(this);
        end
    end

    methods(Hidden)

        function onFocus(this)
            this.Application.FocusedComponent='scenario';
        end

        function keyPressCallback(this,~,ev)
            if strcmp(ev.Key,'escape')
                cancel(this.CanvasMode);
            elseif strcmp(ev.Key,'return')
                accept(this.CanvasMode);
            elseif strcmp(ev.Key,'delete')
                discard(this.CanvasMode);
            elseif strcmp(ev.Key,'space')
                zoomScene(this);
            end
        end

        function newPlatform=pasteItem(this,platform,location)

            newPlatform=copy(platform);
            traj=newPlatform.TrajectorySpecification;
            if nargin<3






                unitsPerPixel=getHVUnitsPerPixel(this);
                offset=[1,1,0]*8*unitsPerPixel;
            elseif nargin>2



                offset=horzcat(location(1:2)-traj.Position(1,1:2),0);
            end

            traj.Position=traj.Position+offset;
            autoAdjust(traj);
        end

        function updateXYLimits(this,ax)
            pos=getpixelposition(ax);

            center=this.XYCenter;
            unitsPerPixel=this.XYUnitsPerPixel;
            range=[-1,1]*unitsPerPixel/2;

            set(ax,...
            'XLim',center(1)+range*pos(3),...
            'YLim',center(2)+range*pos(4));
        end

        function updateTZLimits(this,ax)
            pos=getpixelposition(ax);

            center=this.TZCenter;
            center(~isfinite(center))=0;
            unitsPerPixel=this.TZUnitsPerPixel;
            unitsPerPixel(unitsPerPixel==0)=1;

            if isscalar(unitsPerPixel)
                unitsPerPixel=unitsPerPixel([1,1]);
            end
            rangex=[-1,1]*unitsPerPixel(1)/2;
            rangey=[-1,1]*unitsPerPixel(2)/2;

            newX=center(1)+rangex*pos(3);
            newY=center(2)+rangey*pos(4);
            set(ax,'XLim',newX,'YLim',newY);

        end

        function updateLimits(this)
            updateXYLimits(this,this.XYAxes);
            updateTZLimits(this,this.TZAxes);
        end

        function resize(this,~,~)
            updateLimits(this);
            update(this.XYAxesHelpText);
        end

        function updateTZEnable(this)

            zoom(this.Figure,'off');

            state=this.Application.TZEnable;
            this.TZAxes.Visible=matlab.lang.OnOffSwitchState(state);
            this.TZAxes.HandleVisibility=char(matlab.lang.OnOffSwitchState(state));
            this.TZAxes.Toolbar.Visible=char(matlab.lang.OnOffSwitchState(state));
            layoutCanvas(this);
            update(this);
            zoomTZScene(this);
        end

        function updateXYAxesHelpText(this)
            mode=this.Application.CanvasMode;
            plats=getPlatforms(this.Application);
            if isempty(plats)&&strcmp(mode,'AddPlatform')
                this.XYAxesHelpText.String=msgString(this,'ClickCanvasToAddPlatform');
                this.highlightCanvas;
            elseif~this.XYWaypointHelpShown&&strcmp(mode,'AddWaypoints')
                this.XYAxesHelpText.String=msgString(this,'ClickCanvasToAddWaypoints');
                this.XYWaypointHelpShown=true;
                this.highlightCanvas;
            else
                this.XYAxesHelpText.String='';
                this.removeHighlightCanvas;
            end
        end

        function[min,max]=getAxesSpan(this)
            min=this.MinViewRange;
            max=this.MaxViewRange;
        end

    end

    methods(Access=protected)

        function fig=createFigure(this,varargin)
            fig=createFigure@fusion.internal.scenarioApp.component.BaseComponent(this,...
            'WindowKeyPressFcn',@this.keyPressCallback,varargin{:});
            this.XYAxes=axes(fig,...
            'OuterPosition',[0,0,1,1],...
            'DataAspectRatio',[1,1,1],...
            'ZLim',[-1,1],...
            'XGrid','on',...
            'YGrid','on',...
            'YDir','reverse',...
            'Box','on',...
            'ButtonDownFcn',@this.onButtonDown,...
            'Tag','scenariocanvas.xy',...
            'Visible','on');

            xlabel(this.XYAxes,'X (m)');
            ylabel(this.XYAxes,'Y (m)');

            this.XYPlotter=fusion.internal.scenarioApp.plotter.ScenarioPlotter(this.XYAxes);
            this.XYPlotter.ProjectOntoXYPlane=true;
            this.XYPlotter.ShowCurrentWaypoint=true;
            this.XYPlotter.ShowWaypoints=true;
            this.XYPlotter.ShowTrajectories=true;
            this.XYPlotter.PlatformPositionButtonDownFcn=@this.onButtonDown;
            this.XYPlotter.PlatformPositionTag='platform.position.xy';
            this.XYPlotter.PlatformExtentButtonDownFcn=@this.onButtonDown;
            this.XYPlotter.PlatformExtentTag='platform.extent.xy';
            this.XYPlotter.TrajectoryButtonDownFcn=@this.onButtonDown;
            this.XYPlotter.TrajectoryTag='trajectory.xy';
            this.XYPlotter.WaypointsButtonDownFcn=@this.onButtonDown;
            this.XYPlotter.WaypointsTag='waypoints.xy';
            this.XYPlotter.CurrentWaypointButtonDownFcn=@this.onButtonDown;
            this.XYPlotter.CurrentWaypointTag='activewaypoint.xy';

            this.XYAxesHelpText=fusion.internal.scenarioApp.plotter.AxesHelpText(this.XYAxes);

            this.TZAxes=axes(fig,...
            'OuterPosition',[0,0,1,1],...
            'XGrid','on',...
            'YGrid','on',...
            'YDir','reverse',...
            'Box','on',...
            'ButtonDownFcn',@this.onButtonDown,...
            'Tag','scenariocanvas.tz',...
            'HandleVisibility','off',...
            'Visible','off');

            xlabel(this.TZAxes,'Time (s)');
            ylabel(this.TZAxes,'Altitude (m)');

            this.TZPlotter=fusion.internal.scenarioApp.plotter.TimePlotter(this.TZAxes);
            this.TZPlotter.TrajectoryButtonDownFcn=@this.onButtonDown;
            this.TZPlotter.TrajectoryTag='trajectory.tz';
            this.TZPlotter.WaypointsButtonDownFcn=@this.onButtonDown;
            this.TZPlotter.WaypointsTag='waypoints.tz';
            this.TZPlotter.CurrentWaypointButtonDownFcn=@this.onButtonDown;
            this.TZPlotter.CurrentWaypointTag='activewaypoint.tz';

            initializeFloatingPalette(this,this.Figure,this.XYAxes);
            layoutCanvas(this);
        end

        function layoutCanvas(this)
            ypos=0;

            if matlab.lang.OnOffSwitchState(this.TZAxes.Visible)
                this.TZAxes.OuterPosition=[0,ypos,1,1/4];
                ypos=ypos+1/4;
            end

            this.XYAxes.OuterPosition=[0,ypos,1,1-ypos];
            updateLimits(this);
        end

    end

    methods
        function setXYCenterAndUnitsPerPixel(this,center,unitsPerPixel)
            setXYCenterAndUnitsPerPixel(this.Application.ViewModel.ScenarioCanvas,center,unitsPerPixel);
        end

        function setTZCenterAndUnitsPerPixel(this,center,unitsPerPixel)
            setTZCenterAndUnitsPerPixel(this.Application.ViewModel.ScenarioCanvas,center,unitsPerPixel);
        end

        function applyXYAxesLimits(this,hLim,vLim)
            center=this.XYCenter;
            ax=this.XYAxes;
            pos=getpixelposition(ax);


            center(1)=mean(hLim);
            center(2)=mean(vLim);

            unitsPerPixel=max(diff(hLim)/pos(3),diff(vLim)/pos(4));
            setXYCenterAndUnitsPerPixel(this,center,unitsPerPixel);
        end

        function[hLim,vLim]=safeTZLimits(~,hLim,vLim)



            hLim(hLim<0)=0;


            if diff(hLim)<1e-3
                hLim(2)=1e-3+hLim(1);
            end


            if diff(vLim)<1e-3
                vLim(2)=vLim(1)+1e-3;
            end
        end

        function requestXYDrag(this,drag)
            unitsPerPixel=this.XYUnitsPerPixel;
            center=this.XYCenter;
            center(1:2)=center(1:2)+drag(1:2);
            setXYCenterAndUnitsPerPixel(this.Application.ViewModel.ScenarioCanvas,center,unitsPerPixel);
        end

        function requestTZDrag(this,drag)
            hLim=this.TZAxes.XLim+drag(1);
            vLim=this.TZAxes.YLim+drag(2);


            endTime=getLastDisplayTime(this.Application);
            if hLim(2)>endTime
                hLim=horzcat(endTime-diff(hLim),endTime);
            end


            if hLim(1)<0
                hLim=horzcat(0,diff(hLim));
            end

            applyTZAxesLimits(this,hLim,vLim);
        end

        function applyTZAxesLimits(this,hLim,vLim)
            [hLim,vLim]=safeTZLimits(this,hLim,vLim);
            pos=getpixelposition(this.TZAxes);
            center=[mean(hLim),mean(vLim),0];
            unitsPerPixel=[diff(hLim),diff(vLim),0]./[pos(3:4),1];
            setTZCenterAndUnitsPerPixel(this,center,unitsPerPixel);
        end

        function applyAxesLimits(this,hLim,vLim)
            ax=getAxes(this);
            if ax==this.XYAxes
                applyXYAxesLimits(this,hLim,vLim);
            elseif ax==this.TZAxes
                applyTZAxesLimits(this,hLim,vLim);
            end
        end
    end


    methods
        function initializeFloatingPalette(this,~,~)
            initXYToolbar(this);
            initTZToolbar(this);
        end

        function initXYToolbar(this)

            [tb,btns]=axtoolbar(this.XYAxes,{'restoreview'},'Visible','on');


            xyZoomScene=findobj(btns,'Tag','restoreview');
            xyZoomScene.ButtonPushedFcn=@(src,evt)zoomXYScene(this);
            xyZoomScene.Tooltip=msgString(this,'ZoomToScenario');
            xyZoomScene.Icon='restoreview';
            xyZoomScene.Tag='xyBtnZoomScene';


            xyZoomOut=axtoolbarbtn(tb,'push');
            xyZoomOut.ButtonPushedFcn=@(src,evt)zoomOut(this);
            xyZoomOut.Tooltip=msgString(this,'ZoomOut');
            xyZoomOut.Icon='zoomout';
            xyZoomOut.Tag='xyBtnZoomOut';


            xyZoomIn=axtoolbarbtn(tb,'push');
            xyZoomIn.ButtonPushedFcn=@(src,evt)zoomIn(this);
            xyZoomIn.Tooltip=msgString(this,'ZoomIn');
            xyZoomIn.Icon='zoomin';
            xyZoomIn.Tag='xyBtnZoomIn';


            xyZoomPlat=axtoolbarbtn(tb,'push');
            xyZoomPlat.ButtonPushedFcn=@(src,evt)zoomPlat(this,src,evt);
            xyZoomPlat.Icon=iconFile(this,'zoom_to_platform_16.png');
            xyZoomPlat.Tooltip=msgString(this,'ZoomToPlatform');
            xyZoomPlat.Tag='xyBtnZoomPlat';
        end

        function initTZToolbar(this)

            [tb,btns]=axtoolbar(this.TZAxes,{'zoomin','zoomout','restoreview'},'Visible','off');


            tzZoomScene=findobj(btns,'Tag','restoreview');
            tzZoomScene.Tooltip=msgString(this,'ZoomToScenario');
            tzZoomScene.ButtonPushedFcn=@(src,evt)zoomTZScene(this);


            tzZoomTraj=axtoolbarbtn(tb,'push');
            tzZoomTraj.ButtonPushedFcn=@(src,evt)zoomTZTrajectory(this);
            tzZoomTraj.Tooltip=msgString(this,'ZoomToTrajectory');
            tzZoomTraj.Icon=iconFile(this,'zoom_to_trajectory_16.png');
            tzZoomTraj.Tag='tzBtnZoomTraj';
        end
    end

    methods(Access=protected)
        function zoomPlat(this,~,~)
            platform=this.Application.getCurrentPlatform;

            if isempty(platform)

                zoomScene(this);
            else

                center=platform.Position;


                range=2*max(platform.Dimension(1:3)+platform.Dimension(4:6));
                range=max(range,100);
                this.applyAxesLimits(center(1)+[-range/2,range/2],...
                center(2)+[-range/2,range/2]);
            end
        end

        function zoomEscapedPoint(this)
            mode=this.Application.CanvasMode;
            pos=getCurrentPoint(this,true);
            if endsWith(mode,'XY')

                zoomXYWaypoint(this,pos);
            elseif endsWith(mode,'Z')

                pos(1)=max(pos(1),0);
                zoomTZWaypoint(this,pos);
            end
        end

        function zoomXYTrajectory(this)
            platform=this.Application.getCurrentPlatform;
            if isempty(platform)
                zoomXYScene(this);
            else
                scaleFactor=this.XYScaleFactor;
                traj=platform.TrajectorySpecification;
                pos=vertcat(traj.Position);
                minX=min(pos(:,1));
                maxX=max(pos(:,1));
                maxY=max(pos(:,2));
                minY=min(pos(:,2));
                sumX=minX+maxX;
                sumY=minY+maxY;
                difX=maxX-minX;
                difX=max(difX,1e-3);
                difY=maxY-minY;
                difY=max(difY,1e-3);
                xLim=(sumX+scaleFactor*[-difX,difX])/2;
                yLim=(sumY+scaleFactor*[-difY,difY])/2;
                applyXYAxesLimits(this,xLim,yLim);
            end
        end

        function zoomTZTrajectory(this)
            platform=this.Application.getCurrentPlatform;
            if isempty(platform)
                zoomTZScene(this);
            else
                scaleFactor=this.TZScaleFactor;
                traj=platform.TrajectorySpecification;
                minT=traj.TimeOfArrival(1);
                maxT=traj.TimeOfArrival(end);
                pos=vertcat(traj.Position);
                maxZ=max(pos(:,3));
                minZ=min(pos(:,3));
                sumT=minT+maxT;
                sumZ=minZ+maxZ;
                difT=maxT-minT;
                difZ=maxZ-minZ;
                difZ=max(difZ,1e-3);
                xLim=(sumT+scaleFactor*[-difT,difT])/2;
                yLim=(sumZ+scaleFactor*[-difZ,difZ])/2;
                [xLim,yLim]=safeTZLimits(this,xLim,yLim);
                applyTZAxesLimits(this,xLim,yLim);
            end
        end

        function zoomXYScene(this)

            scaleFactor=this.XYScaleFactor;

            platforms=this.Application.getPlatforms;
            if isempty(platforms)

                hRange=[-100,100];
                vRange=[-100,100];
                this.applyAxesLimits(hRange,vRange);
                return
            end

            minpositions=inf(1,2);
            maxpositions=-inf(1,2);
            for ind=1:numel(platforms)
                positions=reshape(generateFaces(platforms(ind),'global'),3,[])';
                minpositions=min(minpositions,min(positions(:,1:2)));
                maxpositions=max(maxpositions,max(positions(:,1:2)));
                positions=platforms(ind).TrajectorySpecification.Position;
                minpositions=min(minpositions,min(positions(:,1:2)));
                maxpositions=max(maxpositions,max(positions(:,1:2)));
            end

            xMin=minpositions(:,1);
            xMax=maxpositions(:,1);
            yMin=minpositions(:,2);
            yMax=maxpositions(:,2);
            xCenter=(xMin+xMax)/2;
            yCenter=(yMin+yMax)/2;
            radius=scaleFactor*max(100,max([xMax-xMin,yMax-yMin]))/2;

            minH=xCenter-radius;
            maxH=xCenter+radius;
            minV=yCenter-radius;
            maxV=yCenter+radius;

            this.applyXYAxesLimits([minH,maxH],[minV,maxV]);
        end

        function zoomTZScene(this)
            scaleFactor=this.TZScaleFactor;
            stopTime=getLastDisplayTime(this.Application);
            platforms=this.Application.getPlatforms;
            if isempty(platforms)

                minV=0;
                maxV=50;
            else
                traj=vertcat(platforms.TrajectorySpecification);
                pos=vertcat(traj.Position);
                zMin=min(pos(:,3));
                zMax=max(pos(:,3));
                zCenter=(zMax+zMin)/2;
                zRange=scaleFactor*max(1,(zMax-zMin)/2);
                minV=zCenter-zRange;
                maxV=zCenter+zRange;
            end
            this.applyTZAxesLimits([0,stopTime],[minV,maxV]);
        end

        function[isValid,xy,tz]=getLastWaypointLocation(this)
            isValid=false;
            xy=[nan,nan];
            tz=[nan,nan];
            plat=getCurrentPlatform(this.Application);
            if~isempty(plat)
                traj=plat.TrajectorySpecification;
                if~isempty(traj)
                    pos=traj.Position;
                    toa=traj.TimeOfArrival;
                    idx=length(traj.TimeOfArrival);
                    isValid=true;
                    xy=pos(idx,1:2);
                    tz=[toa(idx),pos(idx,3)];
                end
            end
        end

        function[isValid,xy,tz]=getCurrentWaypointLocation(this)
            isValid=false;
            xy=[nan,nan];
            tz=[nan,nan];
            idx=this.CurrentWaypoint;
            if idx>0
                plat=getCurrentPlatform(this.Application);
                if~isempty(plat)
                    traj=plat.TrajectorySpecification;
                    if~isempty(traj)
                        pos=traj.Position;
                        toa=traj.TimeOfArrival;
                        if idx<=length(traj.TimeOfArrival)
                            isValid=true;
                            xy=pos(idx,1:2);
                            tz=[toa(idx),pos(idx,3)];
                        end
                    end
                end
            end
        end

        function zoomXYWaypoint(this,xy)
            scaleFactor=this.WaypointScaleFactor;
            xLim=this.XYAxes.XLim;
            yLim=this.XYAxes.YLim;
            xTest=[xLim(1),xy(1),xLim(2)];
            yTest=[yLim(1),xy(2),yLim(2)];
            if~issorted(xTest)||~issorted(yTest)
                xTest=sort(xTest);
                yTest=sort(yTest);
                xTest=xTest([1,3]);
                yTest=yTest([1,3]);
                if~isequal(xTest,xLim)
                    dLim=diff(xTest);
                    xLim=mean(xTest)+scaleFactor*[-dLim,dLim]/2;
                end
                if~isequal(yTest,yLim)
                    dLim=diff(yTest);
                    yLim=mean(yTest)+scaleFactor*[-dLim,dLim]/2;
                end
                this.applyXYAxesLimits(xLim,yLim);
            end
        end

        function zoomTZWaypoint(this,tz)
            scaleFactor=this.WaypointScaleFactor;
            xLim=this.TZAxes.XLim;
            yLim=this.TZAxes.YLim;
            xTest=[xLim(1),tz(1),xLim(2)];
            yTest=[yLim(1),tz(2),yLim(2)];
            if~issorted(xTest)||~issorted(yTest)
                xTest=sort(xTest);
                yTest=sort(yTest);
                xTest=xTest([1,3]);
                yTest=yTest([1,3]);
                if~isequal(xTest,xLim)
                    dLim=diff(xTest);
                    xLim=mean(xTest)+scaleFactor*[-dLim,dLim]/2;
                end
                if~isequal(yTest,yLim)
                    dLim=diff(yTest);
                    yLim=mean(yTest)+scaleFactor*[-dLim,dLim]/2;
                end
                this.applyTZAxesLimits(xLim,yLim);
            end
        end

        function zoomScene(this,~,~)
            zoomXYScene(this);
            zoomTZScene(this);
        end

        function zoomCurrentWaypoint(this)
            [isValid,xy,tz]=getCurrentWaypointLocation(this);
            if isValid
                zoomXYWaypoint(this,xy);
                zoomTZWaypoint(this,tz);
            end
        end

        function zoomLastWaypoint(this)
            [isValid,xy,tz]=getLastWaypointLocation(this);
            if isValid
                zoomXYWaypoint(this,xy);
                zoomTZWaypoint(this,tz);
            end
        end

        function zoomScenarioCallback(this,~,~)
            zoomScene(this);
        end
    end


    methods(Access=protected)

        function createCanvasModes(this)
            this.CanvasModes=containers.Map;
            this.CanvasModes('Explore')=fusion.internal.scenarioApp.canvasMode.Explore(this.Application,this);
            this.CanvasModes('AddPlatform')=fusion.internal.scenarioApp.canvasMode.AddPlatform(this.Application,this);
            this.CanvasModes('AddWaypoints')=fusion.internal.scenarioApp.canvasMode.AddWaypoints(this.Application,this);
            this.CanvasModes('HoverPlatformXY')=fusion.internal.scenarioApp.canvasMode.HoverPlatformXY(this.Application,this);
            this.CanvasModes('HoverWaypointXY')=fusion.internal.scenarioApp.canvasMode.HoverWaypointXY(this.Application,this);
            this.CanvasModes('HoverWaypointTZ')=fusion.internal.scenarioApp.canvasMode.HoverWaypointTZ(this.Application,this);
            this.CanvasModes('HoverWaypointZ')=fusion.internal.scenarioApp.canvasMode.HoverWaypointZ(this.Application,this);
            this.CanvasModes('HoverTrajectoryXY')=fusion.internal.scenarioApp.canvasMode.HoverTrajectoryXY(this.Application,this);
            this.CanvasModes('HoverTrajectoryZ')=fusion.internal.scenarioApp.canvasMode.HoverTrajectoryZ(this.Application,this);
            this.CanvasModes('DragPlatformXY')=fusion.internal.scenarioApp.canvasMode.DragPlatformXY(this.Application,this);
            this.CanvasModes('DragWaypointXY')=fusion.internal.scenarioApp.canvasMode.DragWaypointXY(this.Application,this);
            this.CanvasModes('DragWaypointTZ')=fusion.internal.scenarioApp.canvasMode.DragWaypointTZ(this.Application,this);
            this.CanvasModes('DragWaypointZ')=fusion.internal.scenarioApp.canvasMode.DragWaypointZ(this.Application,this);
            this.CanvasModes('DragTrajectoryXY')=fusion.internal.scenarioApp.canvasMode.DragTrajectoryXY(this.Application,this);
            this.CanvasModes('DragTrajectoryZ')=fusion.internal.scenarioApp.canvasMode.DragTrajectoryZ(this.Application,this);
            this.CanvasModes('PanScenarioCanvasTZ')=fusion.internal.scenarioApp.canvasMode.PanScenarioCanvasTZ(this.Application,this);
            this.CanvasModes('PanScenarioCanvasXY')=fusion.internal.scenarioApp.canvasMode.PanScenarioCanvasXY(this.Application,this);
            defaultMode=this.Application.CanvasMode;
            this.CanvasMode=this.CanvasModes(defaultMode);
        end

        function performMouseMove(this,hSrc,evt)
            performMouseMove(this.CanvasMode,hSrc,evt);
        end

        function performButtonDown(this,hSrc,evt)
            performButtonDown(this.CanvasMode,hSrc,evt);
        end

        function performButtonUp(this,hSrc,evt)
            performButtonUp(this.CanvasMode,hSrc,evt);
        end

        function cancelButtonDown(this)
            cancelButtonDown(this.CanvasMode);
        end
    end

    methods(Hidden)

        function setCanvasMode(this,newMode)






            zoom(this.Figure,'off');
            setScenarioCanvasMode(this.Application,newMode);
        end
    end

    methods
        function b=isLeftClick(this)
            b=strcmp(this.Figure.SelectionType,'normal');
        end

        function b=isRightClick(this)
            b=strcmp(this.Figure.SelectionType,'alt');
        end

        function b=isDoubleClick(this)
            b=strcmp(this.Figure.SelectionType,'open');
        end

        function b=isExtendedClick(this)
            b=strcmp(this.Figure.SelectionType,'extend');
        end
    end


    methods(Hidden)
        function createContextMenus(this)
            fig=this.Figure;


            this.CachedContextMenuState=matlab.lang.OnOffSwitchState('on');

            axesContextMenu=uicontextmenu(fig,...
            'Callback',@this.axesContextMenuCallback,...
            'Tag','ScenarioCanvasAxesContextMenu');
            uimenu(axesContextMenu,...
            'Label',msgString(this,'PastePlatform'),...
            'Tag','PastePlatform',...
            'Callback',@this.pastePlatformCallback);
            uimenu(axesContextMenu,...
            'Label',msgString(this,'ZoomToScenario'),...
            'Tag','ZoomToScenario',...
            'Callback',@this.zoomScenarioCallback);
            this.XYAxes.UIContextMenu=axesContextMenu;

            platformContextMenu=uicontextmenu(fig,...
            'Callback',@this.xyContextMenuCallback,...
            'Tag','ScenarioCanvasPlatformContextMenu');
            uimenu(platformContextMenu,...
            'Label',msgString(this,'CopyPlatform'),...
            'Tag','CopyPlatform',...
            'Callback',@this.copyPlatformCallback);
            uimenu(platformContextMenu,...
            'Label',msgString(this,'AddWaypoints'),...
            'Tag','AddWaypoints',...
            'Callback',@this.addWaypointsCallback);
            uimenu(platformContextMenu,...
            'Label',msgString(this,'DeletePlatform'),...
            'Tag','DeletePlatform',...
            'Callback',@this.deletePlatformCallback);
            uimenu(platformContextMenu,...
            'Label',msgString(this,'ZoomToPlatform'),...
            'Tag','ZoomToPlatform',...
            'Callback',@this.zoomPlatformCallback);
            this.XYPlotter.PlatformPositionUIContextMenu=platformContextMenu;
            this.XYPlotter.PlatformExtentUIContextMenu=platformContextMenu;


            waypointXYContextMenu=uicontextmenu(fig,...
            'Callback',@this.xyContextMenuCallback,...
            'Tag','ScenarioCanvasWaypointXYContextMenu');
            uimenu(waypointXYContextMenu,...
            'Label',msgString(this,'SelectWaypoint'),...
            'Tag','SelectWaypoint',...
            'Callback',@this.selectXYWaypointCallback);
            uimenu(waypointXYContextMenu,...
            'Label',msgString(this,'DeleteWaypoint'),...
            'Tag','DeleteWaypoint',...
            'Callback',@this.deleteXYWaypointCallback);
            this.XYPlotter.WaypointsUIContextMenu=waypointXYContextMenu;
            this.XYPlotter.CurrentWaypointUIContextMenu=waypointXYContextMenu;

            waypointTZContextMenu=uicontextmenu(fig,...
            'Callback',@this.tzContextMenuCallback,...
            'Tag','ScenarioCanvasWaypointTZContextMenu');
            uimenu(waypointTZContextMenu,...
            'Label',msgString(this,'SelectWaypoint'),...
            'Tag','SelectWaypoint',...
            'Callback',@this.selectTZWaypointCallback);
            uimenu(waypointTZContextMenu,...
            'Label',msgString(this,'DeleteWaypoint'),...
            'Tag','DeleteWaypoint',...
            'Callback',@this.deleteTZWaypointCallback);
            this.TZPlotter.WaypointsUIContextMenu=waypointTZContextMenu;
            this.TZPlotter.CurrentWaypointUIContextMenu=waypointTZContextMenu;


            trajectoryXYContextMenu=uicontextmenu(fig,...
            'Callback',@this.xyContextMenuCallback,...
            'Tag','ScenarioCanvasTrajectoryXYContextMenu');
            uimenu(trajectoryXYContextMenu,...
            'Label',msgString(this,'InsertWaypoint'),...
            'Tag','InsertWaypoint',...
            'Callback',@this.insertXYWaypointCallback);
            uimenu(trajectoryXYContextMenu,...
            'Label',msgString(this,'DeleteTrajectory'),...
            'Tag','DeleteTrajectory',...
            'Callback',@this.deleteTrajectoryCallback);
            this.XYPlotter.TrajectoryUIContextMenu=trajectoryXYContextMenu;

            trajectoryTZContextMenu=uicontextmenu(fig,...
            'Callback',@this.tzContextMenuCallback,...
            'Tag','ScenarioCanvasTrajectoryTZContextMenu');
            uimenu(trajectoryTZContextMenu,...
            'Label',msgString(this,'InsertWaypoint'),...
            'Tag','InsertWaypoint',...
            'Callback',@this.insertTZWaypointCallback);
            uimenu(trajectoryTZContextMenu,...
            'Label',msgString(this,'DeleteTrajectory'),...
            'Tag','DeleteTrajectory',...
            'Callback',@this.deleteTrajectoryCallback);
            uimenu(trajectoryTZContextMenu,...
            'Label',msgString(this,'ZoomToTrajectory'),...
            'Tag','ZoomToTrajectory',...
            'Callback',@this.zoomTrajectoryCallback);
            this.TZPlotter.TrajectoryUIContextMenu=trajectoryTZContextMenu;
        end

        function updateContextMenus(this)
            if strcmp(this.Application.CanvasMode,'AddWaypoints')
                removeContextMenus(this);
            end
        end

        function removeContextMenus(this)
            this.CachedContextMenuState=matlab.lang.OnOffSwitchState('off');
            removeContextMenus(this.XYPlotter);
        end

        function restoreContextMenus(this)
            if~this.CachedContextMenuState
                restoreContextMenus(this.XYPlotter);
                this.CachedContextMenuState=matlab.lang.OnOffSwitchState('on');
            end
        end


        function axesContextMenuCallback(this,hSrc,~)



            this.ContextClickLocation=getCurrentPoint(this);
            hPaste=findobj(hSrc,'Tag','PastePlatform');
            hPaste.Enable=matlabshared.application.logicalToOnOff(isPasteEnabled(this.Application));
        end

        function pastePlatformCallback(this,~,~)
            pasteItem(this.Application,this.ContextClickLocation);
        end

        function xyContextMenuCallback(this,~,~)
            this.ContextClickLocation=getCurrentPoint(this);
        end

        function tzContextMenuCallback(this,~,~)
            this.ContextClickLocation=getCurrentPoint(this);
        end


        function addWaypointsCallback(this,~,~)
            appendWaypoints(this);
        end

        function zoomPlatformCallback(this,~,~)
            zoomPlat(this);
        end

        function copyPlatformCallback(this,~,~)
            copyItem(this.Application);
        end

        function deletePlatformCallback(this,~,~)
            deleteCurrentPlatform(this.Application);
        end


        function selectXYWaypointCallback(this,~,~)

            idx=closestXYWaypointIndex(...
            this.Application.getCurrentPlatform.TrajectorySpecification,...
            this.ContextClickLocation);
            this.CurrentWaypoint=idx;
        end

        function deleteXYWaypointCallback(this,~,~)
            oldTraj=this.Application.getCurrentPlatform.TrajectorySpecification;
            newTraj=copy(oldTraj);
            idx=closestXYWaypointIndex(newTraj,this.ContextClickLocation);
            deleteWaypoint(newTraj,idx);
            changeTrajectory(this.Application,0,newTraj,idx,oldTraj);
        end

        function selectTZWaypointCallback(this,~,~)
            ax=this.TZAxes;
            pos=getpixelposition(ax);
            unitsPerPixel=[diff(ax.XLim),diff(ax.YLim)]./pos(3:4);

            idx=closestTZWaypointIndex(...
            this.Application.getCurrentPlatform.TrajectorySpecification,...
            this.ContextClickLocation,...
            unitsPerPixel);
            this.CurrentWaypoint=idx;
        end

        function deleteTZWaypointCallback(this,~,~)
            oldTraj=this.Application.getCurrentPlatform.TrajectorySpecification;
            newTraj=copy(oldTraj);

            ax=this.TZAxes;
            pos=getpixelposition(ax);
            unitsPerPixel=[diff(ax.XLim),diff(ax.YLim)]./pos(3:4);
            idx=closestTZWaypointIndex(newTraj,this.ContextClickLocation,unitsPerPixel);
            deleteWaypoint(newTraj,idx);
            changeTrajectory(this.Application,0,newTraj,idx,oldTraj);
        end


        function insertXYWaypointCallback(this,~,~)
            oldTraj=this.Application.getCurrentPlatform.TrajectorySpecification;
            newTraj=copy(oldTraj);
            idx=insertWaypointXY(newTraj,this.ContextClickLocation);
            changeTrajectory(this.Application,idx,newTraj,0,oldTraj);
        end

        function insertTZWaypointCallback(this,~,~)
            oldTraj=this.Application.getCurrentPlatform.TrajectorySpecification;
            newTraj=copy(oldTraj);
            idx=insertWaypointT(newTraj,this.ContextClickLocation(1));
            changeTrajectory(this.Application,idx,newTraj,0,oldTraj);
        end

        function deleteTrajectoryCallback(this,~,~)
            oldTraj=this.Application.getCurrentPlatform.TrajectorySpecification;
            newTraj=copy(oldTraj);
            deleteTrajectory(newTraj);
            changeTrajectory(this.Application,0,newTraj,0,oldTraj);
        end

        function zoomTrajectoryCallback(this,~,~)
            zoomTZTrajectory(this);
        end

    end

end
