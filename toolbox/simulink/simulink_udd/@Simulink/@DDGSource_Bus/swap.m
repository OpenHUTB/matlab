function swap(this,dlg,inc)




    [ind,entries]=this.retrieveSelection(dlg);

    if isempty(ind);return;end;

    if(length(ind)>1)
        ind=sort(ind);
    end

    newInd=ind+inc;
    if(newInd(1)<1)||(newInd(end)>length(entries));return;end

    if length(ind)>1
        if inc<0
            temp=entries(newInd(1));
            entries(newInd)=entries(ind);
            entries(ind(end))=temp;
        else
            temp=entries(newInd(end));
            entries(newInd)=entries(ind);
            entries(ind(1))=temp;
        end
    else
        temp=entries(newInd);
        entries(newInd)=entries(ind);
        entries(ind)=temp;
    end

    widgetName='MatchInputsString';
    if dlg.getWidgetValue(widgetName)==0
        signalsToHilite=entries(newInd);
    else
        signalsToHilite=newInd;
    end

    this.updateSelectedSignalList(dlg,entries);

    this.refresh(dlg,false);
    this.swapSignal(dlg,signalsToHilite);

    this.hiliteSignalInList(dlg);
end
