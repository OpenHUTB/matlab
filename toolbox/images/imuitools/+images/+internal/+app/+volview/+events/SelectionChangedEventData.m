classdef(ConstructOnLoad)SelectionChangedEventData<event.EventData




    properties

Index
Selected

    end

    methods

        function data=SelectionChangedEventData(idx,selected)

            data.Index=idx;
            data.Selected=selected;

        end

    end

end
