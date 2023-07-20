classdef DragWaypointXY<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragWaypointXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            idx=this.Canvas.CurrentWaypoint;
            currentPoint=getCurrentPoint(this.Canvas);
            setTooltipString(this,getWaypointCursorTextXY(this,idx,currentPoint));
            setCurrentWaypointXY(this.Application,currentPoint(1:2));
        end

        function performButtonDown(~,~,~)

        end

        function performButtonUp(this,src,evt)%#ok<INUSD>
            idx=this.Canvas.CurrentWaypoint;
            newTraj=this.CurrentPlatform.TrajectorySpecification;
            currentPoint=getCurrentPoint(this.Canvas);
            newTraj.Position(idx,1:2)=currentPoint(1:2);
            autoAdjust(newTraj);
            oldTraj=this.Canvas.CachedTrajectory;
            changeTrajectory(this.Application,idx,newTraj,idx,oldTraj);
            setCanvasMode(this,'Explore');
        end

        function cancel(this)
            setCanvasMode(this,'Explore');
        end
    end
end