function checkWorkDir(dirToCheck)



    if nargin<1
        dirToCheck=pwd;
    end
    try
        rtw_checkdir(dirToCheck);
    catch ME
        switch ME.identifier
        case 'RTW:buildProcess:buildDirInMatlabDir'
            DAStudio.error('Slci:ui:buildDirInMatlabDir',dirToCheck);
        case 'RTW:buildProcess:buildDirInRTWProjDir'
            DAStudio.error('Slci:ui:buildDirInRTWProjDir',dirToCheck);
        case 'RTW:buildProcess:buildDirInBuildDir'
            DAStudio.error('Slci:ui:buildDirInBuildDir',dirToCheck);
        otherwise
            rethrow(ME);
        end
    end
end