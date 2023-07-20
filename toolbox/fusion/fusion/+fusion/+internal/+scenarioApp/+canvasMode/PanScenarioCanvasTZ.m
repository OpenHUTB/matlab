classdef PanScenarioCanvasTZ<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=PanScenarioCanvasTZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            drag=this.Canvas.InitialPoint-currentPoint;
            requestTZDrag(this.Application,drag);
            setTooltipString(this,'');
        end

        function performButtonDown(this,~,~)
            cancel(this);
        end

        function performButtonUp(this,~,~)

            cancel(this);
        end

        function cancel(this)
            setCanvasMode(this,'Explore');
        end
    end
end