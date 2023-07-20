function absoluteFilePath=getAbsoluteFilePath(relativeFilePath)





    [relativeFolder,fileName,fileExt]=fileparts(relativeFilePath);
    absoluteFolder=downstream.tool.getAbsoluteFolderPath(relativeFolder);


    absoluteFilePath=fullfile(absoluteFolder,sprintf('%s%s',fileName,fileExt));

