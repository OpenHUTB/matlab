classdef(ConstructOnLoad)WaveformParameterEventData<event.EventData



    properties
Index
Value
    end

    methods
        function data=WaveformParameterEventData(index,value)
            data.Index=index;
            data.Value=value;
        end
    end
end
