classdef(ConstructOnLoad)SliceEventData<event.EventData




    properties

Value
SliceDirection

    end

    methods

        function data=SliceEventData(value,sliceDirection)

            data.Value=value;
            data.SliceDirection=sliceDirection;

        end

    end

end