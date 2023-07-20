function featureval=slfeature(feature,varargin)
    modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface('');
    name=modelInterface.name;
    modelInterface.debugLog(2,['slfeature(',feature,') for model ',name,' called ']);
    featureval=modelInterface.slfeature(feature,varargin);
    modelInterface.debugLog(2,['slfeature(',feature,') returning ',num2str(featureval)]);
end
