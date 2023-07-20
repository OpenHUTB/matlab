function [dp,np] = unpack(x,d,Ny,Nu)
%

% [dp,np] =  localUnpackLSQResults(x,d,Ny,Nu)
%
% Unpack the parameters returned from LSQ solution to get denominator and
% numerator parameters. It is assumed that the first d+1 parameters in x
% belong to the denominator, and the rest belong to the numerators.
%
% Inputs:
%    x     - Packed parameters, a column vector
%    d     - System order
%    Ny    - Number of output channels
%    Nu    - Number of input channels
%
% Outputs:
%    dp      - Denominator parameters. Row vector of length (d+1)
%    np      - Numerator parameters, [Ny Nu] cell array. Each cell element 
%              is a row vector of length (d+1)

%   Copyright 2015-2018 The MathWorks, Inc.

%#codegen
coder.allowpcode('plain');
coder.internal.prefer_const(d, Ny, Nu);

% There must be (d+1) * (Ny*Nu + 1) parameters
assert(numel(x) == (d+1)*(Ny*Nu+1));

% x must be a column vector
assert(iscolumn(x));

% For OVF and VF, ensure that the first parameter for each is the direct
% term, followed by the residues. For instance, resulting np corresponds
% to:
%   np(1) + np(2)*B(1) + np(3)*B(2) + ...
% where B(1), B(2), .., B(k) are the k-th basis functions. np(1) = 0
% corresponds to relative degree 1.
%
% For standard basis functions, np and dp corresponds to numerator and
% denominator polynomial coefficients.
dp = x(1:d+1).';
% Skip the first d+1 parameters, unpack the numerator
np = controllib.internal.fitRational.unpackNum(x,d,Ny,Nu,d+1);
end
