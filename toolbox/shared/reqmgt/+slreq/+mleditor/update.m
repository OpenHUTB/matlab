function result=update(srcName,ids,startLines,endLines)




    srcName=convertStringsToChars(srcName);
    if isstring(ids)
        ids=cellstr(ids);
    end

    result='success';

    try

        if iscell(startLines)
            startLines=cell2mat(startLines);
            endLines=cell2mat(endLines);
        end


        rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
        rangeHelper.reset(srcName);

        if rmisl.isSidString(srcName)
            [mdlName,nodeID]=strtok(srcName,':');
            artifactUri=get_param(mdlName,'FileName');
        else
            artifactUri=srcName;
            nodeID='';
        end
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactUri);
        if isempty(linkSet)
            return;
        end

        textItem=linkSet.getTextItem(nodeID);
        if isempty(textItem)
            warning('rmiml.update(): unable to find TextItem with id "%s"',nodeID);
            return;
        end

        allRanges=textItem.getRanges();
        for i=1:numel(allRanges)
            oneRange=allRanges(i);
            matchIdx=find(strcmp(ids,oneRange.id));
            if isempty(matchIdx)

                oneRange.startPos=0;
                oneRange.endPos=0;
            else
                oneRange.startPos=rangeHelper.lineNumberToCharPosition(srcName,startLines(matchIdx),1);
                oneRange.endPos=rangeHelper.lineNumberToCharPosition(srcName,endLines(matchIdx),-1);
            end
        end




        textItem.content=rmiut.escapeForXml(rangeHelper.getFullText(srcName));

    catch ex
        stack=ex.stack;
        warning(ex.identifier,'%s (%s:%d)',ex.message,stack(1).file,stack(1).line);
        result=ex.message;
    end
end
