classdef DragTrajectoryXY<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragTrajectoryXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            setTooltipString(this,getCursorTextXY(this,currentPoint));
            moveCurrentTrajectory(this.Application,this.Canvas.CachedTrajectory,currentPoint-this.Canvas.CachedPosition);
        end

        function performButtonDown(this,src,evt)%#ok<INUSD>
            cancel(this);
        end

        function performButtonUp(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            oldTraj=this.Canvas.CachedTrajectory;
            moveCurrentTrajectory(this.Application,oldTraj,currentPoint-this.Canvas.CachedPosition);
            currentPlatform=getCurrentPlatform(this.Application);
            newTraj=currentPlatform.TrajectorySpecification;
            changeTrajectory(this.Application,0,newTraj,0,oldTraj);
            setCanvasMode(this,'Explore');
        end

        function cancel(this)
            setCanvasMode(this,'Explore');
        end
    end
end