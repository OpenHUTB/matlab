function np = unpackNum(x,d,Ny,Nu,xSkip)
%

% np = unpackNum(x,d,Ny,Nu,xSkip)
%
% Unpack the parameters returned from LSQ solution x to get numerator
% parameters. It is assumed that numerators for each I/O channel has d+1
% parameters.
%
% Inputs:
%    x     - Packed parameters, a column vector
%    d     - System order
%    Ny    - Number of output channels
%    Nu    - Number of input channels
%    xSkip - (Optional) Number of parameters to skip in x. 
%            x(numSkip+1:end) is assumed to contain the numerator parameters
%
% Outputs:
%    np      - Numerator parameters, [Ny Nu] cell array. Each cell element 
%              is a row vector of length (d+1)

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.internal.prefer_const(d);
coder.internal.prefer_const(Ny);
coder.internal.prefer_const(Nu);

if nargin < 5
    xSkip = 0;
end

% Total number of parameters in x is numSkip+(d+1)*(Ny*Nu)
assert(numel(x) == xSkip + (d+1) * Ny * Nu);

% x must be a column vector
assert(iscolumn(x));

% unpack (d+1) parameters at a time
np = cell(Ny,Nu);
tSkip = xSkip;
for kkY=1:Ny
    for kkU=1:Nu
        np{kkY,kkU} = x(tSkip + (1:d+1)).';
        tSkip = tSkip + d + 1;
    end
end
end

% LocalWords:  np Ny LSQ
