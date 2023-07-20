classdef TimePlotter<handle

    properties
        StopTime=Inf
        WaypointsMarker='o'
        WaypointsMarkerSize=6
        WaypointsMarkerSizeCurrent=8
        WaypointsButtonDownFcn=''
        WaypointsTag='Waypoints'
        WaypointsUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        TrajectoryButtonDownFcn=''
        TrajectoryTag='Trajectory'
        TrajectoryUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        CurrentWaypointMarker='o'
        CurrentWaypointMarkerSize=6
        CurrentWaypointButtonDownFcn=''
        CurrentWaypointTag=''
        CurrentWaypointUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        HighlightLineWidth(1,1)double=1.5
        DefaultLineWidth(1,1)double=1
    end

    properties(SetAccess=protected,Hidden)

Axes


        TrajectoryLines=matlab.graphics.primitive.Line.empty
        WaypointLines=matlab.graphics.primitive.Line.empty
        CurrentWaypointLine=matlab.graphics.primitive.Line.empty

YLimListener
    end

    methods

        function this=TimePlotter(hAxes)
            this.Axes=hAxes;
            addlistener(hAxes,'YLim','PostSet',@(src,evt)this.z2altitude);
        end

        function z2altitude(this)
            haxes=this.Axes;
            haxes.YTickLabel=-haxes.YTick;
        end

        function clear(this)
            delete(this.WaypointLines);
            delete(this.TrajectoryLines);
            delete(this.CurrentWaypointLine);
            this.WaypointLines=matlab.graphics.primitive.Line.empty;
            this.TrajectoryLines=matlab.graphics.primitive.Line.empty;
            this.CurrentWaypointLine=matlab.graphics.primitive.Line.empty;
        end

        function update(this,platforms,currentPlatform)
            if matlab.lang.OnOffSwitchState(this.Axes.Visible)
                plotTrajectory(this,platforms,currentPlatform);
                plotWaypoints(this,currentPlatform);
            else
                clear(this);
            end
        end

        function updateCurrentWaypoint(this,currentPlatform,currentWaypoint)
            if matlab.lang.OnOffSwitchState(this.Axes.Visible)
                plotCurrentWaypoint(this,currentPlatform,currentWaypoint);
            else
                clear(this);
            end
        end

        function plotWaypoints(this,currentPlatform)
            ax=this.Axes;
            waypointLines=this.WaypointLines;

            if~isempty(currentPlatform)
                platformTraj=currentPlatform.TrajectorySpecification;

                timeData=platformTraj.TimeOfArrival;
                elevData=platformTraj.Position(:,3);

                if isscalar(timeData)||~any(platformTraj.GroundSpeed)
                    timeData=ax.XLim;
                    elevData=elevData([1,1]);
                    marker='none';
                    lineColor=getPlatformColor(this,currentPlatform);
                else
                    marker=this.WaypointsMarker;
                    lineColor='none';
                end

                if isempty(waypointLines)||~ishghandle(waypointLines)
                    waypointLines=line('Parent',ax,...
                    'MarkerSize',this.WaypointsMarkerSize,...
                    'MarkerFaceColor',ax.Color,...
                    'ButtonDownFcn',this.WaypointsButtonDownFcn,...
                    'UIContextMenu',this.WaypointsUIContextMenu,...
                    'Tag',this.WaypointsTag);
                end
                set(waypointLines,...
                'Marker',marker,...
                'MarkerEdgeColor',getPlatformColor(this,currentPlatform),...
                'Color',lineColor',...
                'XData',timeData,...
                'YData',elevData,...
                'UserData',currentPlatform);
            else
                delete(waypointLines(:));
                waypointLines(:)=[];
            end

            this.WaypointLines=waypointLines;



            if~isempty(currentPlatform)
                uistack(this.WaypointLines,'top');
            end
        end

        function plotCurrentWaypoint(this,currentPlatform,currentWaypoint)
            ax=this.Axes;

            if~isempty(currentPlatform)
                platformTraj=currentPlatform.TrajectorySpecification;
                timeData=platformTraj.TimeOfArrival;
                elevData=platformTraj.Position(:,3);
            else
                timeData=zeros(0,1);
                elevData=zeros(0,1);
            end

            if currentWaypoint>1&&currentWaypoint<=numel(timeData)
                if isempty(this.CurrentWaypointLine)||~ishghandle(this.CurrentWaypointLine)
                    this.CurrentWaypointLine=line('Parent',ax,...
                    'Marker',this.CurrentWaypointMarker,...
                    'MarkerSize',this.WaypointsMarkerSizeCurrent,...
                    'LineStyle','none',...
                    'ButtonDownFcn',this.WaypointsButtonDownFcn,...
                    'UIContextMenu',this.WaypointsUIContextMenu,...
                    'Tag',this.WaypointsTag);
                end
                color=getPlatformColor(this,currentPlatform);
                set(this.CurrentWaypointLine,...
                'MarkerFaceColor',color,...
                'MarkerEdgeColor',color,...
                'XData',timeData(currentWaypoint),...
                'YData',elevData(currentWaypoint),...
                'UserData',currentPlatform);
                uistack(this.CurrentWaypointLine,'top');
            else
                delete(this.CurrentWaypointLine);
                this.CurrentWaypointLine=matlab.graphics.primitive.Line.empty;
            end
        end

        function plotTrajectory(this,platforms,currentPlatform)
            ax=this.Axes;

            trajectoryLines=this.TrajectoryLines;
            nPlatforms=numel(platforms);

            maxTOA=-Inf;

            for indx=1:nPlatforms
                platform=platforms(indx);
                trajectory=platform.TrajectorySpecification;
                [posData,~,timeData]=trajectoryPreview(trajectory);
                elevData=posData(:,3);
                maxTOA=max(maxTOA,max(timeData));

                if isscalar(timeData)||~any(trajectory.GroundSpeed)
                    timeData=ax.XLim;
                    elevData=elevData([1,1]);
                end

                lineColor=getPlatformColor(this,platform);
                lineWidth=getSelectionWidth(this,platform,currentPlatform);

                if numel(trajectoryLines)<indx||~ishghandle(trajectoryLines(indx))
                    trajectoryLines(indx)=line('Parent',ax,...
                    'ButtonDownFcn',this.TrajectoryButtonDownFcn,...
                    'UIContextMenu',this.TrajectoryUIContextMenu,...
                    'Tag',this.TrajectoryTag);
                end
                set(trajectoryLines(indx),...
                'Color',lineColor',...
                'LineWidth',lineWidth,...
                'XData',timeData,...
                'YData',elevData,...
                'UserData',platform);
            end

            delete(trajectoryLines(nPlatforms+1:end));
            trajectoryLines(nPlatforms+1:end)=[];
            this.TrajectoryLines=trajectoryLines;



            if~isempty(currentPlatform)
                uistack(this.TrajectoryLines(platforms==currentPlatform),'top');
            end
        end

        function color=getPlatformColor(this,platform)
            index=platform.ID+1;
            cid=mod(index,7);
            if cid==0
                cid=7;
            end
            color=this.Axes.ColorOrder(cid,:);
        end

        function width=getSelectionWidth(this,platform,currentPlatform)
            if isequal(platform,currentPlatform)
                width=this.HighlightLineWidth;
            else
                width=this.DefaultLineWidth;
            end
        end

    end
end