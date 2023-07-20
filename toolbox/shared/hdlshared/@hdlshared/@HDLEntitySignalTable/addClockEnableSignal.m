function addClockEnableSignal(this,indices)










    if indices==0

    else
        newIndices=setdiff(indices,this.ClockEnableList);
        if~isempty(newIndices)
            this.ClockEnablelist=[this.ClockEnableList,newIndices];
        end
    end


