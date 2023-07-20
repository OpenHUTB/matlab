function harnessHandle=createHarness(protectedModelName,varargin)
























    if slfeature('ProtectedModelDirectSimulation')
        harnessHandle=Simulink.ModelReference.ProtectedModel.createHarness(protectedModelName,varargin{:});
    else
        DAStudio.error('MATLAB:UndefinedFunctionText','Simulink.ProtectedModel.createHarness');
    end

