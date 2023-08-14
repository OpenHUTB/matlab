function highlight(obj,name,reason)




    name=configset.internal.util.convertHighlightInput(name,obj.Source);

    if nargin<3
        reason='default';
    end

    s.name=name;
    s.reason=reason;

    if obj.isWebPageReady
        obj.publish('highlight',s);
    else
        obj.deferredMsgs{end+1}={'highlight',s};
    end

