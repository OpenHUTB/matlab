function[blockValidPath,validModelName]=getTemporaryValidBlockPath(prefix,blockPath)




    [modelName,blockRelativePath]=strtok(blockPath,'/');
    validModelName=slEnginePir.util.getTemporaryModelName(prefix,modelName);
    blockValidPath=[validModelName,blockRelativePath];
end
