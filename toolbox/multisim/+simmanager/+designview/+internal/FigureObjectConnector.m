classdef(Abstract)FigureObjectConnector<handle
    properties(Access=private)
FigureControlChannel
    end

    properties(Access=protected)
FigureObject
    end

    methods
        function obj=FigureObjectConnector(figureObject)
            channelPrefix="/simmanager/designview/"+figureObject.CanvasId;
            obj.FigureControlChannel=channelPrefix+"/figureControlMatlab";
            obj.FigureObject=figureObject;
        end
    end

    methods(Access=protected)
        function publish(obj,msgContent)
            message.publish(obj.FigureControlChannel,msgContent);
        end
    end
end