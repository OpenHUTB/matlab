function removeDir(dirPath)




    if isempty(dirPath)
        return;
    end

    if~exist(dirPath,'dir')
        return;
    end

    [status,~,msgID]=rmdir(dirPath,'s');
    if status==0
        if strcmp(msgID,'MATLAB:RMDIR:NotADirectory')
            return;
        else
            error(message('hdlcommon:workflow:UnableRemoveDir',dirPath));
        end
    end

end


