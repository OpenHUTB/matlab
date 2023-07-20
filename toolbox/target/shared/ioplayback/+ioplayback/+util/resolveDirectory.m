function dirName=resolveDirectory(dirName)




    dirName=strtrim(dirName);
    if~exist(dirName,'dir')
        error(message('ioplayback:utils:DirectoryDoesNotExists',dirName));
    end
    [~,info]=fileattrib(dirName);
    if(info.UserRead==0)
        error(message('ioplayback:utils:DirectoryNotReadable',dirName));
    end
    dirName=info.Name;
end