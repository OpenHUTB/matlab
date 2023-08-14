function result=getSLXCFileOnPath(aFile)




    result=aFile;
    if~isfile(aFile)
        result=which(aFile);
    end
end