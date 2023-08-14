classdef AxesInteractionStrategy<matlab.graphics.interaction.uiaxes.InteractionStrategy



    properties
fig
ax
Chart
    end

    methods
        function hObj=AxesInteractionStrategy(ax_handle)
            hObj.fig=ancestor(ax_handle,'figure');
            hObj.ax=ax_handle;
        end

        function tf=isValidMouseEvent(strategy,~,~,e)
            if isprop(e,'Chart')&&~isempty(strategy.Chart)
                tf=(e.Chart==strategy.Chart);
            else
                if isactiveuimode(strategy.fig,'Standard.EditPlot')
                    tf=false;
                    return
                end
                tf=matlab.graphics.interaction.uiaxes.AxesInteractionStrategy.hitAxes(strategy.fig,strategy.ax,e.HitObject,e.Point);
            end
        end
    end

    methods(Static)
        function isHit=hitAxes(fig,ax,hitObj,pt)
            import matlab.graphics.interaction.internal.*
            ax_container=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
            hitobj_container=ancestor(hitObj,'matlab.ui.internal.mixin.CanvasHostMixin');

            container=[];
            if(ax_container==hitobj_container)
                container=ax_container;
            end

            isHit=false;
            if~isempty(container)&&isvalid(container)
                vp=getViewportInDevicePixels(fig,container);
                offsets=matlab.graphics.interaction.uiaxes.AxesInteractionStrategy.calculateOffset(container,ax);
                pixelpt=getPointInPixels(fig,pt);
                isHit=isAxesHit(ax,vp,pixelpt,offsets);
            end
        end


        function offset=calculateOffset(container,ax)
            offset=[0,0];
            if isa(container,'matlab.ui.internal.mixin.CanvasHostMixin')&&~isempty(ax)
                if isa(ax.Parent,'matlab.graphics.chart.Chart')
                    pixelpos=matlab.graphics.chart.internal.getOrangeChartChildPixelPosition(ax);
                else
                    pixelpos=getpixelposition(ax,true);
                end
                pos=ax.GetLayoutInformation.Position;
                offset=pixelpos(1:2)-pos(1:2);
            end
        end
    end
end

