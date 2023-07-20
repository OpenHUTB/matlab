classdef(ConstructOnLoad)VirtualAssemblyEventData<event.EventData




    properties
NewData
    end

    methods
        function data=VirtualAssemblyEventData(datain)
            data.NewData=datain;
        end
    end
end