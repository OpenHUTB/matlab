








classdef DataSourceGA<SimBiology.fit.internal.plots.liveplots.DataSource

    properties
Swarm
    end

    methods

        function obj=DataSourceGA(singleFit)
            obj@SimBiology.fit.internal.plots.liveplots.DataSource(singleFit);
        end

        function obj=update(obj,tag,maxIter,transformer,likelihoodConverter,data)
            obj.State=data{2};
            obj.Tag=tag;
            obj.MaxIter=maxIter;

            status=data{1};
            if~isempty(status)


                obj.updateStatus(status);

                obj.Iteration=status.Generation;
                obj.ObjectiveFunctionCount{obj.Iteration+1}=status.FunEval;


                [bestPoint,i]=min(status.Score);
                obj.ObjectiveFunctionValue{obj.Iteration+1}=bestPoint;


                obj.LogLikelihoodValue{obj.Iteration+1}=likelihoodConverter(bestPoint);


                obj.Swarm=status.Population;


                obj.updateParamValues(transformer,status.Population(i,:));
            end
        end
    end
end

