



classdef(ConstructOnLoad)CurrentViewROIMovedEventData<event.EventData

    properties



CurrentPosition



Index
    end

    methods

        function data=CurrentViewROIMovedEventData(currPos,idx)

            data.CurrentPosition=currPos;
            data.Index=idx;

        end
    end

end