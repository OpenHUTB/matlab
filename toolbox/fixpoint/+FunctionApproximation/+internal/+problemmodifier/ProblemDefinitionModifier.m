classdef ProblemDefinitionModifier<matlab.mixin.Heterogeneous&handle





    properties(SetAccess=protected)
        MessageRepository FunctionApproximation.internal.MessageRepository
    end
    methods
        function setMessageRepository(this,repository)
            this.MessageRepository=repository;
        end
    end
    methods(Abstract)
        problemDefinition=modify(this,problemDefinition);
    end
end
