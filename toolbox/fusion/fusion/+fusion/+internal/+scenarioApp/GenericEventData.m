classdef(ConstructOnLoad)GenericEventData<event.EventData




    properties(SetAccess=immutable)
EventData
    end

    methods
        function this=GenericEventData(data)

            if nargin==1
                this.EventData=data;
            end
        end
    end
end