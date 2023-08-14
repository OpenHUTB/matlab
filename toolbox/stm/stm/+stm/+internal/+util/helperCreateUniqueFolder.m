function fullFilePath=helperCreateUniqueFolder(folderLoc)

    folderName='sl_test_baselines';
    fullFilePath=fullfile(folderLoc,folderName);
    [s,~,messid]=mkdir(fullFilePath);
    while(strcmp(messid,'MATLAB:MKDIR:DirectoryExists'))
        ind=regexp(folderName,'/*(\d+)');
        numString=str2double(folderName(ind:end));
        if~isnan(numString)
            folderName=[folderName(1:ind-1),num2str(numString+1)];
        else
            folderName=[folderName,'1'];%#ok
        end
        fullFilePath=fullfile(folderLoc,folderName);
        [s,~,messid]=mkdir(fullFilePath);
    end

    if~s
        error(message(messid));
    end
end