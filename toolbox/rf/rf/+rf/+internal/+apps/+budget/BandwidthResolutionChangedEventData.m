classdef(ConstructOnLoad)BandwidthResolutionChangedEventData<event.EventData
    properties
Name
Budget
Index
    end

    methods
        function data=BandwidthResolutionChangedEventData(name,budget)
            data.Name=name;
            data.Budget=budget;
        end
    end
end
