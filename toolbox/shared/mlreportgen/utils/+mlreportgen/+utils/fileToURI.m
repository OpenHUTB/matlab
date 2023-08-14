function uri=fileToURI(fileName)








    filePath=mlreportgen.utils.findFile(fileName,'FileMustExist',false);
    uri=string(mlreportgen.utils.internal.fileToURI(filePath));
end