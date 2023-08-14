function tf=isFileLocked(filename)








    filePath=mlreportgen.utils.findFile(filename);
    tf=true;



    try
        if isfile(filePath)
            tmpFilePath=filePath+".bak";
            movefile(filePath,tmpFilePath);
            movefile(tmpFilePath,filePath);
        end
        tf=false;
    catch
    end
end
