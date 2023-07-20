function info=formatMexInfo(mexInfo)



    import matlab.io.tdms.internal.wrapper.utility.*
    info=matlab.io.tdms.TdmsInfo;
    info.Path=mexInfo.Path;
    info.Name=mexInfo.Name;
    info.Description=mexInfo.Description;
    info.Title=mexInfo.Title;
    info.Author=mexInfo.Author;
    info.Version=mexInfo.Version;
    info.ChannelList=createChannelList(mexInfo.ChannelList);
end

