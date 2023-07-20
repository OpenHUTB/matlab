function str=getCatalogMsgStr(key,varargin)




    msgid=['EDALink:FILWizard:',key];

    if(nargin==1)
        str=getString(message(msgid));
    else
        str=getString(message(msgid,varargin{:}));
    end



