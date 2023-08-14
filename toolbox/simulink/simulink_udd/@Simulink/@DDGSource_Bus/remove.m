function remove(this,dlg)





    [ind,entries]=this.retrieveSelection(dlg);

    if~isempty(ind)&&~isempty(entries)
        entries(ind)=[];

        this.updateSelectedSignalList(dlg,entries);

        this.refresh(dlg,false);

        this.remove_hook(dlg);

        this.hiliteSignalInList(dlg);
    end
end

