classdef AddWaypoints<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=AddWaypoints(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='cross';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            if~isempty(this.Canvas.ActiveCanvas)&&endsWith(this.Canvas.ActiveCanvas.Tag,'xy')
                setTooltipString(this,getCursorTextXY(this,currentPoint))
                extendCurrentTrajectory(this.Application,this.Canvas.CachedTrajectory,currentPoint(1:2));
            else
                setTooltipString(this,'');
            end
        end

        function performButtonDown(this,~,~)

            if isDoubleClick(this.Canvas)||isRightClick(this.Canvas)


                setCurrentWaypoint(this.Application,0);
                setCanvasMode(this,'Explore');
            end
        end

        function performButtonUp(this,~,~)

            updateXYAxesHelpText(this.Canvas)

            currentPoint=getCurrentPoint(this.Canvas);

            oldTraj=this.Canvas.CachedTrajectory;
            oldIdx=length(oldTraj.TimeOfArrival);

            newTraj=extend(oldTraj,currentPoint(1:2));
            newIdx=length(newTraj.TimeOfArrival);

            changeTrajectory(this.Application,newIdx,newTraj,oldIdx,oldTraj);
            this.Canvas.CachedTrajectory=newTraj;
        end

        function accept(this)
            accept@fusion.internal.scenarioApp.canvasMode.CanvasMode(this);
            setCurrentWaypoint(this.Application,0);
            setCanvasMode(this,'Explore');
        end

        function cancel(this)
            replaceCurrentTrajectory(this.Application,this.Canvas.CachedTrajectory);
            setCanvasMode(this,'Explore');
        end


        function setCanvasMode(this,newMode)


            setCanvasMode(this.Canvas,newMode);
        end
    end
end