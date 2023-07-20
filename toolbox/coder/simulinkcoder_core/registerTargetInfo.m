% 
% Register RTW.TargetRegistry obj and method with cm
% Register callback to warn if saving to MDL file when coder dictionary is
% present
%
% Usage:
%    cm.registerTargetInfo(TargetInfoObj)
% Note:
%    TargetInfoObj must be of type RTW.TflRegistry

function registerTargetInfo(tgtInfoObj)
    % get the current TR handle.
    tr = RTW.TargetRegistry.getInstance('simulinkstart');
    tr.registerTargetInfo(tgtInfoObj);
end
