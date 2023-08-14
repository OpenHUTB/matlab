classdef RGBGeneratorFactory




    methods(Static)

        function rgbGenerator=getGenerator(intent)
            rgbGenerator=DataTypeWorkflow.Visualizer.view.RGBGenerator();
            switch intent
            case 'FixedPoint'
                strategy=DataTypeWorkflow.Visualizer.view.generatorstrategy.FixedPointGeneratorStrategy;
            end

            rgbGenerator.setHistogramGeneratorStrategy(strategy);
        end

    end
end


