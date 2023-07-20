function out=getMessage(obj,msgId,varargin)
    msgID=['CoderFoundation:report:',msgId];
    if obj.IsEnMessage
        out=coder.report.internal.getEnglishMessage(msgID,varargin{:});
    else
        out=DAStudio.message(msgID,varargin{:});
    end
end
