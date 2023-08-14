function out=confidenceIntervalStepHandler(action,varargin)

    switch(action)
    case 'getConfidenceIntervalsStep'
        out=getConfidenceIntervalsStep(varargin{:});
    end

end

function step=getConfidenceIntervalsStep(node)

    step=struct;
    step.description='';
    step.enabled=false;
    step.name='Confidence Interval';
    step.type='Confidence Interval';
    step.version=1;

    step.parameter=struct;
    step.parameter.calculate='true';
    step.parameter.confidenceLevel=95;
    step.parameter.method='gaussian';
    step.parameter.maxStepSize=0.1;
    step.parameter.tolerance=1e-5;
    step.parameter.numSamples=1000;

    step.prediction.calculate='true';
    step.prediction.confidenceLevel=95;
    step.prediction.method='gaussian';
    step.prediction.numSamples=1000;


    step.runInParallel=getAttribute(node,'UseDistributed');
    if isempty(step.runInParallel)
        step.runInParallel=false;
    end


    step.internal=getInternalStructTemplate;
    step.internal.id=4;
    step.internal.outputArguments={'parameterCI','predictionCI'};

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');
end
