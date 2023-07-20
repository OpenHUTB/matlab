function mustBeChannelsOf(selectedChannels,selectedChannelGroup,channelList)



    import matlab.io.tdms.internal.*
    try
        if utility.isEmptyString(selectedChannels)
            return
        end

        if utility.isEmptyString(selectedChannelGroup)
            error(message("tdms:TDMS:ChannelsWithoutChannelGroupSpecified"));
        end

        matlab.io.tdms.internal.validator.mustBeChannels(selectedChannels);
        matlab.io.tdms.internal.validator.mustBeAChannelGroupOf(selectedChannelGroup,channelList);
        channelNames=channelList.ChannelName(ismember(channelList.ChannelGroupName,selectedChannelGroup));
        mustBeMember(selectedChannels,channelNames);

    catch ME
        if strcmp(ME.identifier,"MATLAB:validators:mustBeMember")
            channelNames=channelList.ChannelName(ismember(channelList.ChannelGroupName,selectedChannelGroup));
            eid="tdms:TDMS:InvalidChannelName";
            ChEx=MException(eid,message(eid,strjoin(channelNames,newline)));
            throwAsCaller(ChEx);
        end
        throwAsCaller(ME);
    end

end