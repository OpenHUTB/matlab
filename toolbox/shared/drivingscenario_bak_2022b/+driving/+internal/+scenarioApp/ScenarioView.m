classdef ScenarioView<driving.internal.scenarioApp.BaseView&...
    driving.internal.scenarioApp.Zoom&...
    driving.internal.scenarioApp.FillAxes




    properties


        VerticalAxis{mustBeMember(VerticalAxis,{'X','Y'})}=driving.internal.scenarioApp.ScenarioView.DefaultVerticalAxis;
    end

    properties(SetAccess=protected,Hidden)
RoadEditPoints
BarrierEditPoints
TimeStampTimer
TimeStamp
        TimeStampLeftEdge=inf;
    end

    properties(Hidden)
        Center=[0,0];
        UnitsPerPixel=0.2;
    end

    properties(Constant,Hidden)
        DefaultVerticalAxis=driving.scenario.Plot.DefaultVerticalAxis;
    end

    methods

        function this=ScenarioView(varargin)

            this@driving.internal.scenarioApp.BaseView(varargin{:});
            this.ShowWaypoints=true;
        end

        function initializeFloatingPalette(this,fig,ax)
            this.FloatingPalette=driving.internal.scenarioApp.ScenarioCanvasPalette(...
            fig,ax,@(~,~)zoomIn(this),@(~,~)zoomOut(this),...
            @(~,~)fitToView(this));
        end

        function startTimeStampTimer(this)
            t=this.TimeStampTimer;
            if isempty(t)||~isvalid(t)
                t=timer('Tag','DrivingScenarioTimeStampTimer',...
                'Period',0.5,...
                'ExecutionMode','fixedSpacing',...
                'TimerFcn',@this.timeStampTimerTick);
                this.TimeStampTimer=t;
            end

            if strcmp(t.Running,'off')
                start(t);
            end
        end

        function stopTimeStampTimer(this)
            deleteTimeStampTimer(this);
            timeStampTimerTick(this);
        end

        function deleteTimeStampTimer(this)
            t=this.TimeStampTimer;
            try
                this.TimeStampTimer=[];
                if strcmp(t.Running,'on')
                    stop(t);
                end
                delete(t);
            catch ME %#ok<NASGU>

            end
        end

        function update(this)


            if isempty(this.Figure)
                return;
            end

            update@driving.internal.scenarioApp.BaseView(this);

            hAxes=this.Axes;
            hApp=this.Application;
            roadSpecs=hApp.RoadSpecifications;


            delete(this.RoadEditPoints);
            delete(this.BarrierEditPoints);


            showCenters=getShowRoadEditPoints(this);
            roadCenters=matlab.graphics.primitive.Line.empty;
            roadCentersOffset=0.5;
            orientation=hApp.AxesOrientation;
            if strcmp(orientation,'NED')
                roadCentersOffset=-0.5;
            end
            for indx=1:numel(roadSpecs)
                if showCenters
                    roadCenters(indx)=plotEditPoints(roadSpecs(indx),hAxes,this);
                    roadCenters(indx).Tag='RoadEditPoint';
                    roadCenters(indx).UserData=roadSpecs(indx);

                    roadCenters(indx).ZData=roadCenters(indx).ZData+roadCentersOffset;
                end
            end
            this.RoadEditPoints=roadCenters;


            barrierSpecs=hApp.BarrierSpecifications;
            showBarrierCenters=getShowBarrierEditPoints(this);
            barrierCenters=matlab.graphics.primitive.Line.empty;
            barrierCentersOffset=0.5;
            orientation=hApp.AxesOrientation;
            if strcmp(orientation,'NED')
                barrierCentersOffset=-0.5;
            end
            for indx=1:numel(barrierSpecs)
                if showBarrierCenters
                    barrierCenters(indx)=plotEditPoints(barrierSpecs(indx),hAxes,this);
                    barrierCenters(indx).Tag='BarrierEditPoint';
                    barrierCenters(indx).UserData=barrierSpecs(indx);

                    barrierCenters(indx).ZData=barrierCenters(indx).ZData+barrierSpecs(indx).Height+barrierCentersOffset;
                end
            end
            this.BarrierEditPoints=barrierCenters;

            offset=driving.scenario.internal.AxesOrientation.getOffset(orientation);


            actors=hApp.Scenario.Actors;idx=arrayfun(@(thisActor)eq(thisActor.IsVisible,true),actors);
            nActorLines=size(this.ActorLines,1);
            idx(nActorLines+1:end)=[];
            set(findall(this.ActorLines(idx,1),'type','line'),'Visible',matlabshared.application.logicalToOnOff(getShowWaypoints(this)));


            for indx=1:numel(this.ActorLines)
                if isa(this.ActorLines(indx),'matlab.graphics.primitive.Line')
                    this.ActorLines(indx).ZData=this.ActorLines(indx).ZData+0.5*offset;
                end
            end


            set(hAxes,'ZLimMode','auto');



            this.EnablePlotWaypointsUpdate=false;
            isSpawn=arrayfun(@(thisActor)gt(thisActor.EntryTime,0),actors,'UniformOutput',false);
            isDespawn=arrayfun(@(thisActor)lt(thisActor.ExitTime,Inf),actors,'UniformOutput',false);
            if any(cell2mat(isSpawn))||any(cell2mat(isDespawn))
                this.EnablePlotWaypointsUpdate=true;
            end
        end

        function name=getName(~)

            name=getString(message('driving:scenarioApp:ScenarioViewTitle'));
        end

        function tag=getTag(~)

            tag='ScenarioCanvas';
        end

        function resize(this)
            resize@driving.internal.scenarioApp.BaseView(this);

            this.TimeStampLeftEdge=inf;
            fixTimeStampLocation(this);
            updateLimits(this);
        end

        function set.VerticalAxis(this,v)
            if~strcmp(v,this.VerticalAxis)
                this.VerticalAxis=v;
                setView(this.Axes,v);
            end
        end

    end

    methods(Hidden)

        function fitToView(this)




            lines=findall(this.ActorLines,'type','line');
            if isempty(lines)
                actorWaypoints=zeros(0,3);
            else
                actorWaypoints=[horzcat(lines.XData)',...
                horzcat(lines.YData)',horzcat(lines.ZData)'];
            end
            actorPatches=findall(this.ActorPatches,'type','patch');
            if isempty(actorPatches)
                actorVertices=zeros(0,3);
            else
                actorVertices=vertcat(actorPatches.Vertices);
            end
            roadPatches=findall(this.RoadPatches,'type','patch');
            if isempty(roadPatches)
                roadVertices=zeros(0,3);
            else
                roadVertices=vertcat(roadPatches.Vertices);
            end
            barrierPatches=findall(this.BarrierPatches,'type','patch');
            if isempty(barrierPatches)
                barrierVertices=zeros(0,3);
            else
                barrierVertices=vertcat(barrierPatches.Vertices);
            end
            verts=vertcat(barrierVertices,roadVertices,actorVertices,actorWaypoints);

            if isempty(verts)
                this.applyDefaultAxesLimits();
            else

                [xMin,xMax]=bounds(verts(:,1));
                [yMin,yMax]=bounds(verts(:,2));

                [minSpan,maxSpan]=this.getAxesSpan();
                minHalf=minSpan/2;
                maxHalf=maxSpan/2;


                bufferPercent=5;
                f=1+bufferPercent/100;


                half=f*(xMax-xMin)/2;
                half=min(max(half,minHalf),maxHalf);
                xLim=[-half,half]+(xMin+xMax)/2;

                half=f*(yMax-yMin)/2;
                half=min(max(half,minHalf),maxHalf);
                yLim=[-half,half]+(yMin+yMax)/2;

                if strcmp(this.VerticalAxis,'X')
                    this.applyAxesLimits(yLim,xLim);
                else
                    this.applyAxesLimits(xLim,yLim);
                end
            end
        end

        function applyAxesLimits(this,varargin)
            applyAxesLimits@matlabshared.application.FillAxes(this,varargin{:});
        end

        function hAxes=getAxes(this)
            hAxes=this.Axes;
        end

        function hFig=getFigure(this)
            hFig=this.Figure;
        end

        function[min,max]=getAxesSpan(~)


            min=2;
            max=1e4;
        end
    end

    methods(Access=protected)

        function b=getShowRoadEditPoints(this)
            b=this.ShowRoadEditPoints;
        end

        function b=getShowBarrierEditPoints(this)
            b=this.ShowBarrierEditPoints;
        end

        function b=getShowWaypoints(~)
            b=true;
        end

        function hFig=createFigure(this)
            hFig=createFigure@driving.internal.scenarioApp.BaseView(this);


            hAxes=this.Axes;
            axis(hAxes,'vis3d');
            set(hAxes,...
            'LooseInset',[0.06,0.05,0.03,0.03],...
            'Box','on',...
            'Projection','orthographic',...
            'ZLimMode','auto');

            hAxes.Camera.TransparencyMethodHint='objectsort';

            xlabel(hAxes,'X (m)');
            ylabel(hAxes,'Y (m)');
            zlabel(hAxes,'Z (m)');
            axis(hAxes,'vis3d');
            setView(hAxes,this.VerticalAxis);
            grid(hAxes,'off');
            grid(hAxes,'on');
            grid(hAxes,'minor');


            set(hAxes,...
            'CameraPositionMode','auto',...
            'CameraTargetMode','auto',...
            'CameraUpVectorMode','auto',...
            'CameraViewAngleMode','auto');
            if useAppContainer(this.Application)
                this.TimeStamp=uilabel('Parent',hFig,'Text','');
            else
                this.TimeStamp=uicontrol('Parent',hFig,...
                'HorizontalAlignment','left',...
                'Style','text');
            end

            this.applyDefaultAxesLimits();
        end

        function applyDefaultAxesLimits(this)
            applyAxesLimits(this,[-25,25],[0,50]);
        end

        function timeStampTimerTick(this,~,~)
            try
                newTime=getCurrentTime(this.Application.Simulator);
                if newTime==0
                    this.TimeStampLeftEdge=inf;
                end
                str=sprintf('T=%gs',newTime);
                if useAppContainer(this.Application)
                    set(this.TimeStamp,'text',str);
                else
                    set(this.TimeStamp,'String',str);
                end
                fixTimeStampLocation(this)
            catch me %#ok<NASGU>

            end
        end

        function fixTimeStampLocation(this)
            figpos=getpixelposition(this.Figure);
            timeStamp=this.TimeStamp;
            if useAppContainer(this.Application)
                w=matlabshared.application.layout.AbstractLayout.getMinimumWidth(timeStamp);
            else
                ext=get(timeStamp,'Extent');
                w=ext(3);
            end
            leftEdge=this.TimeStampLeftEdge;
            newLeftEdge=figpos(3)-w-5;
            if newLeftEdge<leftEdge
                leftEdge=newLeftEdge;
                this.TimeStampLeftEdge=leftEdge;
            end
            set(timeStamp,'Position',[leftEdge,5,w,20]);
        end
    end
end

function setView(ax,hv)
    [az,el]=view(ax);
    switch hv
    case 'Y'
        az=0;
    case 'X'
        az=-90;
    end
    view(ax,az,el);
end


