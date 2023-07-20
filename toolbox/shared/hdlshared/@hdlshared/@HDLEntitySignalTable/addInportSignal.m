function addInportSignal(this,indices)










    if indices==0

    else
        newIndices=setdiff(indices,this.InportList);
        if~isempty(newIndices)
            this.Inportlist=[this.InportList,newIndices];
        end
    end
