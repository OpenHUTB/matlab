function dealLinkData(this,parentRoot,childRootsArray)
    childRootNames=cell(size(childRootsArray));
    for i=1:length(childRootNames)
        childRootNames{i}=childRootsArray{i}.url;
    end
    parentLinkDataCount=parentRoot.linkData.size;
    moved=false(1,parentLinkDataCount);
    for i=1:parentLinkDataCount
        linkDatum=parentRoot.linkData.at(i);
        dependentUrl=strrep(linkDatum.getValue('dependentUrl'),'$ModelName$',parentRoot.url);
        matched=strcmp(childRootNames,dependentUrl);
        if any(matched)
            matchedIdx=find(matched);
            if length(matchedIdx)==1
                data=rmidd.LinkData(this.graph);
                for j=1:linkDatum.names.size
                    data.names.append(linkDatum.names.at(j));
                    data.values.append(linkDatum.values.at(j));
                end
                childRootsArray{matchedIdx}.linkData.append(data);
                moved(i)=true;
            else
                error('Error in dealLinkData(): multiple matches for %s',dependentUrl);
            end
        elseif~strcmp(dependentUrl,parentRoot.url)


            warning('RMIRepository: martian linkData source "%s"',dependentUrl);
            moved(i)=true;
        end
    end
    if any(moved)
        movedIdx=find(moved);
        for i=length(movedIdx):-1:1
            parentRoot.linkData.erase(movedIdx(i));
        end
    end
end


