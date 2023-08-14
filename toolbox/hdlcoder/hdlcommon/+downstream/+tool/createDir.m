function createDir(dirPath)




    if isempty(dirPath)
        return;
    end

    [status,~,~]=mkdir(dirPath);
    if status==0
        error(message('hdlcommon:workflow:UnableCreateDir',dirPath));
    end

end