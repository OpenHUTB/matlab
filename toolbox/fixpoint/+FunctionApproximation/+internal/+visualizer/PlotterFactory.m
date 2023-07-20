classdef PlotterFactory





    methods(Static)
        function plotter=getPlotter(inputDimensions)
            plotter=[];
            if any(inputDimensions==[1,2])

                plotterClass=['Plotter',int2str(inputDimensions),'D'];
                plotter=FunctionApproximation.internal.visualizer.(plotterClass);
            end
        end
    end
end
