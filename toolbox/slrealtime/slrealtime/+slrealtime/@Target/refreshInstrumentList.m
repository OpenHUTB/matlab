function refreshInstrumentList(this,OnStartFlag)









    oldInstList=this.instrumentList;

    this.instrumentList=[];
    this.streamingAcquireList=[];
    this.mapStreamingALToInstList=[];
    this.streamingAcquireListRefrenceCount=[];

    for i=1:length(oldInstList)
        hInst=oldInstList(i);
        if hInst.RemoveOnStop&&~OnStartFlag
            hInst.LockedByTarget=[];
            continue;
        end
        this.mergeInstrument(hInst);
    end
end
