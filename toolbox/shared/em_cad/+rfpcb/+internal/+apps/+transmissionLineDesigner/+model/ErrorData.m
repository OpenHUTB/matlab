classdef(ConstructOnLoad)ErrorData<event.EventData



    properties
Data
    end

    methods
        function obj=ErrorData(newData)


            obj.Data=newData;
        end
    end
end

