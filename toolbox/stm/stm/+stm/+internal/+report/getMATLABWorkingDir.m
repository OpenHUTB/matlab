function workingPath = getMATLABWorkingDir()
%
% This is to rely on MATLAB to handle path naming under different operating
% systems.

% Copyright 2014 The MathWorks, Inc.
%
    currentDir = pwd();
    fileSeparator = filesep();
    
    if(currentDir(end) == fileSeparator)
        workingPath = currentDir;
    else
        workingPath = [currentDir fileSeparator];
    end
end
