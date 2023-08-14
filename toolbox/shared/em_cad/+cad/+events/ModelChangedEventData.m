classdef(ConstructOnLoad)ModelChangedEventData<event.EventData





    properties
EventType
CategoryType
ObjectType
Data
ModelInfo
LayerInfo
    end

    methods
        function eventObj=ModelChangedEventData(evtType,CategoryType,ObjectType,info,varargin)
            eventObj.EventType=evtType;
            eventObj.CategoryType=CategoryType;
            eventObj.ObjectType=ObjectType;
            eventObj.Data=info;

            if~isempty(varargin)
                eventObj.ModelInfo=varargin{1};
                if numel(varargin)>1
                    eventObj.LayerInfo=varargin{2};
                end
            end

        end

    end
end
