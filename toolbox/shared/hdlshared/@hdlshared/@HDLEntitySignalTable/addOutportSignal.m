function addOutportSignal(this,indices)










    if indices==0

    else
        newIndices=setdiff(indices,this.OutportList);
        if~isempty(newIndices)
            this.Outportlist=[this.OutportList,newIndices];
        end
    end
