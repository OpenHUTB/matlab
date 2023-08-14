classdef(ConstructOnLoad)AddEventData<event.EventData





    properties
CategoryType
ObjectType
Data
    end

    methods
        function eventObj=AddEventData(CategoryType,ObjectType,varargin)
            eventObj.CategoryType=CategoryType;
            eventObj.ObjectType=ObjectType;
            switch CategoryType
            case 'Shape'
                eventObj.Data.BBox=varargin{1};
                if strcmpi(ObjectType,'Polygon')
                    eventObj.Data.Vertices=varargin{2};
                end
            case 'Operation'
                eventObj.Data.ShapesId=varargin{1};
                if strcmpi(ObjectType,'Move')
                    eventObj.Data.FirstPoint=varargin{2};
                    eventObj.Data.LastPoint=varargin{3};
                elseif strcmpi(ObjectType,'Resize')
                    eventObj.Data.BoundsVal=varargin{2};
                elseif strcmpi(ObjectType,'Rotate')
                    eventObj.Data.RotateVal=varargin{2};
                    eventObj.Data.RotateAxis=varargin{3};
                end
            case 'Feed'
                eventObj.Data.BBox=varargin{1};
            case 'Via'
                eventObj.Data.BBox=varargin{1};
            case 'Load'
                eventObj.Data.BBox=varargin{1};
            end
        end

    end
end

