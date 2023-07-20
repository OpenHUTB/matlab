classdef ScenarioPlotter<handle

    properties
        ShowCurrentWaypoint logical=false
        ShowWaypoints logical=false
        ShowTrajectories logical=false
        ProjectOntoXYPlane logical=false
        HighlightCurrentPlatform logical=true
        HighlightColor(1,3)double=[0.3010,0.7450,0.9330]
        HighlightLineWidth(1,1)double=1.5
        DefaultLineWidth(1,1)double=1
        GreyMode logical=false
        PlatformPositionMarker='^'
        PlatformPositionMarkerSize=6
        PlatformPositionMarkerSizeCurrent=10
        PlatformPositionButtonDownFcn=''
        PlatformPositionTag='PlatformPositionTag'
        PlatformPositionUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        PlatformExtentFaceAlpha matlab.internal.datatype.matlab.graphics.datatype.MeshAlpha=0.2
        PlatformExtentFaceAlphaCurrent matlab.internal.datatype.matlab.graphics.datatype.MeshAlpha=0.6
        PlatformExtentButtonDownFcn=''
        PlatformExtentTag='PlatformExtentTag'
        PlatformExtentUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        WaypointsMarker='o'
        WaypointsMarkerSize=6;
        WaypointsMarkerSizeCurrent=8
        WaypointsButtonDownFcn=''
        WaypointsTag='WaypointsTag'
        WaypointsUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        TrajectoryButtonDownFcn=''
        TrajectoryTag='TrajectoryTag'
        TrajectoryUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        CurrentWaypointMarker='o'
        CurrentWaypointMarkerSize=6;
        CurrentWaypointButtonDownFcn=''
        CurrentWaypointTag='CurrentWaypointTag'
        CurrentWaypointUIContextMenu=matlab.graphics.GraphicsPlaceholder.empty
        ZDir=1
    end

    properties(SetAccess=protected,Hidden)

Axes


        PositionLines=matlab.graphics.primitive.Line.empty
        ExtentPatches=matlab.graphics.primitive.Patch.empty
        CurrentWaypointLine=matlab.graphics.primitive.Line.empty
        WaypointLines=matlab.graphics.primitive.Line.empty
        TrajectoryLines=matlab.graphics.primitive.Line.empty
    end

    properties(Dependent)
