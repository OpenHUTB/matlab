classdef WordDocChecker<slreq.backlinks.Checker



    properties
docUtilObj
bookmarksInfo
    end

    properties(Constant)
        MAX_DISTANCE_TO_ANCHOR=20;
    end

    methods

        function this=WordDocChecker(documentName)
            this@slreq.backlinks.Checker();
            this.domain='linktype_rmi_word';
            this.document=documentName;
        end

        function initialize(this)
            fullPathToDoc=this.getFullPathToDoc();
            this.docUtilObj=rmidotnet.docUtilObj(fullPathToDoc,true);
        end

        function id=getCanonicalId(this,id)%#ok<INUSL>


            if~isempty(id)&&id(1)=='@'
                id(1)=[];
            end
        end

        function[countUnmatched,countChecked]=countUnmatchedLinks(this)
            if isempty(this.mwSource)
                error('need to assign SOURCE before checking backlinks');
            end
            if~isa(this.mwLinksMap,'containers.Map')
                error('need to populate mwLinksMap before checking backlinks');
            end
            linksToCheck=this.findRefLinksBySource();
            countChecked=numel(linksToCheck);
            if countChecked==0
                countUnmatched=0;
            else
                countUnmatched=this.registerIfUnmatched(linksToCheck);
            end
        end

        function count=deleteUnmatchedLinks(this)


            if this.lastChecked<this.lastRefreshed
                error(message('Slvnv:slreq_backlinks:StaleDataNeedToRerun','WordDocChecker'));
            else
                count=this.doDeleteUnmatched();
            end
        end

        function tf=isFile(~)
            tf=true;
        end

    end

    methods(Access=private)

        function refLinks=findRefLinksBySource(this)

            fullPathToDoc=this.getFullPathToDoc();
            this.docUtilObj=rmidotnet.docUtilObj(fullPathToDoc);
            backlinksInfo=this.docUtilObj.findBacklinks();

            if isempty(backlinksInfo)
                refLinks=[];
            else
                refLinks=this.filterByLinkedArtifact(backlinksInfo);
            end
        end

        function filtered=filterByLinkedArtifact(this,unfiltered)
            isWantedSource=false(size(unfiltered));
            [~,wantedName,wantedExt]=fileparts(this.mwSource);
            for i=1:length(unfiltered)
                [~,linkedName,linkedExt]=fileparts(unfiltered(i).mwSource);
                if strcmp(linkedName,wantedName)
                    if isempty(linkedExt)||strcmp(linkedExt,wantedExt)





                        isWantedSource(i)=true;
                    end
                end
            end
            filtered=unfiltered(isWantedSource);
        end

        function count=registerIfUnmatched(this,documentLinks)



            count=0;


            definedDomainType=rmi.linktype_mgr('resolveByRegName',this.domain);
            if isempty(definedDomainType)
                return;
            end
            if isempty(definedDomainType.BacklinkDeleteFcn)
                return;
            end
            totalLinks=length(documentLinks);
            this.bookmarksInfo=this.docUtilObj.findBookmarks();
            for i=1:totalLinks
                mwItemId=documentLinks(i).mwId;
                docItemIndex=documentLinks(i).index;
                docItemRange=documentLinks(i).range;
                if this.atOrAfterLinkedBookmark(docItemRange,mwItemId)

                else
                    this.registerUnmatchedLink(num2str(docItemIndex),docItemRange);
                    count=count+1;
                end
            end
            this.lastChecked=now;
        end

        function tf=atOrAfterLinkedBookmark(this,rangeInDoc,mwItemId)

            for i=1:length(this.bookmarksInfo)
                bookmarkRange=this.bookmarksInfo(i).range;
                if rangeInDoc(1)>=bookmarkRange(1)&&rangeInDoc(2)<=bookmarkRange(2)

                    bookmarkName=this.bookmarksInfo(i).id;
                elseif rangeInDoc(1)>=bookmarkRange(2)&&rangeInDoc(1)<bookmarkRange(2)+this.MAX_DISTANCE_TO_ANCHOR

                    bookmarkName=this.bookmarksInfo(i).id;
                else
                    continue;
                end

                if isKey(this.mwLinksMap,bookmarkName)
                    if any(strcmp(this.mwLinksMap(bookmarkName),mwItemId))
                        tf=true;
                        return;
                    end
                end
            end
            tf=false;
        end

        function count=doDeleteUnmatched(this)
            count=0;
            hyperlinkOrderNumbers=keys(this.unmatchedMap);


            hyperlinkAnchorRanges=values(this.unmatchedMap);
            ranges=zeros(size(hyperlinkAnchorRanges));
            for j=1:length(ranges)
                ranges(j)=hyperlinkAnchorRanges{j}{1}(1);
            end
            [~,sortIdx]=sort(ranges);
            sortedHyperlinkNumbers=hyperlinkOrderNumbers(sortIdx);
            hyperlinks=this.docUtilObj.hDoc.Hyperlinks;
            for j=length(sortedHyperlinkNumbers):-1:1
                orderNumber=str2num(sortedHyperlinkNumbers{j});%#ok<ST2NM>
                try
                    oneHyperlink=hyperlinks.Item(orderNumber);
                    if strcmp(char(oneHyperlink.Type),'msoHyperlinkShape')

                        oneHyperlink.Shape.Delete;
                    else

                        oneHyperlink.Delete;
                    end
                    count=count+1;
                catch ex
                    rmiut.warnNoBacktrace(ex.message);
                end
            end
        end

    end

end



