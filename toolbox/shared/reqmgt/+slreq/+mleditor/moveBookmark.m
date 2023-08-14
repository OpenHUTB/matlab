function status=moveBookmark(srcName,id,startLine,endLine)










    srcName=convertStringsToChars(srcName);

    if nargin<2
        rangeAdjusterDialog(srcName);
        return;
    end

    id=convertStringsToChars(id);

    status='success';

    if nargin<4

        rangeAdjusterDialog(srcName,id);
        return;
    end

    try
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


        range=textItem.getRange(id);
        rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
        rangeHelper.reset(srcName);
        range.startPos=rangeHelper.lineNumberToCharPosition(srcName,startLine,1);
        range.endPos=rangeHelper.lineNumberToCharPosition(srcName,endLine,-1);


        textItem.content=rmiut.escapeForXml(rangeHelper.getFullText(srcName));


        rmiml.notifyEditor(srcName,['~',id]);

    catch ex
        stack=ex.stack;
        warning(ex.identifier,'%s (%s:%d)',ex.message,stack(1).file,stack(1).line);
        status=ex.message;
    end
end



function rangeAdjusterDialog(srcName,id)

    persistent knownDialogs

    if isempty(knownDialogs)
        makeNewMap();
    end
    function makeNewMap()
        knownDialogs=containers.Map('KeyType','char','ValueType','Any');
        knownDialogs('')='';
    end


    if nargin==1
        if isempty(srcName)

            closeAll();
        else

            closeMatching(srcName);
        end
        return;
    end
    function closeAll()
        allDialogs=values(knownDialogs);
        for i=numel(allDialogs):-1:1
            if~isempty(allDialogs{i})
                try
                    allDialogs{i}.delete();
                catch
                end
            end
        end
        makeNewMap();
    end
    function closeMatching(srcName)
        allKeys=keys(knownDialogs);
        for i=1:numel(allKeys)
            if startsWith(allKeys{i},srcName)
                dlg=knownDialogs(allKeys{i});
                try
                    dlg.delete();
                catch
                end
                knownDialogs.remove(allKeys{i});
            end
        end
    end


    key=[srcName,id];
    makeNewDlg=true;
    if isKey(knownDialogs,key)
        dlg=knownDialogs(key);
        try
            dlg.show();
            makeNewDlg=false;
        catch
        end
    end
    if makeNewDlg
        dlgSrc=slreq.mleditor.DlgBkmrkRange(srcName,id);
        knownDialogs(key)=DAStudio.Dialog(dlgSrc);
    end
end
