function[outMap,grouplist,totallinks]=groupLinks(reqInfo,type)


    grouplist={};
    outMap=containers.Map('KeyType','Char','ValueType','any');
    allLinkTypes=slreq.utils.getAllLinkTypes;

    inType='#?<-?#';
    outType='#?->?#';
    totallinks=[0,0];
    for typeIndex=1:length(allLinkTypes)
        thisLinkType=allLinkTypes(typeIndex);

        inLinks=reqInfo.getIncomingLinksWithType(thisLinkType.typeName,true);
        outLinks=reqInfo.getOutgoingLinksWithType(thisLinkType.typeName,true);
        totallinks=totallinks+[length(inLinks),length(outLinks)];
        if~isempty(inLinks)
            if strcmp(type,'linktype')
                outMapKey=[thisLinkType.typeName,inType];
                outMap(outMapKey)=inLinks;
                grouplist{end+1}=thisLinkType.typeName;
            elseif strcmp(type,'linkartifact')
                for ilIndex=1:length(inLinks)
                    cLink=inLinks(ilIndex);
                    linkTarget=cLink.source;
                    if~ismember(linkTarget.artifactUri,grouplist)
                        grouplist{end+1}=linkTarget.artifactUri;
                    end
                    outMapKey=[linkTarget.artifactUri,inType];
                    if isKey(outMap,outMapKey)
                        tempartiLinks=outMap(outMapKey);
                        tempartiLinks(end+1)=cLink;
                        outMap(outMapKey)=tempartiLinks;
                    else
                        outMap(outMapKey)=cLink;
                    end
                end
            end
        end

        if~isempty(outLinks)
            if strcmp(type,'linktype')
                outMapKey=[thisLinkType.typeName,outType];
                outMap(outMapKey)=outLinks;
                grouplist{end+1}=thisLinkType.typeName;
            elseif strcmp(type,'linkartifact')
                for olIndex=1:length(outLinks)
                    cLink=outLinks(olIndex);
                    linkTarget=cLink.dest;
                    artifact=slreq.report.utils.getLinkArtifact(linkTarget);
                    if isempty(artifact)
                        artifact=cLink.destUri;
                    end
                    if~ismember(artifact,grouplist)
                        grouplist{end+1}=artifact;
                    end
                    outMapKey=[artifact,outType];
                    if isKey(outMap,outMapKey)
                        tempartiLinks=outMap(outMapKey);
                        tempartiLinks(end+1)=cLink;
                        outMap(outMapKey)=tempartiLinks;
                    else
                        outMap(outMapKey)=cLink;
                    end
                end
            end
        end
    end

    grouplist=sort(grouplist);
end

