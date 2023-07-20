function addInstrument(this,hInst,updateWhileRunning)













    if(nargin<3),updateWhileRunning=true;end

    if~isempty(hInst.LockedByTarget)
        slrealtime.internal.throw.Error('slrealtime:target:addInstAlreadyLocked',...
        this.TargetSettings.name,hInst.LockedByTarget.TargetSettings.name);
    end
    hInst.LockedByTarget=this;

    if~this.isConnected()


        this.forceRefresh=true;
        this.instrumentList=[this.instrumentList;hInst];
    elseif slrealtime.internal.feature('KeepAppDesUIsActiveWhenNotRecording')&&hInst.StreamingOnly&&~this.Recording



        hInst.LockedByTarget=[];
        this.RemovedInstruments=[this.RemovedInstruments;hInst];
    else
        [isLoaded,appName]=this.isLoaded();
        if~isLoaded



            this.forceRefresh=true;
            this.instrumentList=[this.instrumentList;hInst];
        else





            isRunning=this.isRunning();
            if isRunning

                if this.Recording
                    this.xcp.pauseMeasurement();
                end
                Simulink.AsyncQueue.Queue.flushStreamingQueues(...
                this.ModelStatus.ModelName,this.TargetSettings.name);
                pause(1);
            end




            needsToBeValidated=true;
            if~isempty(hInst.Application)



                appName=this.tc.ModelProperties.Application;
                hostUUID=hInst.Checksum;
                targetUUID=this.getUUIDFromTarget(appName);

                if strcmp(hostUUID,targetUUID)



                    needsToBeValidated=false;
                end
            end
            if needsToBeValidated
                hInst.validate(this.getAppFile(appName));
            end



            hInst.registerObserversWithTarget(this);




            if isempty(this.streamingAcquireList)
                oldAcquireList=this.streamingAcquireList;
            else
                oldAcquireList=this.streamingAcquireList.duplicate();
            end
            this.mergeInstrument(hInst);



            if isRunning&&updateWhileRunning
                if isempty(this.SDIRunId)


                    this.xcpStartMeasurement()
                else



                    if isempty(oldAcquireList)

                        ALadded=this.streamingAcquireList;
                        ALremoved=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);
                        previously_added=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);

                    elseif isempty(this.streamingAcquireList)

                        ALadded=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);
                        ALremoved=oldAcquireList;
                        previously_added=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);

                    else

                        [ALadded,~]=slrealtime.internal.instrument.AcquireList.findDifference(oldAcquireList,this.streamingAcquireList);
                        ALremoved=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);





























                        [~,previously_added]=slrealtime.internal.instrument.AcquireList.findDifference(hInst.AcquireList,ALadded.duplicate());
                    end





                    if ALadded.AcquireListModel.MaxGroupLength>0||ALremoved.AcquireListModel.MaxGroupLength>0||previously_added.AcquireListModel.MaxGroupLength>0
                        if ALadded.AcquireListModel.MaxGroupLength>0||ALremoved.AcquireListModel.MaxGroupLength>0
                            this.xcp.addToRemoveFromMeasurement(ALadded.AcquireListModel,ALremoved.AcquireListModel,this.ModelStatus.ExecTime);
                        end

                        if previously_added.AcquireListModel.MaxGroupLength>0
                            rem=slrealtime.internal.instrument.AcquireList(this.streamingAcquireList.AcquireListModel.mldatxfile);
                            this.xcp.addToRemoveFromMeasurement(previously_added.AcquireListModel,rem.AcquireListModel,this.ModelStatus.ExecTime);
                        end

                        Simulink.sdi.loadSDIEvent();
                    else

                        if this.Recording
                            this.xcp.resumeMeasurement();
                        end
                    end
                end
            end
        end
    end
end
