function applySignalLogging(obj,simWatcher)



    signaLoggingMSGList={};
    if(isempty(simWatcher.modelLoggingInfo)&&simWatcher.modelLoggingInfoDone==false)
        signaLoggingMSGList=simWatcher.prepareForIteratingSignalSetInFS();
    end
    tmpMSGList=obj.configureSignalsForStreaming(simWatcher);
    signaLoggingMSGList=[signaLoggingMSGList,tmpMSGList];

    signaLoggingMSGList=unique(signaLoggingMSGList);
    if(~isempty(signaLoggingMSGList))
        obj.addMessages(signaLoggingMSGList,num2cell(true(1,length(signaLoggingMSGList))));
    end
end