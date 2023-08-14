function[newStarts,newEnds,remainingIds,lostIds]=remapRanges(contents,cached,starts,ends,ids)








    if ischar(starts)
        doConvert=true;
        [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
    else
        doConvert=false;
        startPositions=starts;
        endPositions=ends;
        idStrings=ids;
    end
    oldRanges=numericToCell(startPositions,endPositions);
    newRanges=rmiut.RangeUtils.textRangeRemap(contents,cached,oldRanges);
    [newStartPositions,newEndPositions]=cellToNumeric(newRanges);

    if isequal(oldRanges,newRanges)

        newStartPositions=startPositions;
        newEndPositions=endPositions;
        remainingIdStrings=idStrings;
        lostIds={};
    else

        isLost=(newEndPositions==1);
        if any(isLost)
            lostIds=idStrings(isLost);
            newStartPositions(isLost)=[];
            newEndPositions(isLost)=[];
            for i=1:length(lostIds)
                disp(getString(message('Slvnv:rmigraph:LostBookmark',lostIds{i})));
            end
            remainingIdStrings=idStrings(~isLost);
        else
            lostIds={};
            remainingIdStrings=idStrings;
        end
    end

    if doConvert
        [newStarts,newEnds,remainingIds]=rmiut.RangeUtils.convert(newStartPositions,newEndPositions,remainingIdStrings);
    else
        newStarts=newStartPositions;
        newEnds=newEndPositions;
        remainingIds=remainingIdStrings;
    end
end

function result=numericToCell(startPos,endPos)
    if length(startPos)==length(endPos)
        matrix=[startPos;endPos-1];
        cellArray=num2cell(matrix',2);
        result=cellArray';
    else
        error('RangeUtils:remapRanges: Lengths should match!');
    end
end

function[startPos,endPos]=cellToNumeric(cellArray)
    matrix=cell2mat(cellArray');
    transposed=matrix';
    startPos=transposed(1,:);
    endPos=transposed(2,:)+1;
end
