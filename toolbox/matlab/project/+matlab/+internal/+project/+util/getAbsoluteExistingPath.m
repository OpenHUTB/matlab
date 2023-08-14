function absPath=getAbsoluteExistingPath(inPath)





    parent=fileparts(inPath);
    if strlength(parent)~=0&&~isfolder(parent)
        error(message('MATLAB:project:api:FolderDoesNotExist',parent))
    end
    if isfolder(fullfile(pwd,parent))&&~startsWith(inPath,filesep)
        absPath=fullfile(pwd,inPath);
    else
        absPath=inPath;
    end
end

