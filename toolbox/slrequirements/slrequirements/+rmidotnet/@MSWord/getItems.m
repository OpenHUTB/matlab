function orderedItems=getItems(this,varargin)













    items=[];
    paragOrder=[];

    if~this.validate()
        orderedItems=[];
        return;
    end

    if isstruct(varargin{1})
        options=varargin{1};
    else
        options=parseArgs(varargin);
    end

    getBookmarks=isfield(options,'bookmarks')&&options.bookmarks;
    getMatches=isfield(options,'match')&&~isempty(options.match);
    ignoreOutlineNumbers=isfield(options,'ignoreOutlineNumbers')&&options.ignoreOutlineNumbers;




    allParagraphs=this.hDoc.Paragraphs;
    totalParagraphs=allParagraphs.Count;
    isIncluded=false(totalParagraphs,1);

    count=0;
    slreq.import.deduplicate();


    bodyTextItems=(this.iLevels<0&this.iParents>0);


    subsectionIdx=this.iParents(bodyTextItems);

    uniqueSubsectionIdx=unique(subsectionIdx);

    if isempty(uniqueSubsectionIdx)

        rmiut.warnNoBacktrace('Slvnv:slreq_import:NoOutlineSections',this.sName);
        beep;
        ignoreOutlineNumbers=false;

        for idx=1:length(this.iLevels)
            paragItem.type='parag';

            if getMatches
                label=matchLabelInParag(idx);
            else
                label='';
            end
            if~isempty(label)
                paragItem.label=label;
                paragItem.type='match';
            else
                paragItem.label=localParagToLabel(idx,false);
            end
            paragItem.parags=idx;
            paragItem.range=[this.iStarts(idx),this.iEnds(idx)];
            addItem(paragItem);
        end
    else

        for idx=uniqueSubsectionIdx'
            sectionItem.type='section';

            if getMatches

                label=matchLabelInParag(idx);
            else
                label='';
            end

            if~isempty(label)
                sectionItem.type='match';
                sectionItem.label=label;
            else
                sectionItem.label=localParagToLabel(idx,true);
            end
            sectionItem.range=[this.iStarts(idx),this.iEnds(idx)];

            children=find(this.iParents==idx);
            isBodyText=(this.iLevels(children)<0);
            if any(~isBodyText)
                stopHere=find(~isBodyText);
                children=children(1:stopHere(1)-1);
            end
            if isempty(children)
                sectionItem.parags=idx;
            else
                sectionItem.parags=[idx,children'];
            end

            if getMatches


                prevMatch=[];

                for childIdx=1:length(children)

                    childParag=children(childIdx);

                    label=matchLabelInParag(childParag);
                    if isempty(label)
                        continue;
                    end
                    matchItem.label=label;
                    matchItem.type='match';
                    matchItem.parags=childParag;
                    childText=this.getText(childParag);
                    localPosition=strfind(childText,matchItem.label);
                    matchItem.range=[...
                    this.iStarts(childParag)+localPosition-1,...
                    this.iStarts(childParag)+localPosition+length(matchItem.label)-1];

                    if isempty(prevMatch)

                        sectionItem.parags(sectionItem.parags>=childParag)=[];
                        sectionItem.range(2)=this.iEnds(sectionItem.parags(end));

                    elseif prevMatch+1<childParag

                        midItem.label=localParagToLabel(prevMatch+1,false);
                        midItem.type='parag';
                        midItem.parags=prevMatch+1:childParag-1;
                        midItem.range=[this.iStarts(prevMatch+1),this.iEnds(childParag-1)];
                        addItem(midItem);
                    end

                    prevMatch=childParag;


                    addItem(matchItem);
                end


                if~isempty(prevMatch)&&prevMatch<children(end)
                    tailItem.label=localParagToLabel(prevMatch+1,false);
                    tailItem.type='parag';
                    tailItem.parags=prevMatch+1:children(end);
                    tailItem.range=[this.iStarts(prevMatch+1),this.iEnds(children(end))];
                    addItem(tailItem);
                end
            end

            addItem(sectionItem);
            ensureParents(idx);
        end
    end

    if getBookmarks
        hBookmarks=this.hDoc.Bookmarks;



        hBookmarkEnum=hBookmarks.GetEnumerator();
        while hBookmarkEnum.MoveNext()
            comObj=hBookmarkEnum.Current();

            if~isa(comObj,'Microsoft.Office.Interop.Word.Bookmark')
                hBookmark=Microsoft.Office.Interop.Word.Bookmark(comObj);
            end


            bookmarkName=hBookmark.Name.char;
            hBookMarkRange=hBookmark.Range;

            startPos=hBookMarkRange.Start;
            endPos=hBookMarkRange.End;
            [startPar,endPar]=rangeToParagIdx(hBookMarkRange);







            if this.iLevels(startPar)>0


                itemIdx=find(paragOrder==startPar);
                if length(itemIdx)~=1
                    if isempty(itemIdx)&&this.iLevels(startPar)>0&&endPar==startPar






                        bmItem.type='bookmark';
                        bmItem.label=bookmarkName;
                        bmItem.range=[startPos,endPos];
                        bmItem.parags=startPar:endPar;
                        addItem(bmItem);
                    else

                        rmiut.warnNoBacktrace('Slvnv:slreq_import:WdBookmarkMismatchedPosition',bookmarkName);
                    end
                else
                    items(itemIdx).type='bookmark';%#ok<AGROW>
                    items(itemIdx).label=bookmarkName;%#ok<AGROW>
                end
            elseif any(paragOrder==startPar)

                itemIdx=find(paragOrder==startPar);
                if strcmp(items(itemIdx).type,'bookmark')
                    rmiut.warnNoBacktrace('Slvnv:slreq_import:WdBookmarkConflict',items(itemIdx).label,bookmarkName);
                elseif strcmp(items(itemIdx).type,'match')

                    if items(itemIdx).parags(end)<endPar
                        items(itemIdx).parags=startPar:endPar;%#ok<AGROW>


                        removeCoveredParagItems(itemIdx+1,endPar,bookmarkName);
                    end
                elseif strcmp(items(itemIdx).type,'parag')


                    origLastParag=items(itemIdx).parags(end);
                    items(itemIdx).type='bookmark';%#ok<AGROW>
                    items(itemIdx).label=bookmarkName;%#ok<AGROW>
                    items(itemIdx).parags=startPar:endPar;%#ok<AGROW>


                    if endPar<origLastParag
                        tailItem.label=localParagToLabel(endPar+1,false);
                        tailItem.type='parag';
                        tailItem.parags=endPar+1:origLastParag;
                        tailItem.range=[this.iStarts(endPar+1),this.iEnds(origLastParag)];
                        addItem(tailItem);
                    elseif origLastParag<endPar


                        isOverlap=(items(itemIdx).parags>origLastParag);
                        if any(isOverlap)
                            items(itemIdx).parags(isOverlap)=[];%#ok<AGROW>
                        end
                    end
                else
                    error('wrong item type %s when inserting %s',items(itemIdx).type,bookmarkName);
                end
            else

                parentParagFromStart=this.iParents(startPar);
                parentParagFromEnd=this.iParents(endPar);
                if parentParagFromStart==parentParagFromEnd




                    bmItem.type='bookmark';
                    bmItem.label=bookmarkName;
                    bmItem.range=[startPos,endPos];
                    bmItem.parags=startPar:endPar;
                    addItem(bmItem);

                    paragBelow=min(paragOrder(paragOrder>endPar));
                    if~isempty(paragBelow)&&paragBelow>endPar+1


                        belowItem.type='parag';
                        belowItem.parags=endPar+1:paragBelow-1;
                        belowItem.range=[this.iStarts(endPar+1),this.iEnds(paragBelow-1)];
                        belowItem.label=localParagsToLabel(endPar+1,paragBelow-1);
                        addItem(belowItem);
                    elseif~isempty(uniqueSubsectionIdx)&&this.iParents(endPar)==uniqueSubsectionIdx(end)


                        belowItem.type='parag';
                        belowItem.parags=endPar+1:totalParagraphs;
                        belowItem.range=[this.iStarts(endPar+1),this.iEnds(totalParagraphs)];
                        belowItem.label=localParagsToLabel(endPar+1,totalParagraphs);
                        addItem(belowItem);
                    end
                else



                    rmiut.warnNoBacktrace('Slvnv:slreq_import:WdBookmarkCrossesSectionBoundary',bookmarkName);
                    childrenOfStart=find(this.iParents==parentParagFromStart);
                    lastChild=childrenOfStart(end);
                    bmItem.type='bookmark';
                    bmItem.label=bookmarkName;
                    bmItem.parags=startPar:lastChild;
                    bmItem.range=[startPos,this.iEnds(lastChild)];
                    addItem(bmItem);

                    paragBelow=min(paragOrder(paragOrder>startPar));
                    if~isempty(paragBelow)
                        idxBelow=find(paragOrder==paragBelow);
                        removeCoveredParagItems(idxBelow,lastChild,bookmarkName);
                    end
                end

                prevAbove=max(paragOrder(paragOrder<startPar));
                if~isempty(prevAbove)
                    prevItemIdx=find(paragOrder==prevAbove);
                    if~isempty(prevItemIdx)&&items(prevItemIdx).parags(end)>=startPar
                        paragsToShrink=(items(prevItemIdx).parags>=startPar);
                        items(prevItemIdx).parags(paragsToShrink)=[];%#ok<AGROW>
                    end
                end
            end
        end
    end

    if isempty(items)
        orderedItems=[];
    else
        [~,reorder]=sort(paragOrder);
        orderedItems=items(reorder);
    end







    function addItem(oneItem)
        count=count+1;
        if count==1
            items=oneItem;
        else
            items(count)=oneItem;
        end
        isIncluded(oneItem.parags)=true;
        paragOrder(count)=oneItem.parags(1);
    end









    function ensureParents(parag)
        parent=this.iParents(parag);
        while parent>0&&~isIncluded(parent)
            text=this.getText(parent);
            parentLabel=this.getLabel(parent);
            if isempty(text)
                parent=this.iParents(parent);
                continue;
            end
            parentItem.type='parent';
            if ignoreOutlineNumbers
                localLabel=slreq.import.deduplicate(parentLabel);
            else
                parentLabelPrefix=this.sLabelPrefixes{parent};
                if isempty(parentLabelPrefix)
                    localLabel=parentLabel;
                else
                    localLabel=[parentLabelPrefix,' ',parentLabel];
                end
            end
            parentItem.label=localLabel;
            parentItem.parags=parent;
            parentItem.range=[this.iStarts(parent),this.iEnds(parent)];
            addItem(parentItem);
            parent=this.iParents(parent);
        end
    end

    function label=matchLabelInParag(idx)
        match=regexp(this.getText(idx),['(',options.match,')'],'tokens');
        if~isempty(match)
            label=match{1}{1};
        else
            label='';
        end
    end

    function label=localParagToLabel(idx,mayHaveSectionNumber)
        label=this.getLabel(idx);

        if ignoreOutlineNumbers&&mayHaveSectionNumber

            label=slreq.import.deduplicate(label);
        else
            if mayHaveSectionNumber
                labelPrefix=this.sLabelPrefixes{idx};
            else
                labelPrefix='';
            end
            if isempty(labelPrefix)
                label=slreq.import.deduplicate(label);
            else
                if isempty(label)
                    label=labelPrefix;
                else
                    label=strtrim([labelPrefix,' ',label]);
                end
            end
        end

        if label(1)=='#'
            label(1)=[];
        end
    end

    function label=localParagsToLabel(startIdx,stopIdx)
        tryIdx=startIdx;
        while tryIdx<stopIdx&&this.iEnds(tryIdx)==this.iStarts(tryIdx)+1
            tryIdx=tryIdx+1;
        end

        label=localParagToLabel(tryIdx,false);
    end

    function[fromParag,toParag]=rangeToParagIdx(range)
        atOrBefore=find(this.iStarts<=range.Start);
        atOrAfter=find(this.iEnds>=range.End);
        if~isempty(atOrBefore)&&~isempty(atOrAfter)
            fromParag=atOrBefore(end);
            toParag=max(atOrAfter(1),fromParag);


        else
            fromParag=0;toParag=0;
        end
    end

    function removeCoveredParagItems(startFromItemIdx,stopAtParagIdx,bName)
        nextIdx=startFromItemIdx;
        idxToRemove=[];
        while strcmp(items(nextIdx).type,'parag')&&items(nextIdx).parags(end)<=stopAtParagIdx

            if this.iLevels(items(nextIdx).parags(1))>0
                rmiut.warnNoBacktrace('Slvnv:slreq_import:WdBookmarkCrossesSectionBoundary',bName);
                break;
            end
            idxToRemove(end+1)=nextIdx;%#ok<AGROW>
            paragsBelowIdx=(paragOrder(paragOrder>items(nextIdx).parags(end)));
            if isempty(paragsBelowIdx)
                break;
            else
                nextIdx=find(paragOrder==min(paragsBelowIdx));
            end
        end
        if~isempty(idxToRemove)
            items(idxToRemove)=[];
            paragOrder(idxToRemove)=[];
        end
    end

end


function options=parseArgs(args)
    options.bookmarks=false;
    options.match='';
    for i=1:2:length(args)
        option=args{i};
        value=args{i+1};
        options.(option)=value;
    end
end

