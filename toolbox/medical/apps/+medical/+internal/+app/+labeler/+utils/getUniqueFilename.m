function fileName=getUniqueFilename(path,filename)






    dirDetails=dir(path);
    isDirectory=[dirDetails.isdir];
    dirDetails=dirDetails(~isDirectory);

    names={dirDetails.name};
    [~,names,~]=fileparts(names);

    fileName=matlab.lang.makeUniqueStrings(filename,names);

end
