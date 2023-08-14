function mustBeChannelGroupsOf(selectedChannelGroups,channelList)




    import matlab.io.tdms.internal.*
    try
        if utility.isEmptyString(selectedChannelGroups)
            return
        end
        validator.mustBeChannelList(channelList);
        mustBeMember(selectedChannelGroups,unique(channelList.ChannelGroupName));
    catch ME
        if strcmp(ME.identifier,"MATLAB:validators:mustBeMember")
            eid="tdms:TDMS:InvalidChannelGroupName";
            channelGpNames=unique(channelList.ChannelGroupName);
            CgEx=MException(eid,message(eid,strjoin(channelGpNames,newline)));
            throwAsCaller(CgEx);
        else
            throwAsCaller(ME);
        end
    end
end