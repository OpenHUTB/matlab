function[blockValidPath,validModelName]=getValidBlockPath(prefix,blockPath)




    [modelName,blockRelativePath]=strtok(blockPath,'/');
    validModelName=slEnginePir.util.getBackupModelName(prefix,modelName);
    blockValidPath=[validModelName,blockRelativePath];
end
