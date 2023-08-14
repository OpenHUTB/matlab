% TARGETS_FSYSDAT_FAILSIGS create data for targets fuelsys demo models
%
% Define default Simulink data objects that are expected by the 
% fuelsys algorithm.   
% 
% Note: when this algorithm is used with the C166 these signals are defined
% differently.   See: c166fuelsysdata.m
%

% Copyright 2006 The MathWorks, Inc.

throt_fail = Simulink.Signal;
speed_fail = Simulink.Signal;
o2_fail = Simulink.Signal;
press_fail = Simulink.Signal;
