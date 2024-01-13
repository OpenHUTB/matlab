function p=createTempDir(varargin)

    numRetries=0;

    while true
        p=tempname(varargin{:});
        [status,msg,msgId]=mkdir(p);
        if status

            if strcmp(msgId,'MATLAB:MKDIR:DirectoryExists')

                if numRetries<1000
                    numRetries=numRetries+1;
                    continue
                else
                    error(msgId,msg);
                end
            else
                break
            end
        else
            error(msgId,msg);
        end
    end
