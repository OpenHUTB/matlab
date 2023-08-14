classdef HoverMode<fusion.internal.scenarioApp.canvasMode.CanvasMode

    properties(Transient)
        EnableDrag=false
    end

    methods
        function this=HoverMode(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function flag=testHover(this,hSrc)
            flag=hoverSuccessful(this,hSrc);
            if flag
                currentPlatform=getCurrentPlatform(this.Application);
                this.EnableDrag=isequal(hSrc.UserData,currentPlatform);
            else
                this.EnableDrag=false;
            end
        end

        function update(this)

            if this.EnableDrag
                set(this.Canvas.Figure,'Pointer',pointerIcon(this));
            else
                set(this.Canvas.Figure,'Pointer','hand');
            end
        end

        function performMouseMove(this,~,~)
            hSrc=hittest(this.Canvas.Figure);
            if~testHover(this,hSrc)
                cancel(this);
            end
        end

        function performButtonUp(this,~,~)
            cancel(this);
        end

        function cancel(this)
            setCanvasMode(this,'Explore');
        end
    end

    methods(Abstract)
        flag=hoverSuccessful(this,hSrc)
    end
end