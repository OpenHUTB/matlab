function readAllBookmarksForTestNames(this,filepath)




    parseTree=rmiml.RmiMUnitData.getParsedMTree(filepath);

    linkset=slreq.data.ReqData.getInstance.getLinkSet(filepath);
    if isempty(linkset)

        return;
    end
    links=linkset.getAllLinks();
    nLinks=numel(links);
    bookmarkPositions=zeros(nLinks,2);
    for i=1:nLinks
        iLink=links(i);
        linkSrc=iLink.source;
        bookmarkPositions(i,:)=[linkSrc.startPos,linkSrc.endPos];
    end
    bookmarkPositions=unique(bookmarkPositions,'rows');
    [nBookmarks,~]=size(bookmarkPositions);
    for i=1:nBookmarks
        positions=bookmarkPositions(i,:);
        cacheKey=sprintf("%s::%d::%d",filepath,positions(1),positions(2));
        [names,isFileLevel]=this.getTestNamesUnderRangeRaw(filepath,positions,parseTree);
        cacheVal=struct();
        cacheVal.(this.FIELD_NAMES)=names;
        cacheVal.(this.FIELD_ISFILELEVEL)=isFileLevel;
        this.bookmarkToTestCache(cacheKey)=cacheVal;
    end













end
