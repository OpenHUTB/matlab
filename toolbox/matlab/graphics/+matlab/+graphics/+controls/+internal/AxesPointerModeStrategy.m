classdef AxesPointerModeStrategy<matlab.graphics.controls.internal.PointerModeStrategy



    properties
        Axes;
        ModeListener;
    end

    methods
        function handleModeChange(obj,sourceObj,eventData)


            if~isvalid(obj)
                return
            end




            if~obj.isModeEnabled(sourceObj,eventData)
                if~isempty(obj.Axes)
                    fig=ancestor(obj.Axes,'matlab.ui.Figure');
                    fig.PointerMode='auto';
                end
            end
        end

        function result=isModeEnabled(obj,~,eventData)

            ax=obj.Axes;

            if isempty(ax)&&isprop(eventData,'Primitive')
                ax=ancestor(eventData.Primitive,'matlab.graphics.axis.AbstractAxes');
            end

            result=~isempty(ax)&&isvalid(ax)&&~isempty(ax.InteractionContainer.CurrentMode)&&...
            ~strcmp(ax.InteractionContainer.CurrentMode,'none');
        end

        function createModeListener(obj,~,eventData)
            ax=[];

            if isprop(eventData,'Primitive')
                ax=ancestor(eventData.Primitive,'matlab.graphics.axis.AbstractAxes');
            end

            if~isempty(ax)&&isprop(ax,'InteractionContainer')

                obj.Axes=ax;

                if~isprop(ax,'PointerModeListener')
                    p=addprop(ax,'PointerModeListener');
                    p.Hidden=true;
                    p.Transient=true;
                    obj.ModeListener=event.proplistener(ax.InteractionContainer,...
                    ax.InteractionContainer.findprop('CurrentMode'),'PostSet',...
                    @(e,d)obj.handleModeChange(e,d));
                    ax.PointerModeListener='on';
                end
            end
        end
    end
end

