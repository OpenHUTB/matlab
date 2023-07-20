function diagDir=getSharedDiagnosticDirName(modelName,subDir,overwriteFile)



    bdir=RTW.getBuildDir(modelName);

    postFix=DAStudio.message('soc:scheduler:DiagFolderPostfix');
    diagDir=fullfile(bdir.CodeGenFolder,[modelName,postFix],subDir);

    if overwriteFile
        last=soc.internal.profile.getLatestDiagnosticDirectory(modelName,subDir);
        if~isempty(last)
            [success,msg,msgID]=rmdir(last,'s');%#ok<ASGLU>
            if~success
                warning(message('soc:viewer:CannotOverwriteDiagFolder',last));
            end
        end
    end

    if~isequal(exist(diagDir,'dir'),7)
        mkdir(diagDir);
    end
    t=datetime;
    folderName=strcat(num2str(t.Year),'_',...
    num2str(t.Month),'_',...
    num2str(t.Day),'_',...
    num2str(t.Hour),'_',...
    num2str(t.Minute),'_',...
    num2str(floor(t.Second)));
    diagDir=fullfile(diagDir,folderName);
    if~isequal(exist(diagDir,'dir'),7)
        mkdir(diagDir);
    end
    diagDir=regexprep(diagDir,'\\','/');
end