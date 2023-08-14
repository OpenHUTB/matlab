









classdef DataSourceParticleSwarm<SimBiology.fit.internal.plots.liveplots.DataSource

    properties
Swarm
    end

    methods
        function obj=DataSourceParticleSwarm(singleFit)
            obj@SimBiology.fit.internal.plots.liveplots.DataSource(singleFit);
        end

        function obj=update(obj,tag,maxIter,transformer,likelihoodConverter,data)
            obj.State=data{2};
            obj.Tag=tag;
            obj.MaxIter=maxIter;

            status=data{1};
            if~isempty(status)


                obj.updateStatus(status);

                obj.Iteration=status.iteration;
                obj.ObjectiveFunctionCount{obj.Iteration+1}=status.funccount;
                obj.ObjectiveFunctionValue{obj.Iteration+1}=status.bestfval;
                obj.Swarm=status.swarm;


                obj.LogLikelihoodValue{obj.Iteration+1}=likelihoodConverter(status.bestfval);


                obj.updateParamValues(transformer,status.bestx);
            end
        end
    end
end

