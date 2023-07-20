function absPath=getURLForFilePath(jsonFilePath,relativePath)






    relPath=relativePath;

    filePath=erase(jsonFilePath,[filesep,'functionSignatures.json']);
    if~contains(relPath,'./')
        relPath=extractAfter(relPath,2);
    end

    if~contains(relPath,'.')&&contains(relPath,'..')
        relPath=extractAfter(relPath,1);
    end


    while contains(relPath,'../')
        indexChar=regexp(filePath,filesep,'end');
        filePath=extractBefore(filePath,indexChar(end));
        relPath=extractAfter(relPath,3);
    end
    subStr=extractBefore(filePath,'toolbox');
    substr1=extractAfter(filePath,subStr);
    absPath=strcat(substr1,filesep,relPath);
end