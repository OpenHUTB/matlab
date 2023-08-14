function newRanges=textRangeRemap(newCode,oldCode,ranges)










    oldIdx2newIdx=modified_str_map(newCode,oldCode);

    rangeCnt=numel(ranges);
    newRanges=cell(1,rangeCnt);
    oldTotalChars=length(oldCode);

    for idx=1:rangeCnt

        oldRange=ranges{idx};


        if oldRange(2)<=0

            newRanges{idx}=oldRange;
            continue;
        end


        if oldRange(2)>oldTotalChars
            warning(message('Slvnv:rmiml:InvalidRange',num2str(idx)));
            oldRange(2)=oldTotalChars;
            if oldRange(1)>oldTotalChars
                oldRange(1)=oldTotalChars;
            end
        end

        newRange=oldIdx2newIdx(oldRange);


        if any(newRange==0)


            subIndxMap=oldIdx2newIdx((oldRange(1)):(oldRange(2)));
            validMapIdx=find(subIndxMap);

            if isempty(validMapIdx)
                if rmiml.persistentBookmarks()

                    isSurvivingPosition=find(oldIdx2newIdx(1:oldRange(1)));
                    if isempty(isSurvivingPosition)
                        newRange=[1,1];
                    else
                        nearestSurvivingPosition=oldIdx2newIdx(isSurvivingPosition(end));
                        newRange=[nearestSurvivingPosition,nearestSurvivingPosition];
                    end
                else

                    newRange=[0,0];
                end
            else

                newRange=[min(subIndxMap(validMapIdx)),max(subIndxMap(validMapIdx))];
            end

        end
        newRanges{idx}=newRange;
    end

end

function oldIdx2newIdx=modified_str_map(newCode,oldCode)












    oldLineStartIdx=[1,find(oldCode==sprintf('\n'))+1];
    newLineStartIdx=[1,find(newCode==sprintf('\n'))+1];
    lastOldLine=numel(oldLineStartIdx)-1;


    oldLines=textscan(oldCode,'%s','delimiter',char(10),'whitespace','');
    oldLines=oldLines{1};

    newLines=textscan(newCode,'%s','delimiter',char(10),'whitespace','');
    newLines=newLines{1};


    [lineIdxOld,lineIdxNew]=diffcode(oldLines,newLines);


    checkLinesIdx=lineIdxOld>0&lineIdxNew>0;

    checkOldLines=oldLines(lineIdxOld(checkLinesIdx));
    checkNewLines=newLines(lineIdxNew(checkLinesIdx));
    checkLinesSame=strcmp(checkOldLines,checkNewLines);

    linesEqual=false(1,numel(lineIdxOld));
    linesEqual(checkLinesIdx)=checkLinesSame;


    oldIdx2newIdx=zeros(1,numel(oldCode));




    nextOldLine=1;
    lastProcessIdx=0;
    processIdx=find(~linesEqual);

    for idx=processIdx
        oldLineIdx=lineIdxOld(idx);
        newLineIdx=lineIdxNew(idx);

        if oldLineIdx>0
            if oldLineIdx>nextOldLine


                bkStartO=oldLineStartIdx(nextOldLine);
                bkEndO=oldLineStartIdx(oldLineIdx)-1;



                prevNewIdx=lineIdxNew(idx-1);
                assert(prevNewIdx>0)

                bkEndN=newLineStartIdx(prevNewIdx+1)-1;
                bkStartN=bkEndN-(bkEndO-bkStartO);

                oldIdx2newIdx(bkStartO:bkEndO)=bkStartN:bkEndN;
            end

            nextOldLine=oldLineIdx+1;

            if newLineIdx>0


                offsetOld=oldLineStartIdx(oldLineIdx)-1;
                offsetNew=newLineStartIdx(newLineIdx)-1;

                oldLine=oldLines{oldLineIdx};
                oldCnt=numel(oldLine);

                newLine=newLines{newLineIdx};


                lineMapping=map_single_line(oldLine,newLine);

                lineMapping(lineMapping~=0)=lineMapping(lineMapping~=0)+offsetNew;
                oldIdx2newIdx(offsetOld+(1:oldCnt))=lineMapping;
            else






            end
        else





            if(idx>(lastProcessIdx+1))
                bkStartO=oldLineStartIdx(lineIdxOld(lastProcessIdx+1));
                bkLastOldLine=lineIdxOld(idx-1);
                bkEndO=oldLineStartIdx(bkLastOldLine+1)-1;

                nextOldLine=bkLastOldLine+1;

                bkStartN=newLineStartIdx(lineIdxNew(lastProcessIdx+1));
                bkEndN=newLineStartIdx(newLineIdx)-1;

                oldIdx2newIdx(bkStartO:bkEndO)=bkStartN:bkEndN;
            end
        end

        lastProcessIdx=idx;
    end


    if isempty(processIdx)
        firstUnprocessedIdx=1;
    else
        firstUnprocessedIdx=processIdx(end)+1;
    end


    if firstUnprocessedIdx<numel(lineIdxOld)&&lineIdxOld(firstUnprocessedIdx)<=lastOldLine
        oldLineIdx=lineIdxOld(firstUnprocessedIdx);
        newLineIdx=lineIdxNew(firstUnprocessedIdx);



        bkStartO=oldLineStartIdx(oldLineIdx);
        bkEndO=numel(oldCode);


        bkStartN=newLineStartIdx(newLineIdx);
        bkEndN=bkStartN+(bkEndO-bkStartO);

        oldIdx2newIdx(bkStartO:bkEndO)=bkStartN:bkEndN;
    end


    function lineMapping=map_single_line(oldLine,newLine)




        lineMapping=zeros(1,numel(oldLine));

        [oldIdx,newIdx]=diffcode(oldLine,newLine);


        checkIdx=oldIdx>0&newIdx>0;

        oldCmpIdx=oldIdx(checkIdx);
        newCmpIdx=newIdx(checkIdx);

        oldCompStr=oldLine(oldCmpIdx);
        newCompStr=newLine(newCmpIdx);
        match=oldCompStr==newCompStr;

        lineMapping(oldCmpIdx(match))=newCmpIdx(match);
    end
end

