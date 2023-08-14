function varargout = targetsprivate(function_name, varargin)
%TARGETSPRIVATE is a gateway for internal support functions used by Embedded Targets
%
% VARARGOUT = TARGETSPRIVATE('FUNCTION_NAME', VARARGIN) 
%      

%   Copyright 2007 The MathWorks, Inc.

[varargout{1:nargout}] = feval(function_name, varargin{1:end});

