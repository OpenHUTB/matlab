function yesno=isCurrentCache(filePath,timestamp)

    filePath=convertStringsToChars(filePath);

    fileInfo=dir(filePath);

    if isempty(fileInfo)
        yesno=false;
        return;
    end



    yesno=(fileInfo.datenum==timestamp);
end
