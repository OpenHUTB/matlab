classdef(Sealed)RegisteredBlockTableDescriptionGenerator<FunctionApproximation.internal.memoryusagetablebuilder.TableDescriptionGenerator







    methods
        function description=generate(~,path)
            description=message('SimulinkFixedPoint:functionApproximation:tableDescriptionPathIsALUT',path).getString();
        end
    end
end