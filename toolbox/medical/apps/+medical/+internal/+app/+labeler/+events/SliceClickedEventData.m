classdef(ConstructOnLoad)SliceClickedEventData<event.EventData




    properties

Position
Index
SliceDirection

    end

    methods

        function data=SliceClickedEventData(pos,idx,sliceDirection)

            data.Position=pos;
            data.Index=idx;
            data.SliceDirection=sliceDirection;

        end

    end

end