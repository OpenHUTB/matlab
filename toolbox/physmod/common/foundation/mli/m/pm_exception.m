function exception=pm_exception(msgid,varargin)



















    narginchk(1,nargin);

    if pm_hasmessage(msgid)
        msg=pm_message(msgid,varargin{:});
        msg=pm_unsprintf(msg);
        exception=MException(...
        msgid,msg);
    else
        exception=MException(...
        message(msgid,varargin{:}));
    end

end
