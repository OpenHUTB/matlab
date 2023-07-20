function[isModified,lostIds]=verifyTextRanges(textItem)





    isModified=false;
    lostIds={};

    editorId=textItem.getEditorId();
    if isempty(editorId)



        return;
    end

    textRanges=textItem.getRanges;
    if isempty(textRanges)
        return;
    end

    numRanges=numel(textRanges);

    isMatlabInSl=~isempty(textItem.id);


    contents=rmiml.getText(editorId);


    cached=rmiut.unescapeFromXml(textItem.content);

    if strcmp(contents,cached)
        return;
    end

    if isempty(cached)


        textItem.content=contents;
        return;
    end


    if isMatlabInSl
        mdlName=strtok(editorId,':');
        disp(getString(message('Slvnv:rmigraph:AnalyzingStaleChild',textItem.id,mdlName)));
    else
        disp(getString(message('Slvnv:rmigraph:AnalyzingStale',editorId)));
    end


    starts=zeros(1,numRanges);
    ends=zeros(1,numRanges);
    ids=cell(1,numRanges);
    for i=1:numRanges
        oneRange=textRanges(i);
        starts(i)=oneRange.startPos;
        ends(i)=oneRange.endPos;
        ids{i}=oneRange.id;
    end


    [newStarts,newEnds,remainingIds,lostIds]=rmiut.RangeUtils.remapRanges(contents,cached,starts,ends,ids);



    isModified=~isequal(newStarts,starts)||~isequal(newEnds,ends);

    if isModified

        for i=1:numRanges
            oneRange=textRanges(i);
            id=oneRange.id;
            if any(strcmp(lostIds,id))
                oneRange.startPos=0;
                oneRange.endPos=0;
            else
                idx=find(strcmp(remainingIds,id));
                oneRange.startPos=newStarts(idx);
                oneRange.endPos=newEnds(idx);
            end
        end
        textItem.content=contents;


    end

end

