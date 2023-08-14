classdef(ConstructOnLoad)SliderMovingEventData<event.EventData





    properties

Index
PreviousIndex

    end

    methods

        function data=SliderMovingEventData(idx,oldIdx)

            data.Index=idx;
            data.PreviousIndex=oldIdx;

        end

    end

end