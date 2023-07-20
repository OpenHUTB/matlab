function varargout = launchApplication(c, varargin)
%launchApplication Helper to wrap up warning/error code while launching

%   Copyright 2020 The MathWorks, Inc.

% Capture and clear the current warning state
w = matlabshared.application.IgnoreWarnings();

try
    % Construct the Application
    h = c(varargin{:});
catch me
    
    % Do not throw warnings if we are going to error out.
    w.RethrowWarning = false;
    
    % Throw the caught error
    throwAsCaller(me);
end

throwLastWarning(w, true);
w.RethrowWarning = false;

% Open the Application
open(h);

if nargout
    
    % Call the createCommandLineInterface method which returns [] by
    % default.  Application subclasses must overload to provide CLI.
    varargout = {createCommandLineInterface(h), h};
end

% [EOF]
