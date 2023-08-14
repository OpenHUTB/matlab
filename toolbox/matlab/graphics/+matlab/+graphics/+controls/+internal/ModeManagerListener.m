classdef ModeManagerListener<event.listener





    methods
        function obj=ModeManagerListener(classObj,eventType,callback,fig)
            obj=obj@event.listener(classObj,eventType,callback);
            obj.Figure=fig;
        end
    end

    properties
        Figure;
    end

end
