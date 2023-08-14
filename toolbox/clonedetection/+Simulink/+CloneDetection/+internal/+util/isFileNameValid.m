function isValid=isFileNameValid(fileName)




    startIndexList=regexp(fileName,'^[a-zA-Z][a-zA-Z0-9_]*$','ONCE');
    isValid=~isempty(startIndexList);
end