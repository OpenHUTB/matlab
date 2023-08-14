classdef channel






    properties
ChannelName
SampleRate
ClksPerValid
TimeSeries
OverflowFlag
ContiguousFlag
    end

    methods
        function obj=channel(ChannelName,SampleRate,ClksPerValid)
            obj.ChannelName=ChannelName;
            obj.SampleRate=SampleRate;
            obj.ClksPerValid=ClksPerValid;
        end
    end
end
