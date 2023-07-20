classdef ZoomDirectionListener<handle





    properties
        Listener;
        LastModeStateData;
    end

    methods
        function this=ZoomDirectionListener(modeManager,callback)
            this.Listener=event.listener(modeManager,...
            'ModeStateDataChange',@(modeManager,d)eventHandler(this,modeManager,callback));
        end

        function eventHandler(this,modeManager,callback)
            if~isempty(modeManager.CurrentMode)&&strcmp(modeManager.CurrentMode.Name,'Exploration.Zoom')&&...
                isfield(modeManager.CurrentMode.ModeStateData,'Direction')


                if isempty(this.LastModeStateData)||~isequal(this.LastModeStateData.Direction,modeManager.CurrentMode.ModeStateData.Direction)
                    feval(callback);
                end
                this.LastModeStateData=modeManager.CurrentMode.ModeStateData;
            end
        end
    end
end