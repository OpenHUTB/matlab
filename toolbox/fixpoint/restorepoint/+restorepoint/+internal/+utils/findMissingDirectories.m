function missingDirectories=findMissingDirectories(filesToRestore)




    missingDirectories=cell.empty;
    for idx=1:numel(filesToRestore)
        currentFile=filesToRestore{idx}{1};
        [fileDir,~,~]=fileparts(currentFile);
        if~exist(fileDir,'dir')
            missingDirectories{end+1}=currentFile;%#ok<AGROW>
        end
    end
end
