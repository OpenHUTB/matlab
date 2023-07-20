function warnNoBacktrace(messageID,varargin)




    ws=warning('off','backtrace');
    if isMessageID(messageID)
        warning(message(messageID,varargin{:}));
    else
        warning(messageID,varargin{:});
    end
    if strcmp(ws.state,'on')
        warning('on','backtrace');
    end
end

function yesno=isMessageID(text)
    yesno=~any(text==' ')&&~contains(text,'://')&&length(find(text==':'))>1;
end
