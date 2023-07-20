function clearHighlights(obj)





    if obj.isWebPageReady
        obj.publish('clearHighlights','clear all');
    else
        obj.deferredMsgs{end+1}={'clearHighlights','clear all'};
    end
