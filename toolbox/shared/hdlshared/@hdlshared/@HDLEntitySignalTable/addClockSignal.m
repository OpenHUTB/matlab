function addClockSignal(this,indices)










    if indices==0

    else
        newIndices=setdiff(indices,this.ClockList);
        if~isempty(newIndices)
            this.clocklist=[this.ClockList,newIndices];
        end
    end
