function msg=getMessageFromCatalog(messageId,varargin)







    fullMessageId=['physmod:common:logging:sli:dataexplorer:',messageId];

    nVarargs=length(varargin);
    if nVarargs==1
        messageObj=message(fullMessageId,varargin{1});
    elseif nVarargs==2
        messageObj=message(fullMessageId,varargin{1},varargin{2});
    else
        messageObj=message(fullMessageId);
    end

    msg=messageObj.getString();
end
