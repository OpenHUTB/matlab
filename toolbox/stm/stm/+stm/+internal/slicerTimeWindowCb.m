function slicerTimeWindowCb(evtData,timeDiff)




    evtData.data(2)={evtData.data{2}-timeDiff};
    evtData.data(3)={evtData.data{3}-timeDiff};

    twdata=struct('modelStartTime',evtData.data(1),'startTime',...
    evtData.data(2),'stopTime',evtData.data(3),'simStatus',...
    evtData.data(4),'isFastRestartEnabled',evtData.data(5));
    payloadStruct=struct('VirtualChannel','Results/SyncTimeWindowCursors','Payload',twdata);
    message.publish('/stm/messaging',payloadStruct);
end
