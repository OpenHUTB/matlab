classdef(Abstract)AbstractExperiment<handle




    properties(Abstract,SetAccess=private)
        SourceTemplate(1,1)string
HyperTable
        Description(1,1)string
        TrainingType char{mustBeMember(TrainingType,{'StandardTraining','CustomTraining'})}
        ExperimentType(1,:)char{mustBeMember(ExperimentType,{'ParamSweep','BayesOpt'})}
    end

    properties(SetAccess=protected)
HelperFunctions
        ExecMode='Exhaustive'
Metrics
BayesOptOptions
        OptimizableMetricData=''

    end
end
