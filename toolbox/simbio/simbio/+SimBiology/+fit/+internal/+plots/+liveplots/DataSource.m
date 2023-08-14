









classdef DataSource<handle&matlab.mixin.Heterogeneous

    properties(Access=public)
MaxIter
ObjectiveFunctionValue
ObjectiveFunctionCount
ParameterEstimates
Iteration
FirstOrderOptimality
Tag
Status
State
ExitCondition
ExitFlag
LogLikelihoodValue
    end

    properties(Access=private)
SingleFit
    end

    methods
        function obj=DataSource(singleFit)
            obj.ObjectiveFunctionValue={};
            obj.ObjectiveFunctionCount={};
            obj.ParameterEstimates={};
            obj.FirstOrderOptimality={};
            obj.LogLikelihoodValue={};
            obj.SingleFit=singleFit;
        end

        function Tag=get.Tag(obj)
            if obj.SingleFit
                Tag=1;
            else
                Tag=obj.Tag;
            end
        end

        function updateStatus(obj,status)
            if~isempty(status)
                return;
            end

            if isempty(obj.Status)
                obj.Status=status;
            else
                obj.Status(end+1)=status;
            end
        end

        function updateParamValues(obj,transformer,paramValues)
            if~isempty(paramValues)






                numTransformed=numel(transformer.Transforms);
                paramValues(1:numTransformed)=transformer.untransform(paramValues(1:numTransformed));
                obj.ParameterEstimates{obj.Iteration+1}=paramValues;
            end
        end

        function obj=update(obj,tag,maxIter,transformer,likelihoodConverter,data)
            obj.State=data{3};
            obj.Tag=tag;
            obj.MaxIter=maxIter;

            status=data{2};


            if~isempty(status)


                obj.updateStatus(status);

                obj.Iteration=status.iteration;
                obj.ObjectiveFunctionCount{status.iteration+1}=status.funccount;


                if isfield(status,'fval')
                    obj.ObjectiveFunctionValue{status.iteration+1}=status.fval;
                else
                    obj.ObjectiveFunctionValue{status.iteration+1}=status.residual;
                end


                obj.LogLikelihoodValue{status.iteration+1}=likelihoodConverter(obj.ObjectiveFunctionValue{status.iteration+1});


                if isfield(status,'firstorderopt')
                    obj.FirstOrderOptimality{status.iteration+1}=status.firstorderopt;
                end
            end


            obj.updateParamValues(transformer,data{1});
        end
    end
end

