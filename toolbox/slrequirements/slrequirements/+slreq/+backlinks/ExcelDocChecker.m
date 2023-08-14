classdef ExcelDocChecker<slreq.backlinks.Checker



    properties
docUtilObj
namedRanges
    end

    methods

        function this=ExcelDocChecker(documentName)
            this@slreq.backlinks.Checker();
            this.domain='linktype_rmi_excel';
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
                error(message('Slvnv:slreq_backlinks:StaleDataNeedToRerun','ExcelDocChecker'));
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
            if isempty(definedDomainType.BacklinkCheckFcn)&&isempty(definedDomainType.BacklinksCleanupFcn)
                return;
            end
            totalLinks=length(documentLinks);
            this.namedRanges=this.docUtilObj.findNamedRange();
            for i=1:totalLinks
                mwItemId=documentLinks(i).mwId;
                docItemIndex=documentLinks(i).index;
                docItemAddress=documentLinks(i).cell;
                if this.belongsToCorrectLinkedRange(docItemAddress,mwItemId)

                else
                    this.registerUnmatchedLink(num2str(docItemIndex),docItemAddress);
                    count=count+1;
                end
            end
            this.lastChecked=now;
        end

        function tf=belongsToCorrectLinkedRange(this,rangeInDoc,mwItemId)

            tf=false;




            name='';
            for i=1:length(this.namedRanges)
                oneNamedRange=this.namedRanges(i);
                address=oneNamedRange.address;
                range=oneNamedRange.range;
                if rangeInDoc(1)>=address(1)&&rangeInDoc(1)<address(1)+range(1)&&...
                    rangeInDoc(2)>=address(2)&&rangeInDoc(2)<address(2)+range(2)
                    name=oneNamedRange.label;
                    break;
                end
            end
            if~isempty(name)&&isKey(this.mwLinksMap,name)
                linkedItems=this.mwLinksMap(name);
                if any(strcmp(linkedItems,mwItemId))

                    tf=true;
                    return;
                end
            end








            textInDoc=this.docUtilObj.getTextFromCell(rangeInDoc(1),rangeInDoc(2));
            if isKey(this.mwLinksMap,['?',textInDoc])
                linkedItems=this.mwLinksMap(['?',textInDoc]);
                tf=any(strcmp(linkedItems,mwItemId));
            end
        end

        function count=doDeleteUnmatched(this)
            count=0;
            unmatchedHyperlinkIndexStrings=keys(this.unmatchedMap);

            unmatchedHyperlinkIndex=zeros(size(unmatchedHyperlinkIndexStrings));
            for i=1:length(unmatchedHyperlinkIndex)
                unmatchedHyperlinkIndex(i)=str2num(unmatchedHyperlinkIndexStrings{i});%#ok<ST2NM>
            end
            hyperlinkAnchorRanges=values(this.unmatchedMap);
            hyperlinks=this.docUtilObj.hSheet.Hyperlinks;


            [sortedUnmatchedHyperlinkIndex,sortIdx]=sort(unmatchedHyperlinkIndex);
            sortedHyperlinkAnchorRanges=hyperlinkAnchorRanges(sortIdx);
            for j=length(sortedUnmatchedHyperlinkIndex):-1:1
                myIdx=sortedUnmatchedHyperlinkIndex(j);
                try
                    oneHyperlink=hyperlinks.Item(myIdx);


                    expectedRange=sortedHyperlinkAnchorRanges{j}{1};


                    if oneHyperlink.Type==int32(1)
                        iconRange=rmidotnet.MSExcel.getRowAndColAddress(oneHyperlink.Shape);
                        if all(iconRange==expectedRange)
                            oneHyperlink.Shape.Delete;
                            count=count+1;
                        end
                    else
                        hLinkRange=oneHyperlink.Range;
                        if all([hLinkRange.Row,hLinkRange.Column]==expectedRange)
                            oneHyperlink.Delete;
                            count=count+1;
                        end
                    end
                catch ex
                    rmiut.warnNoBacktrace(ex.message);
                end
            end
        end

    end

end



