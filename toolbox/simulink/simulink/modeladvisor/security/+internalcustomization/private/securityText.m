






function string=securityText(id,varargin)
    prefix='RTW:security:';
    messageId=[prefix,id];
    string=DAStudio.message(messageId,varargin{:});
end

