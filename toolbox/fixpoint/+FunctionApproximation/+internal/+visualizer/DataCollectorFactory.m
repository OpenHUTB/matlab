classdef DataCollectorFactory




    methods(Static)
        function dataCollector=getDataCollector(inputDimensions)
            dataCollector=[];
            if any(inputDimensions==[1,2])

                plotterClass=['DataCollector',int2str(inputDimensions),'D'];
                dataCollector=FunctionApproximation.internal.visualizer.(plotterClass);
            end
        end
    end
end