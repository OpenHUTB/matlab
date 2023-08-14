function result=datenum(filePath)





    theFileAttributes=dir(which(filePath));
    result=0.0;
    if~isempty(theFileAttributes)
        result=theFileAttributes.datenum;
    end

end
