
classdef(ConstructOnLoad)ROILabelEventData<event.EventData
    properties
        Data;
        ActionType=vision.internal.labeler.tool.actionType.Recreate
    end

    methods
        function this=ROILabelEventData(data,varargin)
            this.Data=data;
            if nargin>1
                this.ActionType=varargin{1};
            end
        end
    end
end
