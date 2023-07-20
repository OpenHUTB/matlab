classdef(ConstructOnLoad)AutomationSliceDirectionEventData<event.EventData




    properties

MaxSliceIdx
SliceDirection

    end

    methods

        function data=AutomationSliceDirectionEventData(idx,sliceDir)

            data.MaxSliceIdx=idx;
            data.SliceDirection=sliceDir;

        end

    end

end