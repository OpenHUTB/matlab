classdef(ConstructOnLoad)AlgorithmIterationEventData<event.EventData





    properties

ExecutionMode
UseScaledVolume

    end

    methods

        function data=AlgorithmIterationEventData(mode,useScaledData)

            data.ExecutionMode=mode;
            data.UseScaledVolume=useScaledData;

        end

    end

end