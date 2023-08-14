function select(this,dlg)





    name=this.getSelectedSignalString();


    if~isempty(this.mAssignedSignals)
        [ind,~]=this.retrieveSelection(dlg);
        if isempty(ind)
            this.mAssignedSignals=[this.mAssignedSignals,',',this.cellArr2Str(name)];
        else
            entries=this.str2CellArr(this.mAssignedSignals,',');
            lastIdx=max(ind);
            if(lastIdx==length(entries))
                this.mAssignedSignals=[this.mAssignedSignals,',',this.cellArr2Str(name)];
            else
                newEntries={entries{1:lastIdx},name{1:end},entries{lastIdx+1:end}};
                this.mAssignedSignals=this.cellArr2Str(newEntries);
            end
        end
    else
        this.mAssignedSignals=this.cellArr2Str(name);
    end
    entries=this.str2CellArr(this.mAssignedSignals,',');
    dlg.setUserData('assignedList',entries);
    dlg.enableApplyButton(true)
    refresh(this,dlg,false);

end

