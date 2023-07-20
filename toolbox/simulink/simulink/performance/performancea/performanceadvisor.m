function performanceadvisor(system, varargin)
% PERFORMANCEADVISOR('MODEL') 
% starts the Performance Advisor, opening ('MODEL')  
% where 'MODEL' is the path to a top-level model. 
% 
% PERFORMANCEADVISOR('Model', 'AutoRestore') 
% starts the Performance Advisor, restoring the status from the last
% exited session, where 'Model' is the path to a top-level model.
%  
% The Performance Advisor is a tool that guides you through the steps 
% for generating high performance Simulink model. 

%   Copyright 2009-2011 The MathWorks, Inc.
%    
if nargin < 1 || nargin > 2
    error(message('SimulinkPerformanceAdvisor:advisor:Usage'));
end

if nargin > 0
    system = convertStringsToChars(system);
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

performanceadvisor_exe(system, varargin);

