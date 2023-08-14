classdef(ConstructOnLoad)createDataDDGEvent<event.EventData





    properties

EventData
    end


    methods
        function this=createDataDDGEvent(data)

            if nargin==1
                this.EventData=data;
            end
        end
    end
end