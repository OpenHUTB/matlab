function addResetSignal(this,indices)










    if indices==0

    else
        newIndices=setdiff(indices,this.ResetList);
        if~isempty(newIndices)
            this.Resetlist=[this.ResetList,newIndices];
        end
    end
