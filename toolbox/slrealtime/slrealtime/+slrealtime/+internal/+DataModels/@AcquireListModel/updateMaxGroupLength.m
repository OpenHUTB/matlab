function updateMaxGroupLength(this)




    this.MaxGroupLength=0;
    for ag=1:this.nAcquireGroups
        this.MaxGroupLength=max(this.MaxGroupLength,this.AcquireGroups(ag).nSignals);
    end
end
