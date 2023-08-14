function channelList=createChannelList(structChannelList)



    channelList=struct2table(formatChannelList(structChannelList));
end

function structChannelList=formatChannelList(structChannelList)
    import matlab.io.tdms.internal.wrapper.utility.*
    props=convertCharsToStrings(fieldnames(structChannelList)');
    for prop=props
        structChannelList.(prop)=replaceMissingType(convertCharsToStrings(structChannelList.(prop)'));
    end
end

