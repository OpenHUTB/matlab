function select(this,dlg)





    name=this.getSelectedSignalString();


    if~isempty(this.mOutputSignals)

        [ind,~]=this.retrieveSelection(dlg);
        if isempty(ind)

            this.mOutputSignals=[this.mOutputSignals,',',this.cellArr2Str(name)];
        else
            entries=this.str2CellArr(this.mOutputSignals,',');
            lastIdx=max(ind);
            if(lastIdx==length(entries))

                this.mOutputSignals=[this.mOutputSignals,',',this.cellArr2Str(name)];
            else

                newEntries={entries{1:lastIdx},name{1:end},entries{lastIdx+1:end}};
                this.mOutputSignals=this.cellArr2Str(newEntries);
            end
        end
    else
        this.mOutputSignals=this.cellArr2Str(name);
    end

    entries=this.str2CellArr(this.mOutputSignals,',');
    dlg.setUserData('outputsList',entries);
    dlg.enableApplyButton(true)
    refresh(this,dlg,false);

end

