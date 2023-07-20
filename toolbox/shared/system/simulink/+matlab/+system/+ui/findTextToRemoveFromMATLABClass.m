function textPostRemoval=findTextToRemoveFromMATLABClass(fcnName,docText)





    textPostRemoval='';
    fcnIdx=strfind(docText,fcnName);
    endTrackingArray={};
    endTrackingArrayLen=0;
    if~isempty(fcnIdx)
        endTrackingArrayLen=1;
        endTrackingArray{end+1}='function';
        docArray=strsplit(docText,'\n');
        funcStartIdx=[];
        funcEndIdx=[];
        for docArrayIdx=1:length(docArray)
            currLine=docArray{docArrayIdx};
            if strfind(currLine,'%')==1
                continue;
            else
                if~isempty(strfind(currLine,'%'))
                    currLine=currLine(1:strfind(currLine,'%')-1);
                end
                if isempty(funcStartIdx)
                    if~isempty(strfind(currLine,fcnName))
                        funcStartIdx=docArrayIdx;


                        funcStartIdx=matlab.system.ui.checkForCommentsAssociatedToFunction(funcStartIdx,docArray);
                    end
                    if isempty(funcStartIdx)
                        continue;
                    end
                else
                    allEndTerminatedBlocks={'if','switch','for','while','parfor','try'};
                    words=regexp(currLine,'\w+','match');
                    for wordIdx=1:length(words)
                        if any(strcmp(words{wordIdx},allEndTerminatedBlocks))
                            endTrackingArrayLen=endTrackingArrayLen+1;
                            endTrackingArray{end+1}=words{wordIdx};
                        elseif any(strcmp(words{wordIdx},'end'))
                            endTrackingArrayLen=endTrackingArrayLen-1;
                            if~endTrackingArrayLen
                                funcEndIdx=docArrayIdx;
                                break;
                            end
                        end
                    end
                    if~isempty(funcEndIdx)
                        break;
                    end
                end
            end

        end
        d=docArray([1:funcStartIdx-1,funcEndIdx+1:end]);
        textPostRemoval=strjoin(d,'\n');
    end
    if isempty(textPostRemoval)
        textPostRemoval=docText;
    end
end