classdef BatchedOutputEventsEventData<event.EventData




    properties
BatchedOutputEvents
CompletedRegionNumbers
    end

    methods
        function data=BatchedOutputEventsEventData(outputs,completedRegionNumbers)
            data.BatchedOutputEvents=outputs;
            data.CompletedRegionNumbers=completedRegionNumbers;
        end
    end
end