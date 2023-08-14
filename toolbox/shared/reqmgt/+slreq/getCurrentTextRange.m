



function range=getCurrentTextRange(host)
    range=[];

    if nargin>0&&~isempty(host)
        host=convertStringsToChars(host);
        [rangeId,editorId]=getCurrentRangeIdInSLEditor(host);
        [mName,sid]=strtok(editorId,':');
        artifactFile=get_param(mName,'Filename');
        rangeId=slreq.utils.getLongIdFromShortId(sid,rangeId);
    else
        [rangeId,artifactFile]=getCurrentRangeIdInMLEditor();
    end

    if isempty(rangeId)||any(rangeId=='-')


        return;
    end

    dataLinkSet=slreq.utils.getLinkSet(artifactFile);
    dataRange=dataLinkSet.getTextRangeById(rangeId);
    if~isempty(dataRange)
        range=slreq.TextRange(dataRange);
    end

end

function[id,fPath]=getCurrentRangeIdInMLEditor()
    [fPath,selectedRange,selectedText]=mleditor.getSelection();
    if~isempty(selectedText)
        [~,id]=rmiml.getBookmark(fPath,selectedRange);
    else
        [~,id]=rmiml.getBookmark();
    end
end

function[id,host]=getCurrentRangeIdInSLEditor(host)
    id='';
    currentBlk=gcb;
    if startsWith(currentBlk,host)&&strcmp(rmisf.sfBlockType(currentBlk),'MATLAB Function')
        selectionInfo=rmisl.getSelection();
        if isfield(selectionInfo,'selectedRange')
            host=selectionInfo.srcKey;
            charRange=selectionInfo.selectedRange;
            [~,id]=rmiml.getBookmark(host,charRange);
        end
    end
end
