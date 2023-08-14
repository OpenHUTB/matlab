function[writeProtectedFiles,writeProtectedDir]=checkFilePermissions(allFiles)




    allFiles=restorepoint.internal.utils.makeCell(allFiles);
    writeProtectedFiles=cell.empty;
    writeProtectedDir=cell.empty;
    for idx=1:numel(allFiles)
        currentFile=allFiles{idx};
        if~restorepoint.internal.utils.fileIsWritable(currentFile)
            writeProtectedFiles{end+1}=currentFile;%#ok<AGROW>
        end
        if~restorepoint.internal.utils.dirIsWritable(currentFile)
            writeProtectedDir{end+1}=fileparts(currentFile);%#ok<AGROW>
        end
    end
end
