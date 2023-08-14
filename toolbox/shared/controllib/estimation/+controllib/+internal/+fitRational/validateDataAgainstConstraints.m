function [w,y,u,Weight] = validateDataAgainstConstraints(tfDen,Ts,w,y,u,Weight)
%

%   Copyright 2017 The MathWorks, Inc.

% Validate input data against transfer function parameter constraints

if Ts
    % Discrete-time
    
    % * If all denominator parameters are fixed, and their sum is 0, then
    % response at w=0 rad/s is Inf.
    % * Our checks in validateData ensure that all input data are finite.
    % Hence if there is data at w=0, it is finite. Check for this conflict.
    %
    % AAO: Do a quick fit to numerator parameters are return
    if all(~tfDen.Free) && sum(tfDen.Value)==0 && any(w==0)
        error(message('Controllib:estimation:fitRationalDataConstraintConflictAtDC'));
    end
    
    % * If all denominator parameters are fixed, and their alternating sum
    % is 0, then response at w=pi/Ts rad/s is Inf.
    % * Our checks in validateData ensure that all input data are finite.
    % Hence if there is data at w=0, it is finite. Check for this conflict.
    %
    % AAO: Do a quick fit to numerator parameters are return
    nyquistFrequency = pi/Ts;
    if all(~tfDen.Free) && localAlternatingSum(tfDen.Value)==0 && any(abs(w-nyquistFrequency)<1e-8*nyquistFrequency)
        error(message('Controllib:estimation:fitRationalDataConstraintConflictAtNyquistFreq'));
    end    
else
    % Continuous-time
    
    % * If the last denominator parameter(s) are fixed to 0, this implies
    % response at w=0 rad/s is Inf. 
    % * Our checks in validateData ensure that all input data are finite.
    % Hence if there is data at w=0, it is finite. Check for this conflict.
    if ~tfDen.Free(end) && tfDen.Value(end)==0 && any(w==0)
        error(message('Controllib:estimation:fitRationalDataConstraintConflictAtDC'));
    end
end
end

function s = localAlternatingSum(v)
% Calculate s=v(end)-v(end-1)+v(end-2)-v(end-3) ...
s = sum(v(1:2:end)) - sum(v(2:2:end));
if mod(numel(v),2)==0
    s = -s;
end
end