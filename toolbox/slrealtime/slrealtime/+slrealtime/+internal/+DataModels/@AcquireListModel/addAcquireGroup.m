function agi=addAcquireGroup(this,tid,discreteInterval,sampleTimeString,decimation)







    m=mf.zero.getModel(this);

    aG=slrealtime.internal.DataModels.AcquireGroup(m);
    aG.tid=tid;
    aG.discreteInterval=discreteInterval;
    aG.sampleTimeString=sampleTimeString;
    aG.decimation=decimation;

    this.AcquireGroups.add(aG);
    this.nAcquireGroups=length(toArray(this.AcquireGroups));
    agi=this.nAcquireGroups;

end
