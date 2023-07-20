function fullDirName=rtw_create_directory_path(varargin)



    if(nargin<1)
        DAStudio.error('RTW:utility:invalidArgCount',...
        'rtw_create_directory_path','at least one');
    end;


    fullDirName=fullfile(varargin{:});

    if(~exist(fullDirName,'dir'))
        [status,msg,msgID]=builtin('mkdir',fullDirName);








        if~isempty(msgID)






            if~(strcmp(msgID,'MATLAB:MKDIR:DirectoryExists')&&(status==1))
                newMsgID='RTW:utility:mkdirError';
                newMsg=DAStudio.message(newMsgID,fullDirName,msg);
                exc=MException(newMsgID,'%s',newMsg);
                throw(exc);
            end
        end
    end

