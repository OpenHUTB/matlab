classdef(ConstructOnLoad)DeleteEventData<event.EventData





    properties
CategoryType
SelectionView
Data
    end

    methods
        function eventObj=DeleteEventData(CategoryType,Id,SelectionView)
            eventObj.CategoryType=CategoryType;
            eventObj.Data.Id=Id;
            eventObj.SelectionView=SelectionView;
        end

    end
end
