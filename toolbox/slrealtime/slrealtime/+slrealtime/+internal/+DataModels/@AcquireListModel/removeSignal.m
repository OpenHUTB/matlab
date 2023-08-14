function acquireIndexMap=removeSignal(this,agIndex,sIndex)








    if length(agIndex)~=1
        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
    end
    if length(sIndex)~=1
        slrealtime.internal.throw.Error('slrealtime:instrument:InvalidArg');
    end


    acquireIndexMap(this.nAcquireGroups,this.MaxGroupLength)=struct('agi',[],'si',[]);
    for agi=1:this.nAcquireGroups
        acquireGroup=this.AcquireGroups(agi);
        for si=1:acquireGroup.nSignals
            acquireIndexMap(agi,si).agi=agi;
            acquireIndexMap(agi,si).si=si;
        end
    end
    acquireIndexMap(agIndex,sIndex).agi=nan;
    acquireIndexMap(agIndex,sIndex).si=nan;



    acquireGroup=this.AcquireGroups(agIndex);
    for si=sIndex+1:acquireGroup.nSignals
        acquireIndexMap(agIndex,si).si=acquireIndexMap(agIndex,si).si-1;
    end


    this.AcquireGroups(agIndex).removeSignal(sIndex);



    if(this.AcquireGroups(agIndex).nSignals==0)

        for agi=agIndex+1:this.nAcquireGroups
            acquireGroup=this.AcquireGroups(agi);
            for si=1:acquireGroup.nSignals
                acquireIndexMap(agi,si).agi=acquireIndexMap(agi,si).agi-1;
            end
        end
        this.AcquireGroups.removeAt(agIndex);
        this.nAcquireGroups=this.nAcquireGroups-1;
    end

    this.updateMaxGroupLength();

end
