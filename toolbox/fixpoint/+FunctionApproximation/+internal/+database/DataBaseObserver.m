classdef DataBaseObserver<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=private)
        Options FunctionApproximation.internal.database.DataBaseObserverContext
    end

    methods(Abstract)
        update(this,database);
    end

    methods(Sealed)
        function setOptions(this,options)
            this.Options=FunctionApproximation.internal.database.DataBaseObserverContextFactory().getContextFromOptionsData(options);
        end
    end
end
