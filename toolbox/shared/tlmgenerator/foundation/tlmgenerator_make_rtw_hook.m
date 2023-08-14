function tlmgenerator_make_rtw_hook (hookPoint, modelName, rtwroot, tmf, buildOpts, buildArgs, buildInfo)
% tlmgenerator_make_rtw_hook TLM Generator Target hook file for the Simulink Coder build process (make_rtw).
%
% Name must match tlmgenerator_make_rtw_hook to be called.

%   Copyright 2008-2009 The MathWorks, Inc.

tlmgenerator_hookpoints (hookPoint, modelName, rtwroot, tmf, buildOpts, buildArgs, buildInfo);

end

