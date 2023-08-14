classdef(ConstructOnLoad)AcceptResultsEventData<event.EventData





    properties

AcceptedBlocks
CompletedBlocks

    end

    methods

        function data=AcceptResultsEventData(acceptedBlocks,completedBlocks)

            data.AcceptedBlocks=acceptedBlocks;
            data.CompletedBlocks=completedBlocks;

        end

    end

end