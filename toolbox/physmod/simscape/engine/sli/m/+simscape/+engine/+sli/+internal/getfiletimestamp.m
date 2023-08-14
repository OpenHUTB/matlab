function result=getfiletimestamp(filePath)





    theFileAttributes=dir(filePath);
    result='';
    if~isempty(theFileAttributes)
        result=theFileAttributes.date;
    end

end
