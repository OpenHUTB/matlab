function mustBeAChannelGroupOf(selectedChannelGroup,channelList)



    import matlab.io.tdms.internal.*
    try
        if utility.isEmptyString(selectedChannelGroup)
            return
        end
        validator.mustBeAChannelGroup(selectedChannelGroup);
        validator.mustBeChannelList(channelList);
        mustBeMember(selectedChannelGroup,unique(channelList.ChannelGroupName));
    catch ME
        if strcmp(ME.identifier,"MATLAB:validators:mustBeMember")
            eid="tdms:TDMS:InvalidChannelGroupName";
            channelGpNames=unique(channelList.ChannelGroupName);
            CgEx=MException(eid,message(eid,strjoin(channelGpNames,newline)));
            throwAsCaller(CgEx);
        end
        throwAsCaller(ME);
    end
end