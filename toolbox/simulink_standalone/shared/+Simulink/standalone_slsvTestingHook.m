function hookval=slsvTestingHook(hook,varargin)
    modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface('');
    name=modelInterface.name;
    modelInterface.debugLog(2,['slsvTestingHook(',hook,') for model ',name,' called ']);
    hookval=modelInterface.slhook(hook,varargin);
    modelInterface.debugLog(2,['slsvTestingHook(',hook,') returning ',num2str(hookval)]);
end