ZScale
    end

    methods

        function this=ScenarioPlotter(hAxes)
            this.Axes=hAxes;
        end

        function clear(this)
            delete(this.PositionLines);
            delete(this.ExtentPatches);
            delete(this.CurrentWaypointLine);
            delete(this.WaypointLines);
            delete(this.TrajectoryLines);
            this.PositionLines=matlab.graphics.primitive.Line.empty;
            this.ExtentPatches=matlab.graphics.primitive.Patch.empty;
            this.CurrentWaypointLine=matlab.graphics.primitive.Line.empty;
            this.WaypointLines=matlab.graphics.primitive.Line.empty;
            this.TrajectoryLines=matlab.graphics.primitive.Line.empty;
        end

        function update(this,platforms,currentPlatform,playbackEntry)
            if isempty(playbackEntry)
                updateViaPlatformSpecification(this,platforms,currentPlatform);
            else
                updateViaPlaybackEntry(this,platforms,currentPlatform,playbackEntry);
            end
        end

        function updateViaPlatformSpecification(this,platforms,currentPlatform)
            plotPlatformExtents(this,platforms,currentPlatform);
            plotPlatformPositions(this,platforms,currentPlatform);
            plotTrajectories(this,platforms,currentPlatform);
            plotWaypoints(this,currentPlatform);
        end

        function updateCurrentWaypoint(this,currentPlatform,currentWaypoint)
            plotCurrentWaypoint(this,currentPlatform,currentWaypoint);
        end

        function updateViaPlaybackEntry(this,platforms,currentPlatform,playbackEntry)
            plotPlaybackExtents(this,platforms,currentPlatform,playbackEntry)
            plotPlaybackPositions(this,platforms,currentPlatform,playbackEntry)
            if this.ShowTrajectories==isempty(this.TrajectoryLines)
                plotTrajectories(this,platforms,currentPlatform);
            end
            if this.ShowWaypoints==isempty(this.WaypointLines)
                plotWaypoints(this,currentPlatform);
            end
        end

        function plotPlatformPositions(this,platforms,currentPlatform)
            positions=vertcat(platforms(:).Position);
            plotPositions(this,platforms,currentPlatform,positions);
        end

        function plotPlaybackPositions(this,platforms,currentPlatform,playbackEntry)
            poses=playbackEntry.Poses;
            platIDs=vertcat(poses(:).PlatformID);
            positions=vertcat(poses(:).Position);
            plotPositions(this,platforms(platIDs),currentPlatform,positions);
        end

        function plotPositions(this,platforms,currentPlatform,positions)
            ax=this.Axes;

            positionLines=this.PositionLines;
            nPlatforms=numel(platforms);

            zScale=this.ZScale;
            for indx=1:nPlatforms
                platform=platforms(indx);

                markerFaceColor=getPlatformColor(this,platform);
                markerEdgeColor=getSelectionColor(this,platform,currentPlatform);
                markerSize=getSelectionSize(this,platform,currentPlatform);

                if numel(positionLines)<indx||~ishghandle(positionLines(indx))
                    positionLines(indx)=line('Parent',ax,...
                    'Marker',this.PlatformPositionMarker,...
                    'ButtonDownFcn',this.PlatformPositionButtonDownFcn,...
                    'UIContextMenu',this.PlatformPositionUIContextMenu,...
                    'Tag',this.PlatformPositionTag);
                end
                set(positionLines(indx),...
                'MarkerFaceColor',markerFaceColor,...
                'MarkerEdgeColor',markerEdgeColor,...
                'MarkerSize',markerSize,...
                'XData',positions(indx,1),...
                'YData',positions(indx,2),...
                'ZData',zScale.*positions(indx,3),...
                'UserData',platform);
            end

            delete(positionLines(nPlatforms+1:end));
            positionLines(nPlatforms+1:end)=[];
            this.PositionLines=positionLines;
        end

        function plotPlatformExtents(this,platforms,currentPlatform)
            positions=reshape(vertcat(platforms(:).Position),[],3);
            orientationsE=reshape(vertcat(platforms(:).Orientation),[],3);
            orientationsQ=quaternion(fliplr(orientationsE),'eulerd','zyx','frame');
            plotExtents(this,platforms,currentPlatform,positions,orientationsQ);
        end

        function plotPlaybackExtents(this,platforms,currentPlatform,playbackEntry)
            poses=playbackEntry.Poses;
            platIDs=vertcat(poses(:).PlatformID);
            positions=vertcat(poses(:).Position);
            orientationsQ=vertcat(poses(:).Orientation);
            plotExtents(this,platforms(platIDs),currentPlatform,positions,orientationsQ);
        end

        function plotExtents(this,platforms,currentPlatform,positions,orientationsQ)

            ax=this.Axes;

            extentPatches=this.ExtentPatches;
            zScale=this.ZScale;

            nPlatforms=numel(platforms);
            for indx=1:nPlatforms
                platform=platforms(indx);
                if numel(extentPatches)<indx||~ishghandle(extentPatches(indx))
                    extentPatches(indx)=patch('Parent',ax,...
                    'ButtonDownFcn',this.PlatformExtentButtonDownFcn,...
                    'UIContextMenu',this.PlatformExtentUIContextMenu,...
                    'Tag',this.PlatformExtentTag);
                end

                faces=generateFaces(platform,'global',positions(indx,:),orientationsQ(indx));
                faceColor=getPlatformColor(this,platform);
                edgeColor=getSelectionColor(this,platform,currentPlatform);
                faceAlpha=getSelectionAlpha(this,platform,currentPlatform);
                edgeWidth=getSelectionWidth(this,platform,currentPlatform);

                set(extentPatches(indx),...
                'XData',squeeze(faces(1,:,:)),...
                'YData',squeeze(faces(2,:,:)),...
                'ZData',zScale.*squeeze(faces(3,:,:)),...
                'FaceColor',faceColor,...
                'EdgeColor',edgeColor,...
                'FaceAlpha',faceAlpha,...
                'LineWidth',edgeWidth,...
                'UserData',platform);
            end

            delete(extentPatches(nPlatforms+1:end));
            extentPatches(nPlatforms+1:end)=[];
            this.ExtentPatches=extentPatches;
        end

        function plotTrajectories(this,platforms,currentPlatform)
            ax=this.Axes;

            trajectoryLines=this.TrajectoryLines;
            if this.ShowTrajectories
                nPlatforms=numel(platforms);
            else
                nPlatforms=0;
            end

            zScale=this.ZScale;

            for indx=1:nPlatforms
                platform=platforms(indx);

                lineColor=getPlatformColor(this,platform);
                lineWidth=getSelectionWidth(this,platform,currentPlatform);

                if numel(trajectoryLines)<indx||~ishghandle(trajectoryLines(indx))
                    trajectoryLines(indx)=line('Parent',ax,...
                    'ButtonDownFcn',this.TrajectoryButtonDownFcn,...
                    'UIContextMenu',this.TrajectoryUIContextMenu,...
                    'Tag',this.TrajectoryTag);
                end
                pos=trajectoryPreview(platform.TrajectorySpecification);
                set(trajectoryLines(indx),...
                'XData',pos(:,1),...
                'YData',pos(:,2),...
                'ZData',zScale.*pos(:,3),...
                'Color',lineColor,...
                'LineWidth',lineWidth,...
                'UserData',platform);
            end

            delete(trajectoryLines(nPlatforms+1:end));
            trajectoryLines(nPlatforms+1:end)=[];
            this.TrajectoryLines=trajectoryLines;
        end

        function plotWaypoints(this,currentPlatform)
            ax=this.Axes;

            waypointLines=this.WaypointLines;

            if this.ShowWaypoints&&~isempty(currentPlatform)
                zScale=this.ZScale;

                platform=currentPlatform;
                markerEdgeColor=getPlatformColor(this,platform);

                if isempty(waypointLines)||~ishghandle(waypointLines)
                    waypointLines=line('Parent',ax,...
                    'Marker',this.WaypointsMarker,...
                    'MarkerFaceColor',ax.Color,...
                    'MarkerSize',this.WaypointsMarkerSize,...
                    'LineStyle','none',...
                    'ButtonDownFcn',this.WaypointsButtonDownFcn,...
                    'UIContextMenu',this.WaypointsUIContextMenu,...
                    'Tag',this.WaypointsTag);
                end
                pos=platform.TrajectorySpecification.Position(2:end,:);
                set(waypointLines,...
                'MarkerEdgeColor',markerEdgeColor,...
                'XData',pos(:,1),...
                'YData',pos(:,2),...
                'ZData',zScale.*pos(:,3),...
                'UserData',platform);
            else
                delete(waypointLines(:));
                waypointLines(:)=[];
            end

            this.WaypointLines=waypointLines;
        end

        function plotCurrentWaypoint(this,currentPlatform,currentWaypoint)
            ax=this.Axes;
            if~isempty(currentPlatform)
                pos=currentPlatform.TrajectorySpecification.Position;
            else
                pos=zeros(0,3);
            end

            if this.ShowCurrentWaypoint&&0<currentWaypoint&&currentWaypoint<=size(pos,1)
                pos=currentPlatform.TrajectorySpecification.Position;
                zScale=this.ZScale;

                if isempty(this.CurrentWaypointLine)||~ishghandle(this.CurrentWaypointLine)
                    this.CurrentWaypointLine=line('Parent',ax,...
                    'Marker',this.CurrentWaypointMarker,...
                    'MarkerSize',this.WaypointsMarkerSizeCurrent,...
                    'LineStyle','none',...
                    'ButtonDownFcn',this.WaypointsButtonDownFcn,...
                    'UIContextMenu',this.WaypointsUIContextMenu,...
                    'Tag',this.CurrentWaypointTag);
                end

                set(this.CurrentWaypointLine,...
                'MarkerFaceColor',getPlatformColor(this,currentPlatform),...
                'MarkerEdgeColor',getPlatformColor(this,currentPlatform),...
                'XData',pos(currentWaypoint,1),...
                'YData',pos(currentWaypoint,2),...
                'ZData',zScale.*pos(currentWaypoint,3),...
                'UserData',currentPlatform);
            else
                delete(this.CurrentWaypointLine);
                this.CurrentWaypointLine=matlab.graphics.primitive.Line.empty;
            end
        end

        function color=getPlatformColor(this,platform)
            if~this.GreyMode
                index=platform.ID+1;
                cid=mod(index,7);
                if cid==0
                    cid=7;
                end
                color=this.Axes.ColorOrder(cid,:);
            else
                color=[0.5,0.5,0.5];
            end
        end

        function faceAlpha=getSelectionAlpha(this,platform,currentPlatform)
            if this.HighlightCurrentPlatform&&isequal(platform,currentPlatform)
                faceAlpha=this.PlatformExtentFaceAlphaCurrent;
            else
                faceAlpha=this.PlatformExtentFaceAlpha;
            end
        end

        function color=getSelectionColor(this,platform,currentPlatform)
            if~this.GreyMode&&this.HighlightCurrentPlatform&&isequal(platform,currentPlatform)
                color=this.HighlightColor;
            else
                color=getPlatformColor(this,platform);
            end
        end

        function width=getSelectionWidth(this,platform,currentPlatform)
            if this.HighlightCurrentPlatform&&isequal(platform,currentPlatform)
                width=this.HighlightLineWidth;
            else
                width=this.DefaultLineWidth;
            end
        end

        function sz=getSelectionSize(this,platform,currentPlatform)
            if~this.GreyMode&&this.HighlightCurrentPlatform&&isequal(platform,currentPlatform)
                sz=this.PlatformPositionMarkerSizeCurrent;
            else
                sz=this.PlatformPositionMarkerSize;
            end
        end

        function zScale=get.ZScale(this)
            zScale=double(~this.ProjectOntoXYPlane)*this.ZDir;
        end

        function removeContextMenus(this)
            set(this.PositionLines,'UIContextMenu',matlab.graphics.GraphicsPlaceholder.empty);
            set(this.ExtentPatches,'UIContextMenu',matlab.graphics.GraphicsPlaceholder.empty);
            set(this.WaypointLines,'UIContextMenu',matlab.graphics.GraphicsPlaceholder.empty);
            set(this.CurrentWaypointLine,'UIContextMenu',matlab.graphics.GraphicsPlaceholder.empty);
            set(this.TrajectoryLines,'UIContextMenu',matlab.graphics.GraphicsPlaceholder.empty);
        end

        function restoreContextMenus(this)
            set(this.PositionLines,'UIContextMenu',this.PlatformPositionUIContextMenu);
            set(this.ExtentPatches,'UIContextMenu',this.PlatformExtentUIContextMenu);
            set(this.WaypointLines,'UIContextMenu',this.WaypointsUIContextMenu);
            set(this.CurrentWaypointLine,'UIContextMenu',this.CurrentWaypointUIContextMenu);
            set(this.TrajectoryLines,'UIContextMenu',this.TrajectoryUIContextMenu);
        end
    end
end