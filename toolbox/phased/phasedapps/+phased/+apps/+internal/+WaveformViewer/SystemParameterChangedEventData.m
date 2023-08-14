classdef(ConstructOnLoad)SystemParameterChangedEventData<event.EventData



    properties
Index
Name
Value
SampleRate
    end

    methods
        function data=SystemParameterChangedEventData(index,value,name,samplerate)
            data.Index=index;
            data.Value=value;
            data.Name=name;
            data.SampleRate=samplerate;
        end
    end
end
