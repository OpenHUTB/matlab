function agi=getAcquireGroupIndex(this,tid,decimation)







    agi=-1;
    for ag=1:this.nAcquireGroups
        if tid==this.AcquireGroups(ag).tid&&decimation==this.AcquireGroups(ag).decimation
            agi=ag;
            return
        end
    end
end
