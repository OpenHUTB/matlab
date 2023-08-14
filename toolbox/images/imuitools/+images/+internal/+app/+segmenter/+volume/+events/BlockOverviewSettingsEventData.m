classdef(ConstructOnLoad)BlockOverviewSettingsEventData<event.EventData





    properties

CurrentIndex
History
Completed

    end

    methods

        function data=BlockOverviewSettingsEventData(idx,his,completedBlocks)

            data.History=his;
            data.CurrentIndex=idx;
            data.Completed=completedBlocks;

        end

    end

end