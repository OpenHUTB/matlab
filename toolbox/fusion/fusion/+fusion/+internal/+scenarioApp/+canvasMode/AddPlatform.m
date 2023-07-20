classdef AddPlatform<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=AddPlatform(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='cross';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            if~isempty(this.Canvas.ActiveCanvas)&&endsWith(this.Canvas.ActiveCanvas.Tag,'xy')&&isOverAxes(this.Canvas)
                setTooltipString(this,getCursorTextXY(this,getCurrentPoint(this.Canvas)));
            end
        end

        function performButtonDown(this,src,evt)%#ok<INUSD>

        end

        function performButtonUp(this,~,~)
            hApp=this.Application;
            newPlatform=hApp.PlatformToAdd;
            cp=getCurrentPoint(this.Canvas);
            traj=newPlatform.TrajectorySpecification;
            offset=horzcat(cp(1:2)-traj.Position(1,1:2),0);
            traj.Position=traj.Position+offset;
            autoAdjust(traj);
            hApp.addPlatform(newPlatform);

            setCanvasMode(this,'Explore');
        end

        function cancel(this)

            setCanvasMode(this,'Explore');
        end
    end
end