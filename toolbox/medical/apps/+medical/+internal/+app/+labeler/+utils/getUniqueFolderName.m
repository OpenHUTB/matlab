function folderName=getUniqueFolderName(path,folderName)





    folderName=string(folderName);

    dirDetails=dir(path);
    isDirectory=[dirDetails.isdir];
    dirDetails=dirDetails(isDirectory);

    names={dirDetails.name};
    folderName=matlab.lang.makeUniqueStrings(folderName,names);

end
