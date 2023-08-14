function switchModelName(this,newModelName)





    modelIndex=strmatch(newModelName,this.modelList,'exact');
    if(~isempty(modelIndex))
        this.currentTabIndex=modelIndex-1;
        this.modelName=newModelName;
        if(~isempty(this.legendDlg))
            this.legendDlg.resetSize
            this.legendDlg.refresh
        end
    end

end



