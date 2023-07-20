function add(this,dlg)





    [ind,entries]=this.retrieveSelection(dlg);

    if isempty(ind)
        newind=length(entries)+1;
    elseif(length(ind)>1)
        newind=ind(end)+1;
    else
        newind=ind+1;
    end

    temp=entries(newind:end);
    newentries=entries(1:newind-1);


    continueSearch=true;
    signalMap=containers.Map(entries,ones(length(entries),1));
    inc=1;
    while continueSearch
        newName=['newsignal',num2str(inc)];
        nameFound=signalMap.isKey(newName);
        if nameFound
            continueSearch=true;
        else
            continueSearch=false;
        end
        inc=inc+1;
    end

    newentries{end+1}=newName;
    for i=1:length(temp)
        newentries{end+1}=temp{i};
    end

    widgetName='MatchInputsString';
    if dlg.getWidgetValue(widgetName)==0
        entriesToHilite=newentries(newind);
    else
        entriesToHilite=newind;
    end

    this.updateSelectedSignalList(dlg,newentries);

    this.refresh(dlg,false);

    this.addSignal(dlg,entriesToHilite);

    this.hiliteSignalInList(dlg);

end
