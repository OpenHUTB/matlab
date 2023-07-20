classdef FigurePointerModeStrategy<matlab.graphics.controls.internal.PointerModeStrategy



    properties
        FigureModeChangeListener;
    end

    methods
        function handleModeChange(obj,~,eventData)



            if~obj.isModeEnabled(eventData.AffectedObject.FigureHandle,eventData)
                eventData.AffectedObject.FigureHandle.PointerMode='auto';
            end
        end

        function result=isModeEnabled(~,sourceObj,~)
            result=false;

            fig=ancestor(sourceObj,'matlab.ui.Figure');

            if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)...
                &&~isstruct(fig.ModeManager)
                result=~isempty(fig.ModeManager.Currentmode);
            end
        end

        function createModeListener(obj,sourceObj,~)
            if isempty(obj.FigureModeChangeListener)

                fig=ancestor(sourceObj,'matlab.ui.Figure');

                if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)...
                    &&~isstruct(fig.ModeManager)

                    obj.FigureModeChangeListener=event.proplistener(fig.ModeManager,...
                    fig.ModeManager.findprop('CurrentMode'),'PostSet',@(e,d)obj.handleModeChange(e,d));

                end
            end
        end
    end
end

