function setupSlTraining


    thisPath=fileparts(mfilename('fullpath'));
    filesepIndices=strfind(thisPath,filesep);
    toolboxPath=thisPath(1:filesepIndices(end)-1);


    pathAdded=genpath(fullfile(toolboxPath,'slbridge'));
    addpath(pathAdded);
end
