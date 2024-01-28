function url=getCSHURL(mapkey,topicid)
    helpTopicMap=matlab.internal.doc.csh.HelpTopicMap.fromTopicPath("mapkey:"+mapkey);
    if~isempty(helpTopicMap)
        url=char(helpTopicMap.mapTopic(topicid));
    else
        url='';
    end
end