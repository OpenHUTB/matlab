classdef ModeListener<event.proplistener






    methods
        function obj=ModeListener(classObj,propObject,eventType,callback,fig)
            obj=obj@event.proplistener(classObj,propObject,eventType,callback);
            obj.Figure=fig;
        end
    end

    properties
        Figure;
    end

end
