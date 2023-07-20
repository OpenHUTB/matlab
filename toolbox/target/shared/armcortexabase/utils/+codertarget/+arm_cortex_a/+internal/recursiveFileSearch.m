function [ret, allValidMatches] = recursiveFileSearch(startDir, fileName)
% CODERTARGET.ARM_CORTEX_A.INTERNAL.RECURSIVEFILESEARCH Search for a file
% recursively in a given directory. Returns the first match.
%
% Usage:
%      fullFname =  codertarget.arm_cortex_a.internal.recursiveFileSearch(...
%           codertarget.arm_cortex_a.internal.getSpPkgRootDir,'getARMCortexAInfo.m');
%

% Copyright 2014-2017 The MathWorks, Inc.

ret = '';
allValidMatches = {''};

% Set the correct file-separator using fullfile
startDir = fullfile(startDir);

if ~exist(startDir, 'dir')
    msg = sprintf('Base directory %s does not exist.\n',startDir);
    hwconnectinstaller.internal.inform(msg);
    return;
end

if ispc
    % "where" is one of the few Windows commands that requires backslashes
    cmd2search = ['where /R "',strrep(startDir,'/','\'),'"', ' ' , fileName];
else
    cmd2search = ['find ',startDir,' -type f -name "',fileName,'" -follow -print'];
end
msg = sprintf('Executing command :\n%s\n',cmd2search);
hwconnectinstaller.internal.inform(msg);

[res,out]=system(cmd2search);
if res
    msg = sprintf('System returned error code:%d\n%s\n',res, out);
    hwconnectinstaller.internal.inform(msg);
    return;
else
    splitOut = regexp(out,'\n','split');
    allValidMatches = {''};
    ct = 1;
    for i=1:numel(splitOut)
        if exist(splitOut{i},'file')
            ret = splitOut{i};
            allValidMatches{ct} = ret;
            ct = ct + 1;
        end
    end
end
end % END FUNCTION RECURSIVEFILESEARCH

