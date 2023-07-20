classdef(ConstructOnLoad)RGBAEventData<event.EventData





    properties

DataColormap
DataAlphamap
LabelColormap
LabelAlphamap

    end

    methods

        function data=RGBAEventData(cmapData,amapData,cmapLabels,amapLabels)

            data.DataColormap=cmapData;
            data.DataAlphamap=amapData;
            data.LabelColormap=cmapLabels;
            data.LabelAlphamap=amapLabels;

        end

    end

end