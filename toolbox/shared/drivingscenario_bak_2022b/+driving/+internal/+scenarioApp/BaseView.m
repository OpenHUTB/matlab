classdef BaseView<matlabshared.application.Component
    properties
        ShowRoadEditPoints=false;
        ShowBarrierEditPoints=false;
        ShowCenterline=false;
        ShowWaypoints=false;
        EnablePlotWaypointsUpdate=false;
    end

    properties(SetAccess=protected,Hidden)
Axes
RoadPatches
BarrierPatches
RoadBoundaries
LaneTypesPatch
LaneMarkingsPatch
ActorPatches
ActorLines
    end

    properties(Hidden,Dependent)
Centerline
    end

    properties(Constant,Hidden)
        RoadTileFaceColor=[.8,.8,.8]
        RoadTileEdgeColor=[.7,.7,.7]
        RoadBorderColor=[0,0,0]
        RoadCenterlineColor=[1,1,1]
    end

    methods
        function this=BaseView(varargin)
            this@matlabshared.application.Component(varargin{:});
        end

        function centerline=get.Centerline(this)
            if this.ShowCenterline
                centerline='on';
            else
                centerline='off';
            end
        end

        function set.ShowWaypoints(this,showWaypoints)
            this.ShowWaypoints=showWaypoints;
            update(this);
        end

        function set.ShowRoadEditPoints(this,showRoadEditPoints)
            this.ShowRoadEditPoints=showRoadEditPoints;
            update(this);
        end

        function set.ShowBarrierEditPoints(this,showBarrierEditPoints)
            this.ShowBarrierEditPoints=showBarrierEditPoints;
            update(this);
        end

        function set.ShowCenterline(this,showCenterline)
            this.ShowCenterline=showCenterline;
            update(this);
        end

        function updateActor(this,actorId,full)
            if nargin<3
                full=false;
            end
            if nargin<2
                actorId=[];
            end
            app=this.Application;
            hAxes=this.Axes;
            actor=app.Scenario.Actors;
            oldActorPatch=this.ActorPatches;
            opts=getPlotActorsOptions(this);
            if isempty(actorId)
                opts.FullPaint=full;
            else
                opts.FullPaint=true;
                actor=actor(actorId);
                oldActorPatch=oldActorPatch(actorId);
            end
            actorPatch=driving.scenario.internal.plotActors(actor,hAxes,oldActorPatch,opts);
            newActorObjects=false;
            if isempty(actorId)
                this.ActorPatches=actorPatch;
                newActorObjects=~isequal(actorPatch,oldActorPatch);
            end

            if this.ShowWaypoints&&(~isempty(actorId)||this.EnablePlotWaypointsUpdate||full)&&isStopped(app.Simulator)

                actorLines=this.ActorLines;
                newActorLines={};
                if(full&&isempty(actorId))||this.EnablePlotWaypointsUpdate
                    delete(actorLines);
                    actorLines=matlab.graphics.primitive.Line.empty([0,2]);
                    this.ActorLines=actorLines;
                    newActorLines{1}=driving.scenario.internal.plotActorWaypoints(actor,hAxes,actorLines,this.ShowWaypointsDuringSim||full);
                elseif~isempty(actorId)
                    for iActor=1:numel(actorId)
                        if size(actorLines,1)<actorId(iActor)
                            actorLines(actorId(iActor),:)=repmat(matlab.graphics.GraphicsPlaceholder,1,2);
                        end
                        newActorLines{iActor}=driving.scenario.internal.plotActorWaypoints(actor(iActor),hAxes,actorLines(actorId(iActor),:),this.ShowWaypointsDuringSim||full);
                    end
                end

                offset=driving.scenario.internal.AxesOrientation.getOffset(app.AxesOrientation);
                for indx=1:numel(newActorLines)
                    if~isequal(newActorLines{indx},actorLines)
                        if~isempty(actorId)
                            this.ActorLines(actorId(indx),:)=newActorLines{indx};
                        else
                            this.ActorLines=newActorLines{indx};
                        end
                        newActorObjects=true;
                    end
                    if~isempty(newActorLines)&&~isempty(newActorLines{indx})&&isa(newActorLines{indx}(1),'matlab.graphics.primitive.Line')
                        newActorLines{indx}(1).ZData=newActorLines{indx}(1).ZData+0.5*offset;%#ok<*AGROW>
                    end
                end
            end

            if newActorObjects
                onNewActorObjects(this);
            end

        end

        function update(this)
            hAxes=this.Axes;
            if isempty(hAxes)
                return;
            end

            deleteScene(this);

            scenario=this.Application.Scenario;
            actors=scenario.Actors;
            barriers=scenario.Barriers;
            roadTiles=scenario.RoadTiles;
            [this.RoadPatches,~,lmCount,lCount]=driving.scenario.internal.plotRoadTiles(roadTiles,hAxes,this);

            this.LaneTypesPatch=driving.scenario.internal.plotLaneTypes(roadTiles,hAxes,this,lCount);
            this.LaneMarkingsPatch=driving.scenario.internal.plotLaneMarkings(roadTiles,hAxes,lmCount,this);
            this.RoadBoundaries=driving.scenario.internal.plotRoadBoundaries(roadBoundaries(scenario),hAxes,this,scenario.ShowRoadBorders);

            opts=getPlotActorsOptions(this);

            opts.FullPaint=true;
            this.ActorPatches=driving.scenario.internal.plotActors(actors,hAxes,this.ActorPatches,opts);
            if this.ShowWaypoints
                this.ActorLines=driving.scenario.internal.plotActorWaypoints(actors,hAxes);
            else
                this.ActorLines=[];
            end


            for i=1:numel(barriers)
                barrierSegments=[barriers(i).BarrierSegments];
                this.BarrierPatches(i)=driving.scenario.internal.plotBarriers(barrierSegments,hAxes,opts);
            end

            dir=driving.scenario.internal.AxesOrientation.getAxesDir(scenario.AxesOrientation);
            set(hAxes,'YDir',dir,'ZDir',dir);

            if~useAppContainer(this.Application)
                uistack(fliplr(this.ActorPatches),'top');
            end
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            this.Axes=axes('Parent',hFig,...
            'Interactions',[],...
            'Tag',[getTag(this),'Axes']);
        end
        function onNewActorObjects(~)

        end
        function opts=getPlotActorsOptions(this)

            opts=struct('FullPaint',false,'AxesOrientation',this.Application.AxesOrientation,'EgoActor',[]);
        end
        function deleteScene(this)

            delete(this.RoadPatches);
            delete(this.BarrierPatches);
            delete(this.LaneTypesPatch);
            delete(this.RoadBoundaries);
            delete(this.LaneMarkingsPatch);
            delete(this.ActorLines);
            this.RoadPatches=[];
            this.BarrierPatches=[];
            this.LaneTypesPatch=[];
            this.RoadBoundaries=[];
            this.LaneMarkingsPatch=[];
            this.ActorLines=[];
        end

        function deleteActors(this)
            delete(this.ActorPatches);
            this.ActorPatches=[];
        end
    end
end


