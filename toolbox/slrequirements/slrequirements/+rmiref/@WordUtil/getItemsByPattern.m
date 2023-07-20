function contents=getItemsByPattern(doc,pattern)


    contents=cell(0,4);
    count=0;
    utilObj=rmiref.WordUtil.docUtilObj(doc);

    spans=[];
    prev=0;
    for i=1:length(utilObj.iLevels)
        if utilObj.iLevels==0
            continue;
        end
        match=regexp(utilObj.sLabels{i},['(',pattern,')'],'tokens');
        if isempty(match)
            continue;
        end
        count=count+1;
        contents{count,1}=match{1}{1};
        contents{count,2}=i;
        if count>1
            spans(count-1)=(i-prev);%#ok<AGROW>
        end
        prev=i;
    end
    if isempty(contents)
        return;
    end



    useRecentItems=4;
    if count>useRecentItems

        spans(count)=floor(sum(spans(end-useRecentItems+1:end))/useRecentItems);
    else
        spans(count)=4;
    end

    for i=1:count
        label=contents{i,1};
        startP=contents{i,2};
        endP=startP+spans(i)-1;
        if i==count&&endP>length(utilObj.iLevels)

            endP=length(utilObj.iLevels);
        end
        myLevel=utilObj.iLevels(startP);
        includedLevels=utilObj.iLevels(startP:endP);
        if myLevel<0
            biggerHeader=find(includedLevels>0);
        else
            biggerHeader=find(includedLevels>0&includedLevels<myLevel);
        end
        if~isempty(biggerHeader)

            span=biggerHeader(1)-1;
            endP=startP+span-1;
        end
        contents{i,2}=[startP,endP];

        myRange=utilObj.hDoc.Paragraphs.Item(startP).Range;
        endRange=utilObj.hDoc.Paragraphs.Item(endP).Range;
        myRange.End=endRange.End;
        targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,label);
        if rmiref.WordUtil.isUpToDate(targetFilePath,doc)
            resultsFile=targetFilePath;
        else
            resultsFile=rmiref.WordUtil.rangeToHtml(myRange,targetFilePath,utilObj);
        end
        if~isempty(resultsFile)&&exist(resultsFile,'file')==2
            contents{i,3}=resultsFile;
            contents{i,4}=rmi.Informer.htmlFileToString(resultsFile);
        else
            contents(i,3:4)={'',''};
        end
    end

end

