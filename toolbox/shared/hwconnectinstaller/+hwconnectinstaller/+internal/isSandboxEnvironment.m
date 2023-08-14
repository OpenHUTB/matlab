function isSandbox=isSandboxEnvironment









    thisLoc=mfilename('fullpath');
    spiDir=fileparts(fileparts(fileparts(thisLoc)));
    isSandbox=exist(fullfile(spiDir,'resources','sandboxFileSdkOnly.txt'),'file')==2;
