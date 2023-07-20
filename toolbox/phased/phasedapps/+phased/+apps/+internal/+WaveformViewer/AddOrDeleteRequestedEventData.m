classdef(ConstructOnLoad)AddOrDeleteRequestedEventData<event.EventData



    properties
InsertIndex
SelectIndex
SampleRate
    end

    methods
        function data=AddOrDeleteRequestedEventData(Iindex,Sindex,samplerate)
            data.InsertIndex=Iindex;
            data.SelectIndex=Sindex;
            if nargin==3
                data.SampleRate=samplerate;
            end
        end
    end
end