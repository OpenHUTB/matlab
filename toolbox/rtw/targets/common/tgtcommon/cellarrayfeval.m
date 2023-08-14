function ret = cellarrayfeval(fname,nout,varargin)
% CELLARRAYFEVAL 
%
% Wrap up a call to feval by specifying that the desired output arguments
% are returned as a cell array.
%
% Syntax: ret = cellarrayfeval(fname, nout, varargin)
%
% Return value: 
% 
% "ret" is a cell array consisting of "nout" return values from 
% the feval call to "fname"
%
% Arguments:
%
% "fname" is the name of the function to evaluate
% "nout" is the number of return values required from the function evaluation
% "varargin" is the array of arguments for the function evaluation
%

%   Copyright 2003-2004 The MathWorks, Inc.

% size the output array   
ret =  cell(1,nout);
% assign the appropriate number of outputs
% to the return value
[ret{:}] = feval(fname,varargin{:});