classdef(ConstructOnLoad)AutomateBlockedImageEventData<event.EventData





    properties

AutomateOnBlocks
BorderSize
UseParallel
SkipCompleted
Review

    end

    methods

        function data=AutomateBlockedImageEventData(useAllBlocks,borderSize,useParallel,skipCompleted,reviewResults)

            data.AutomateOnBlocks=useAllBlocks;
            data.BorderSize=borderSize;
            data.UseParallel=useParallel;
            data.SkipCompleted=skipCompleted;
            data.Review=reviewResults;

        end

    end

end