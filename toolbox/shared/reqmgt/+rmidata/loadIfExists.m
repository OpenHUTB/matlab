function[result,deferredNotification]=loadIfExists(modelH)

    modelPath=get_param(modelH,'FileName');
    deferredNotification={};

    if isempty(modelPath)
        result=false;
    else
        [result,deferredNotification]=slreq.utils.loadLinkSet(modelPath,false);
    end
end


