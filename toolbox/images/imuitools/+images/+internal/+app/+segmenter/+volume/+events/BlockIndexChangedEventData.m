classdef(ConstructOnLoad)BlockIndexChangedEventData<event.EventData





    properties

CurrentIndex
SizeInBlocks
Completed

    end

    methods

        function data=BlockIndexChangedEventData(idx,maxIdx,completedBlock)

            data.CurrentIndex=idx;
            data.SizeInBlocks=maxIdx;
            data.Completed=completedBlock;

        end

    end

end