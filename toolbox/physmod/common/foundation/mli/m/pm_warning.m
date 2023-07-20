function pm_warning(msgid,varargin)










    narginchk(1,nargin);

    msg=pm_unsprintf(pm_message(msgid,varargin{:}));

    pm_callwarning(msgid,msg);
end
