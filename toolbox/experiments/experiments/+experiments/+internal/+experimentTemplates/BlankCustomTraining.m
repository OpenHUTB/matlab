classdef BlankCustomTraining<experiments.internal.AbstractExperiment

    properties(SetAccess=private)
        SourceTemplate=fullfile(matlabroot,'toolbox','experiments','templates','template_blankTrainingFunction.m');
        HyperTable={};
        ExperimentType='ParamSweep';
        Description='';
        TrainingType='CustomTraining';
    end

end
