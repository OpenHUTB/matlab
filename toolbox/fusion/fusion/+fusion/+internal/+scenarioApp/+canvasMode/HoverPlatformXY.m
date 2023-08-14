classdef HoverPlatformXY<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverPlatformXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='fleur';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=any(strcmp(hSrc.Tag,{'platform.position.xy','platform.extent.xy'}));
            if flag
                if strcmp(hSrc.Tag,'platform.position.xy')
                    setTooltipString(this,...
                    {strcat(hSrc.UserData.Name,' (origin)');...
                    getCursorTextXY(this,hSrc.UserData.Position)});
                else
                    setTooltipString(this,hSrc.UserData.Name);
                end
            end
        end

        function performButtonDown(this,hSrc,~)
            if any(strcmp(hSrc.Tag,{'platform.position.xy','platform.extent.xy'}))


                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    this.Canvas.CurrentWaypoint=1;
                    this.Canvas.CachedPosition=platform.Position;
                    setCanvasMode(this,'DragPlatformXY');
                end
            else
                cancel(this);
            end
        end
    end
end