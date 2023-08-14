function validateFolder(pathStr,folderName)





    downstream.tool.checkNonASCII(pathStr,folderName);


    absPath=downstream.tool.getAbsoluteFolderPath(pathStr);


    if ispc&&strcmp(absPath(1:2),'\\')

        error(message('hdlcommon:workflow:UNCPath',absPath,folderName));
    end


    hiRange=65533;
    loRange=128;

    checkUniChars=any(double(absPath)>=loRange&double(absPath)<=hiRange);

    if checkUniChars
        error(message('hdlcommon:workflow:UnicodeCharsInPathError',absPath));
    end
end



