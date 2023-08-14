function N=countSignals(this)





    N=0;
    for ag=1:this.nAcquireGroups
        N=N+this.AcquireGroups(ag).nSignals;
    end

end
