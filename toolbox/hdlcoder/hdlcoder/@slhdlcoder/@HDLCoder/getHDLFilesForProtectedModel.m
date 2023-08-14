function fileList=getHDLFilesForProtectedModel(this,protectedFilesDir,extension,fileList)%#ok<INUSL>
    extension=['*.',extension];
    fileNamePattern=fullfile(protectedFilesDir,extension);
    files=dir(fileNamePattern);
    if~isempty(files)
        for ii=1:numel(files)
            fileList{end+1}=files(ii).name;%#ok<AGROW>
        end
    end
end