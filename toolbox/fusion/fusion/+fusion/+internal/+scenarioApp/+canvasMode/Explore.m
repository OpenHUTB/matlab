classdef Explore<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=Explore(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function update(this)
            update@fusion.internal.scenarioApp.canvasMode.CanvasMode(this);
            setTooltipString(this,'');
        end

        function ptr=pointerIcon(~)
            ptr='arrow';
        end

        function performMouseMove(this,~,evt)
            if ishghandle(evt.HitObject)...
                &&startsWith(evt.HitObject.Tag,'scenariocanvas.')...
                &&strcmp(evt.HitObject.Type,'axes')
                this.Canvas.ActiveCanvas=evt.HitObject;
            end

            hoverModes=["HoverPlatformXY",...
            "HoverWaypointXY",...
            "HoverWaypointTZ",...
            "HoverWaypointZ",...
            "HoverTrajectoryXY",...
            "HoverTrajectoryZ"];

            hSrc=hittest(this.Canvas.Figure);
            for mode=hoverModes
                if testHover(this.Canvas.CanvasModes(mode),hSrc)
                    setCanvasMode(this,mode);
                    break
                end
            end
        end

        function performButtonDown(this,hSrc,evt)%#ok<INUSD>
            if strcmp(hSrc.Tag,'scenariocanvas.xy')&&(isLeftClick(this.Canvas)||isExtendedClick(this.Canvas))


                this.Canvas.ActiveCanvas=hSrc;
                this.Canvas.CachedCenter=this.Canvas.XYCenter;
                setCanvasMode(this,'PanScenarioCanvasXY');
            elseif strcmp(hSrc.Tag,'scenariocanvas.tz')&&(isLeftClick(this.Canvas)||isExtendedClick(this.Canvas))


                this.Canvas.ActiveCanvas=hSrc;
                this.Canvas.CachedCenter=this.Canvas.TZCenter;
                setCanvasMode(this,'PanScenarioCanvasTZ');
            elseif isRightClick(this.Canvas)
                restoreContextMenus(this.Canvas);
            end
            setCurrentWaypoint(this.Application,0);
        end

        function performButtonUp(this,~,~)
            cancel(this);
        end

        function accept(this)

            hSrc=hittest(this.Canvas.Figure);
            if~startsWith(hSrc.Tag,'scenariocanvas.')
                performButtonUp(this,hSrc)
                performButtonDown(this,hSrc)
            end
        end

        function cancel(this)
            this.Canvas.ActiveCanvas=[];
            update(this.Canvas);
        end
    end
end