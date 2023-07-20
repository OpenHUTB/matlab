function tg = slrealtime(varargin)
%
%
%

% Copyright 2018-2020 The MathWorks, Inc.

tgs = slrealtime.Targets;
tg = tgs.getTarget(varargin{:});
