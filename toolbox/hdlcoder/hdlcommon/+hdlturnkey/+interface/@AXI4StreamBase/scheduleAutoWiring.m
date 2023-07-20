function scheduleAutoWiring(obj)









    inReadyNum=0;
    outReadyNum=0;
    channelIDlist=obj.hChannelList.getAssignedChannels;
    for ii=1:length(channelIDlist)
        channelID=channelIDlist{ii};
        hChannel=obj.hChannelList.getChannel(channelID);
        hReadyPort=hChannel.getReadyPort;
        if~hReadyPort.isAssigned
            if hChannel.ChannelDirType==hdlturnkey.IOType.IN
                inReadyNum=inReadyNum+1;
            else
                outReadyNum=outReadyNum+1;
            end
        end
    end


    if inReadyNum==1&&outReadyNum==1
        channelIDlist=obj.hChannelList.getAssignedChannels;
        for ii=1:length(channelIDlist)
            channelID=channelIDlist{ii};
            hChannel=obj.hChannelList.getChannel(channelID);
            hReadyPort=hChannel.getReadyPort;
            if~hReadyPort.isAssigned






                hChannel.NeedAutoReadyWiring=true;
            end
        end
    end

end


