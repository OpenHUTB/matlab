function newId=newRangeId(this,srcName,range)

    isNewRoot=false;
    [isMatlabFunction,mdlName]=rmisl.isSidString(srcName);
    if isMatlabFunction

        parentRoot=this.ensureRoot(mdlName);
    end
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(srcRoot)&&~isMatlabFunction

        srcRoot=this.loadIfExists(srcName);
    end
    if isempty(srcRoot)
        srcRoot=this.addRoot(srcName);
        isNewRoot=true;
    end

    t=M3I.Transaction(this.graph);

    if isNewRoot
        ids='{  }';
        starts='[  ]';
        ends='[  ]';
        if isMatlabFunction
            srcRoot.setProperty('id',srcName(length(mdlName)+1:end));
        end
    else
        ids=srcRoot.getProperty('rangeLabels');
        if isempty(ids)
            ids='{  }';
        else
            starts=srcRoot.getProperty('rangeStarts');
            ends=srcRoot.getProperty('rangeEnds');
        end
    end

    lastDay=srcRoot.getProperty('lastDay');
    major=floor(now);
    if str2num(lastDay)==major %#ok<*ST2NM>
        minor=str2num(srcRoot.getProperty('lastId'))+1;
    else
        srcRoot.setProperty('lastDay',num2str(major));
        minor=1;
    end
    srcRoot.setProperty('lastId',num2str(minor));
    newId=sprintf('%d.%d',major,minor);

    if strcmp(ids,'{  }')
        [starts,ends,ids]=rmiut.RangeUtils.convert(range(1),range(2),{newId});
    else
        [starts,ends,ids]=rmiut.RangeUtils.appendRange(starts,ends,ids,range,newId);
    end
    srcRoot.setProperty('rangeStarts',starts);
    srcRoot.setProperty('rangeEnds',ends);
    srcRoot.setProperty('rangeLabels',ids);
    cache=rmiut.escapeForXml(rmiml.getText(srcName));
    srcRoot.setProperty('cache',cache);
    if isMatlabFunction
        this.updateTextNodeData(parentRoot,srcRoot);
    end

    t.commit();
end


