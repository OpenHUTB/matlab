
function value=utilDAGetString(key,varargin)
    if nargin==4
        value=DAStudio.message(['Simulink:solverProfiler:',key],varargin{1},varargin{2},varargin{3});
    elseif nargin==3
        value=DAStudio.message(['Simulink:solverProfiler:',key],varargin{1},varargin{2});
    elseif nargin==2
        value=DAStudio.message(['Simulink:solverProfiler:',key],varargin{1});
    else
        value=DAStudio.message(['Simulink:solverProfiler:',key]);
    end
end