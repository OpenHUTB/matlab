function hiliteSignalInList(this,dlg)





    this.unhilite(dlg,false);

    [ind,entries]=this.retrieveSelection(dlg);


    if isempty(ind)

        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        dlg.setEnabled('removeButton',0);
        return;
    end

    discontiguousInx=false;
    if(length(ind)>1)



        ind=sort(ind);
        discontiguousInx=~isempty(find((ind(2:end)-ind(1:end-1))~=1,1));
    end

    minIdx=min(ind);
    maxIdx=max(ind);

    dlg.setEnabled('removeButton',1);

    if(length(entries)==1||...
        discontiguousInx||...
        (minIdx==1&&maxIdx==length(entries)))





        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',0);
        return;
    end

    if minIdx==1

        dlg.setEnabled('upButton',0);
        dlg.setEnabled('downButton',1);
        return;
    end

    if maxIdx==length(entries)

        dlg.setEnabled('upButton',1);
        dlg.setEnabled('downButton',0);
        return;
    end


    dlg.setEnabled('upButton',1);
    dlg.setEnabled('downButton',1);

end

