function s=isParentPath(parentPath,childPath)









    if parentPath(end)~='/'
        parentPath=[parentPath,'/'];
    end

    s=strncmp(parentPath,childPath,length(parentPath));
end

