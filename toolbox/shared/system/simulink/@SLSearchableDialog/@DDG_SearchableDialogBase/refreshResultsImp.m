function refreshResultsImp(this,dlg)





    this.DialogData.NumItemAllowed=this.DialogData.DefaultNumItem;

    if isempty(this.DialogData.FilterExp)
        this.DialogData.ShowList=this.DialogData.ListVisible;
        this.DialogData.ShowListIndex=find(this.DialogData.ShowList);
    else
        if this.DialogData.RegexpSupport==true
            FilterExp=this.DialogData.FilterExp;
        else

            FilterExp=regexprep(this.DialogData.FilterExp,'(\\|\^|\$|\.|\||\?|\*|\+|\(|\)|\[|\{)','\\$1');
        end

        startIndexName=this.DialogData.hSearchFcn(this.DialogData.ListParams,FilterExp);
        startIndexPrompt=this.DialogData.hSearchFcn(this.DialogData.ListPrompt,FilterExp);
        this.DialogData.ShowList=((~cellfun(@isempty,startIndexName))|...
        (~cellfun(@isempty,startIndexPrompt)))&this.DialogData.ListVisible;
        this.DialogData.ShowListIndex=find(this.DialogData.ShowList);
    end


    this.DialogData.NumItemTotal=sum(this.DialogData.ShowList);

    dlg.refresh();

end
