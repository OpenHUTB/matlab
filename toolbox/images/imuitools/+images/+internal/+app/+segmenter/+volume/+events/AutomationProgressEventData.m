classdef(ConstructOnLoad)AutomationProgressEventData<event.EventData





    properties

CurrentBlock

    end

    methods

        function data=AutomationProgressEventData(idx)

            data.CurrentBlock=idx;

        end

    end

end