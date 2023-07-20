function result=update(srcName,ids,starts,ends)




    srcName=convertStringsToChars(srcName);
    if isstring(ids)
        ids=cellstr(ids);
    end

    try
        result='success';

        if iscell(starts)
            starts=cell2mat(starts);
            ends=cell2mat(ends);
        end

        if rmisl.isSidString(srcName)
            [mdlName,nodeID]=strtok(srcName,':');
            srcName=get_param(mdlName,'FileName');
        else
            nodeID='';
        end
        linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcName);
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
                oneRange.startPos=starts(matchIdx);
                oneRange.endPos=ends(matchIdx);
            end
        end




        textItem.content=rmiut.escapeForXml(rmiml.getText(srcName));

    catch ex
        warning(ex.identifier,'%s',ex.message);
        result=ex.message;
    end
end
