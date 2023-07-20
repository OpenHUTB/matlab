function [rRemove,wMinVec] = findFastRootsContinuous(rVec,sCutoff,Tol)
%

% [rRemove,wMinVec] = findFastRootsContinuous(rVec,sCutoff,Tol)
%
% Inputs:
%    rVec:    Roots of a polynomial p(s), where s=jw
%    sCutoff: sCutoff=1i*wCutoff. Roots in rVec that can be approximated 
%             well by a constant gain below wCutoff (rad/s) will be 
%             indicated in rRemove
%    Tol:     Maximum allowed relative deviation in magnitude at wCutoff
%             between the constant gain and the zero term
%
% Outputs:
%    rRemove: Indices of zeros in rVec that can be approximated well with
%             a constant gain below wCutoff
%    wMin:    The frequencies below which each s-rVec(..) term can be 
%             approximated by a constant gain

%   Copyright 2015-2017 The MathWorks, Inc.

% Find the minimum frequency for each root below which their response can
% be approximated with a constant gain
wMinVec = controllib.internal.fitRational.findMinimumFrequencyContinuousTime(rVec,Tol);
rRemove = wMinVec>imag(sCutoff);
end