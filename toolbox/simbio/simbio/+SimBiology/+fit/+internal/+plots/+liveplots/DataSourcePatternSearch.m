









classdef DataSourcePatternSearch<SimBiology.fit.internal.plots.liveplots.DataSource
    properties
    end

    methods
        function obj=DataSourcePatternSearch(singleFit)
            obj@SimBiology.fit.internal.plots.liveplots.DataSource(singleFit);
        end

        function obj=update(obj,tag,maxIter,transformer,likelihoodConverter,data)
            obj.State=data{3};
            obj.Tag=tag;
            obj.MaxIter=maxIter;

            status=data{1};
            if~isempty(status)


                obj.updateStatus(status);

                obj.Iteration=status.iteration;
                obj.ObjectiveFunctionCount{obj.Iteration+1}=status.funccount;
                obj.ObjectiveFunctionValue{obj.Iteration+1}=status.fval;


                obj.LogLikelihoodValue{obj.Iteration+1}=likelihoodConverter(status.fval);


                obj.updateParamValues(transformer,status.x);
            end
        end
    end
end

