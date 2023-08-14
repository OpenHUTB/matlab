function validatePathWhiteSpace(pathStr,folderName)





    absPath=downstream.tool.getAbsoluteFolderPath(pathStr);


    checkSpace=regexp(absPath,' ','once');
    if~isempty(checkSpace)
        error(message('hdlcommon:workflow:SpaceInPath',absPath,folderName));
    end

end
