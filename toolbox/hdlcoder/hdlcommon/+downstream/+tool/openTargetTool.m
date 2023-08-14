function openTargetTool(CmdStr,projectPath,cmdDisplay)




    if~exist(projectPath,'file')
        hM=message('hdlcommon:workflow:NoProjectFile',projectPath);
        if cmdDisplay
            error(hM);
        else
            errordlg(hM.getString,'Error','modal');
            return;
        end
    end

    currentDir=pwd;
    projFolder=fileparts(projectPath);
    cd(projFolder);


    system(CmdStr);
    cd(currentDir);
end