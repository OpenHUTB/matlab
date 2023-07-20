function[html,cacheFilePath]=itemToHtml(doc,itemId)




    html='';
    cacheFilePath='';


    switch itemId(1)
    case '@'
        cacheFilePath=bookmarkToHtml(doc,itemId(2:end));
    case '?'
        cacheFilePath=matchToHtml(doc,itemId(2:end));
    otherwise

        return;
    end

    if~isempty(cacheFilePath)&&exist(cacheFilePath,'file')==2
        html=rmi.Informer.htmlFileToString(cacheFilePath);
    else


        html=['<br/>','<font color="red">',getString(message('Slvnv:rmiref:WordUtil:UnableToLocate',itemId(2:end),doc))...
        ,'</font>','<br/>'];
    end

end


function resultsFile=bookmarkToHtml(doc,bookmarkName)
    targetFilePath=rmiref.WordUtil.getCacheFilePath(doc,bookmarkName);
    if rmiref.WordUtil.isUpToDate(targetFilePath,doc)
        resultsFile=targetFilePath;
    else
        hDoc=rmiref.WordUtil.activateDocument(doc);
        hBookmarks=hDoc.Bookmarks;
        match=-1;
        for i=1:hBookmarks.Count
            if strcmp(hBookmarks.Item(i).Name,bookmarkName)
                match=i;
                break;
            end
        end
        if match>0
            range=hDoc.Bookmarks.Item(match).Range;
            if range.Paragraphs.Count==1&&range.End-range.Start<300


                utilObj=rmiref.WordUtil.docUtilObj(hDoc.FullName);
                range=utilObj.expandRange(range,300);
            else
                utilObj=[];
            end
            resultsFile=rmiref.WordUtil.rangeToHtml(range,targetFilePath,utilObj);
        else
            resultsFile='';
        end
    end
end





function resultsFile=matchToHtml(docPath,searchText)



    utilObj=rmiref.WordUtil.docUtilObj(docPath);
    [paragIdx,~]=findTopmostMatch(utilObj,searchText);
    if paragIdx==0
        disp(['Failed to find "',searchText,'" in "',utilObj.sName,'"']);
        resultsFile='';
    else
        paragString=sprintf('parag%d',paragIdx);
        targetFilePath=rmiref.WordUtil.getCacheFilePath(utilObj.sName,paragString);
        if rmiref.WordUtil.isUpToDate(targetFilePath,docPath)
            resultsFile=targetFilePath;
        else
            range=utilObj.hDoc.Paragraphs.Item(paragIdx).Range;
            if range.Paragraphs.Count==1&&range.End-range.Start<300
                range=utilObj.expandRange(range,300);
            end
            resultsFile=rmiref.WordUtil.rangeToHtml(range,targetFilePath,utilObj);
        end
    end
end

function[parIdx,parText]=findTopmostMatch(utilObj,searchText)

    topItems=findTopItems(utilObj.iLevels);
    [parIdx,parText]=findMatchIn(utilObj,topItems,searchText);
end

function topItems=findTopItems(levels)
    i=0;
    topItems=[];
    while isempty(topItems)&&i<=3
        i=i+1;
        topItems=find(levels==i);
    end
end

function[matchIdx,matchText]=findMatchIn(utilObj,parIdx,searchText)
    for i=1:length(parIdx)
        parText=utilObj.getText(parIdx(i));
        if~isempty(strfind(parText,searchText))

            if isTOC(utilObj,parIdx(i))
                continue;
            else
                matchIdx=parIdx(i);
                matchText=parText;
                return;
            end
        end
    end

    for i=1:length(parIdx)
        [childIdx,~]=utilObj.getChildren(parIdx(i));
        if isempty(childIdx)
            continue;
        end
        [matchIdx,matchText]=findMatchIn(utilObj,childIdx,searchText);
        if matchIdx>0
            return;
        end
    end

    matchIdx=0;
    matchText='';
end

function yesno=isTOC(utilObj,parIdx)
    parag=utilObj.hDoc.Paragraphs.Item(parIdx);
    if parag.Range.Hyperlinks.Count~=1
        yesno=false;
    else
        link=parag.Range.Hyperlinks.Item(1);
        if link.Range.Start==parag.Range.Start
            yesno=strncmp(link.Name,'_Toc',length('_Toc'));
        else
            yesno=false;
        end
    end
end

