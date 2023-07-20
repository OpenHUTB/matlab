function deleteWeightFiles(codegenDir)





    fileList=dir(codegenDir);
    fileNames={fileList(~[fileList.isdir]).name};

    networkFilesPrefix='cnn_';


    networkFileNames=fileNames(strncmp(fileNames,networkFilesPrefix,numel(networkFilesPrefix)));
    networkFileNames=networkFileNames(cellfun(@(x)endsWith(x,'.bin'),networkFileNames));

    if~isempty(networkFileNames)
        networkFileNames=cellfun(@(x)fullfile(codegenDir,x),networkFileNames,'UniformOutput',false);
        delete(networkFileNames{:});
    end

end
