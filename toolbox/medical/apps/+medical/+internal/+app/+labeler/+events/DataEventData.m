classdef(ConstructOnLoad)DataEventData<event.EventData




    properties

DataName
HasLabels

    end

    methods

        function data=DataEventData(dataName,hasLabels)

            data.DataName=dataName;
            data.HasLabels=hasLabels;

        end

    end

end