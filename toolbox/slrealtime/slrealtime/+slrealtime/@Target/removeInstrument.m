function removeInstrument(this,hInst)







    if isempty(hInst)||...
        (~any(this.instrumentList==hInst)&&~any(this.RemovedInstruments==hInst))
        slrealtime.internal.throw.Error('slrealtime:target:removeInstInvalidArg',...
        this.TargetSettings.name);
    end

    hInst.LockedByTarget=[];

    if slrealtime.internal.feature('KeepAppDesUIsActiveWhenNotRecording')&&~this.Recording&&~isempty(this.RemovedInstruments)
        idxs=(this.RemovedInstruments==hInst);
        if any(idxs)



            this.RemovedInstruments=this.RemovedInstruments(~idxs);
            return;
        end
    end

    if this.isConnected()&&this.isRunning()

        if this.Recording
            this.xcp.pauseMeasurement();
        end

        Simulink.AsyncQueue.Queue.flushStreamingQueues(...
        this.ModelStatus.ModelName,this.TargetSettings.name);
        pause(1);
    end

    acquireList=this.streamingAcquireList;
    map=this.mapStreamingALToInstList;
    ref=this.streamingAcquireListRefrenceCount;

    if length(this.instrumentList)==1



        hInstdummy=slrealtime.Instrument(hInst.Application);
        hInstdummy.RemoveOnStop=true;
        this.instrumentList=hInstdummy;

        ALremoved=hInst.AcquireList;

        if isempty(ALremoved)||isempty(this.streamingAcquireList)
            return;
        end




        for agi=1:acquireList.AcquireListModel.nAcquireGroups
            for si=1:acquireList.AcquireListModel.AcquireGroups(agi).nSignals
                map{agi,si}=[-1,agi,si];
                ref(agi,si)=0;
            end
        end

    else



        hInstdummy=slrealtime.Instrument(hInst.Application);
        hInstdummy.RemoveOnStop=true;
        hInstIndex=find(this.instrumentList==hInst);
        this.instrumentList(hInstIndex)=hInstdummy;

        ALremoved=hInst.AcquireList.duplicate();

        if isempty(ALremoved)||isempty(this.streamingAcquireList)
            return;
        end



        acquireList=this.streamingAcquireList;
        for agi=1:acquireList.AcquireListModel.nAcquireGroups
            for si=1:acquireList.AcquireListModel.AcquireGroups(agi).nSignals
                mappedInsts=map{agi,si}(:,1);
                for iHI=1:length(mappedInsts)
                    if mappedInsts(iHI)==hInstIndex


                        map{agi,si}(iHI,1)=-1;
                        ref(agi,si)=ref(agi,si)-1;
                        assert(ref(agi,si)==0);
                    end
                end
            end
        end
    end

    this.streamingAcquireList=acquireList;
    this.mapStreamingALToInstList=map;
    this.streamingAcquireListRefrenceCount=ref;

    if this.isConnected()&&this.isRunning()


        ALadded=slrealtime.internal.instrument.AcquireList(ALremoved.AcquireListModel.mldatxfile);



        if ALremoved.AcquireListModel.MaxGroupLength>0
            this.xcp.addToRemoveFromMeasurement(ALadded.AcquireListModel,ALremoved.AcquireListModel,this.ModelStatus.ExecTime);
        else


            if this.Recording
                this.xcp.resumeMeasurement();
            end
        end
    end
end
