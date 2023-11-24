function rootFolder=findProjectRoot(fileOrFolder)

    fileOrFolder=strtrim(fileOrFolder);

    if isfolder(fileOrFolder)
        fileOrFolder=fullfile(fileOrFolder,"dummy.txt");
        [state,rootFolder]=matlab.internal.project.util.isUnderProjectRoot(fileOrFolder);
    elseif isfile(fileOrFolder)
        [state,rootFolder]=matlab.internal.project.util.isUnderProjectRoot(fileOrFolder);
    else

        state=false;
    end

    if~state
        rootFolder='';
    else
        rootFolder=char(rootFolder);
    end
end
