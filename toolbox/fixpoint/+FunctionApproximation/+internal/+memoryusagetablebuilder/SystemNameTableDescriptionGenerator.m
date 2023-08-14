classdef(Sealed)SystemNameTableDescriptionGenerator<FunctionApproximation.internal.memoryusagetablebuilder.TableDescriptionGenerator






    methods
        function description=generate(~,path)
            description=message('SimulinkFixedPoint:functionApproximation:tableDescriptionPathIsASUD',path).getString();
        end
    end
end