function contents=getContentByParagIdx(doc,cacheLabel,paragIdx)


    contents=cell(0,4);
    contents{1}=cacheLabel;
    contents{2}=paragIdx;

    utilObj=rmiref.WordUtil.docUtilObj(doc);

    startP=paragIdx(1);
    endP=paragIdx(end);
    myRange=utilObj.hDoc.Paragraphs.Item(startP).Range;
    endRange=utilObj.hDoc.Paragraphs.Item(endP).Range;
    myRange.End=endRange.End;
    targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,cacheLabel);
    if rmiref.WordUtil.isUpToDate(targetFilePath,doc)
        resultsFile=targetFilePath;
    else
        resultsFile=rmiref.WordUtil.rangeToHtml(myRange,targetFilePath,utilObj);
    end
    if~isempty(resultsFile)&&exist(resultsFile,'file')==2
        contents{3}=resultsFile;
        contents{4}=rmi.Informer.htmlFileToString(resultsFile);
    else
        contents(3:4)={'',''};
    end
end
