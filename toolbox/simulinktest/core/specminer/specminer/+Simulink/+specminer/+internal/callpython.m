function [result, status] = callpython(varargin)
%PYTHON Execute Python command and return the result.
%   PYTHON(PYTHONFILE) calls PYTHON script specified by the file PYTHONFILE
%   using appropriate PYTHON executable.
%
%   PYTHON(PYTHONFILE,ARG1,ARG2,...) passes the arguments ARG1,ARG2,...
%   to the PYTHON script file PYTHONFILE, and calls it by using appropriate
%   PYTHON executable.
%
%   RESULT=PYTHON(...) outputs the result of attempted PYTHON call.  If the
%   exit status of PYTHON is not zero, an error will be returned.
%
%   [RESULT,STATUS] = PYTHON(...) outputs the result of the PYTHON call, and
%   also saves its exit status into variable STATUS.
%
%   If the PYTHON executable is not available, please download it
%
%   See also SYSTEM, JAVA, MEX.

%   Copyright 1990-2018 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

cmdString = '';

% Add input to arguments to operating system command to be executed.
% (If an argument refers to a file on the MATLAB path, use full file path.)
for i = 1:nargin
    thisArg = varargin{i};
    if ~ischar(thisArg)
        error(message('MATLAB:perl:InputsMustBeStrings'));
    end
    if i==1
        if exist(thisArg, 'file')==2
            % This is a valid file on the MATLAB path
            if isempty(dir(thisArg))
                % Not complete file specification
                % - file is not in current directory
                % - OR filename specified without extension
                % ==> get full file path
                thisArg = which(thisArg);
            end
        else
            % First input argument is PYTHONFILE - it must be a valid file
            error(message('MATLAB:perl:FileNotFound', thisArg));
        end
    end
    
    % Wrap thisArg in double quotes if it contains spaces
    if isempty(thisArg) || any(thisArg == ' ')
        thisArg = ['"', thisArg, '"']; %#ok<AGROW>
    end
    
    % Add argument to command string
    cmdString = [cmdString, ' ', thisArg]; %#ok<AGROW>
end

% Check that the command string is not empty
if isempty(cmdString)
    error(message('MATLAB:perl:NoPerlCommand'));
end

% Check that PYTHON is available if this is not a PC or isdeployed
if ~ispc || isdeployed
    if ispc
        checkCMDString = 'python3 -v';
    else
        checkCMDString = 'which python3';
    end
    [cmdStatus, ~] = system(checkCMDString);
    if cmdStatus ~=0
        error(message('MATLAB:perl:NoExecutable'));
    end
end

% Execute PYTHON script
cmdString = ['python3' cmdString];
if ispc && ~isdeployed
    % Add PYTHON to the path
    PYTHONInst = fullfile(matlabroot, 'sys\python3\win32\bin\');
    cmdString = ['set PATH=',PYTHONInst, ';%PATH%&' cmdString];
end
[status, result] = system(cmdString);

% Check for errors in shell command
if nargout < 2 && status~=0
    error(message('MATLAB:perl:ExecutionError', result, cmdString));
end


