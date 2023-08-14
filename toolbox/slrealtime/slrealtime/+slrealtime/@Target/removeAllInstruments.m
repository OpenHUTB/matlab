function removeAllInstruments(this)





    if this.isConnected()&&this.isRunning()&&~isempty(this.streamingAcquireList)
        ALremoved=this.streamingAcquireList;
        ALadded=slrealtime.internal.instrument.AcquireList(ALremoved.AcquireListModel.mldatxfile);


        if(ALadded.AcquireListModel.MaxGroupLength>0)||(ALremoved.AcquireListModel.MaxGroupLength>0)
            this.xcp.addToRemoveFromMeasurement(ALadded.AcquireListModel,ALremoved.AcquireListModel,this.ModelStatus.ExecTime);

            if~isdeployed

                Simulink.sdi.loadSDIEvent();
            end
        end
    end

    for i=1:length(this.instrumentList)
        this.instrumentList(i).LockedByTarget=[];
    end
    this.instrumentList=[];
    this.streamingAcquireList=[];

    if this.Recording
        this.stopStreaming();
    end
end
