function[id,isNew]=rangeToId(this,srcName,selection,shouldCreate)




    id='';
    isNew=false;





    if length(selection)==1
        selection(2)=selection(1);
    end


    [isMatlabFunction,mdlName]=rmisl.isSidString(srcName,shouldCreate);
    if isMatlabFunction&&shouldCreate

        parentRoot=this.ensureRoot(mdlName);
    end
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if isempty(srcRoot)&&~isMatlabFunction

        srcRoot=this.loadIfExists(srcName);
    end
    if isempty(srcRoot)
        if shouldCreate

            srcRoot=this.addRoot(srcName);
            isNew=true;
        else
            return;
        end
    end

    if isNew
        ids='{  }';
        starts='[  ]';
        ends='[  ]';
    else

        ids=srcRoot.getProperty('rangeLabels');
        if isempty(ids)
            ids='{  }';
            starts='[  ]';
            ends='[  ]';
        else
            starts=srcRoot.getProperty('rangeStarts');
            ends=srcRoot.getProperty('rangeEnds');
            id=rmiut.RangeUtils.rangeToId(starts,ends,ids,selection);
        end
    end



    if isempty(id)&&shouldCreate


        selection=rmiut.RangeUtils.completeToLines(srcName,selection);
        if isempty(selection)

            return;
        end
        t=M3I.Transaction(this.graph);
        if isNew&&isMatlabFunction
            srcRoot.setProperty('id',srcName(length(mdlName)+1:end));
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
        id=sprintf('%d.%d',major,minor);
        if strcmp(ids,'{  }')
            [starts,ends,ids]=rmiut.RangeUtils.convert(selection(1),selection(2),{id});
        else
            [starts,ends,ids]=rmiut.RangeUtils.appendRange(starts,ends,ids,selection,id);
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

        rmiml.RmiMlData.getInstance.setDirty(srcRoot.url,true);

        isNew=true;
    end
end


