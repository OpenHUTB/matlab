% This class is unsupported and might change or be removed without
% notice in a future version.

% logDebug allows Data Tools components to log debug messages.  To view the
% messages, logging needs to be enabled for the channel specified.  For
% example:
%
%    feature('diagnosticDest', 'stdout'); (or 'file=filename')
%    feature('diagnosticSpec', 'matlab::datatools::import.*=all');
%
% Will enable logging if logDebug is called with a channel of 'import'.
% Channel can have multiple levels, for example: 'inspector::timer'.  To
% turn off logging, set diagnosticSpec to '.*=none'.

% Copyright 2021-2022 The MathWorks, Inc.

function logDebug(channel, msg)
    arguments
        channel char
        msg char
    end

    % Common prefix used for logging
    dataToolsPrefix = "matlab::datatools::";
    
    if ~isempty(channel) && ~isempty(msg)
        feature("diagnosticLog", dataToolsPrefix + channel, "debug", msg);
    end
end