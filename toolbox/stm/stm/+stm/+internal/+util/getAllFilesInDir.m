



function fileList=getAllFilesInDir(dirPath,filter)
    srchPath=fullfile(char(dirPath),char(filter));
    files=dir(srchPath);
    fileList={files.folder}+string(filesep)+{files.name};
end
