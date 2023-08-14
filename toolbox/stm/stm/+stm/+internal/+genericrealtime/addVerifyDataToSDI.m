function addVerifyDataToSDI(filename,runId,fwarnIfMissedData,expectedSampleTime)

    if nargin<2
        runId=0;
    end
    if nargin<3
        fwarnIfMissedData=false;
    end
    if nargin<4
        expectedSampleTime=100;
    end



    d=dir(filename);
    filesize=d.bytes;

    fid=fopen(filename);




























    metaDataMarker=false;
    i=1;

    while(~metaDataMarker&&ftell(fid)<filesize)
        blkId=fread(fid,1,'int32');
        verifyId=fread(fid,1,'int32');
        if(blkId==-3&&verifyId==-3)
            value=fread(fid,1,'int32');
            time=fread(fid,1,'double');
            assert(value==-3&&time==-3,'Corrupted marker');
            metaDataMarker=true;
        else
            verifyMetaData(i).blkId=blkId;%#ok
            verifyMetaData(i).verifyId=verifyId;%#ok
            blkPathLength=fread(fid,1,'int32');
            verifyMetaData(i).blkPath=deblank(fread(fid,blkPathLength,'*char')');%#ok
            sfPathLength=fread(fid,1,'int32');
            verifyMetaData(i).sfPath=deblank(fread(fid,sfPathLength,'*char')');%#ok
            mdlRefPathLength=fread(fid,1,'int32');
            verifyMetaData(i).mdlRefPath=deblank(fread(fid,mdlRefPathLength,'*char')');%#ok
            verifyMetaData(i).ssid=fread(fid,1,'int32');%#ok
            verifyMetaData(i).lStart=fread(fid,1,'int32');%#ok
            verifyMetaData(i).lEnd=fread(fid,1,'int32');%#ok
            msgIdLength=fread(fid,1,'int32');
            verifyMetaData(i).msgId=deblank(fread(fid,msgIdLength,'*char')');%#ok
            i=i+1;
        end
    end

    offset=ftell(fid);



    blockIds=fread(fid,inf,'int32=>int32',16);

    fseek(fid,(offset+4),-1);

    verifyIds=fread(fid,inf,'int32=>int32',16);

    fseek(fid,(offset+8),-1);

    values=fread(fid,inf,'int32=>int32',16);

    fseek(fid,(offset+12),-1);

    time=fread(fid,inf,'double=>double',12);
    fclose(fid);


    blkIdAndVerifyId=unique([blockIds,verifyIds],'rows');

    [hasStickyBuffer,stickyBufferIndex]=ismember([-2,-2],blkIdAndVerifyId,'rows');

    if(hasStickyBuffer)
        blkIdAndVerifyId(stickyBufferIndex,:)=[];
    end


    [hasEndMarker,endMarkerIndex]=ismember([-1,-1],blkIdAndVerifyId,'rows');

    if(hasEndMarker)
        blkIdAndVerifyId(endMarkerIndex,:)=[];
    else
        warning(message('stm:realtime:MissingVerifyFinalResult'));
    end

    verifyCount=size(blkIdAndVerifyId,1);

    signalNames=cell(1,verifyCount);
    signals=cell(1,verifyCount);
    signalFinalValues=cell(1,verifyCount);
    signalSSID=cell(1,verifyCount);
    signalSubPath=cell(1,verifyCount);


    toRemove=[];
    for i=1:verifyCount


        if(blkIdAndVerifyId(i,2)<0)




            toRemove=[toRemove,i];%#ok
            continue;
        end



        indexes=blockIds==blkIdAndVerifyId(i,1)&verifyIds==blkIdAndVerifyId(i,2);
        t=time(indexes);
        v=slTestResult(values(indexes));
        StickyBitTime=[];
        if hasStickyBuffer
            if hasEndMarker
                signalFinalValues{i}=v(end);
                StickyBitTime=t(end);
            else

                signalFinalValues{i}=slTestResult.Fail;
            end
            v(end)=[];
            t(end)=[];
        end

        if fwarnIfMissedData
            fwarnIfMissedData=~(stm.internal.genericrealtime.warnIfMissedData(t,expectedSampleTime));
        end

        if(stm.internal.genericrealtime.FollowProgress.verboseLevel==2)
            if~isempty(v)
                assert(signalFinalValues{i}>=max(v),'Verify final result is less than maximum in trace');
            end
        end

        ts=timeseries(v,t);
        if(~isempty(StickyBitTime)&&isempty(ts.getsampleusingtime(StickyBitTime).Data))

            if signalFinalValues{i}>=0

                ts=ts.addsample('Time',StickyBitTime,'Data',signalFinalValues{i});
            end
        end
        if(isempty(ts.Data))





            ts=ts.addsample('Time',0,'Data',nan);
        end

        ts=ts.setinterpmethod('zoh');
        currentMetadataIdx=find([verifyMetaData.blkId]==blkIdAndVerifyId(i,1)&[verifyMetaData.verifyId]==blkIdAndVerifyId(i,2),1);
        ts.Name=buildSignalName(verifyMetaData(currentMetadataIdx).blkPath,verifyMetaData(currentMetadataIdx).sfPath,verifyMetaData(currentMetadataIdx).msgId);
        signalBlockPath=verifyMetaData(currentMetadataIdx).blkPath;

        if(isempty(signalBlockPath))
            signalBlockPath=verifyMetaData(currentMetadataIdx).msgId;
        end
        signalSubPath{i}=verifyMetaData(currentMetadataIdx).sfPath;
        signalSSID{i}=verifyMetaData(currentMetadataIdx).ssid;
        signalNames{i}=ts.Name;
        sig=Simulink.SimulationData.Signal;
        sig.Name=ts.Name;
        sig.BlockPath=signalBlockPath;
        sig.Values=ts;
        signals{i}=sig;
    end


    if~isempty(toRemove)
        signalNames(toRemove)=[];
        signals(toRemove)=[];
        signalFinalValues(toRemove)=[];
        signalSSID(toRemove)=[];
        signalSubPath(toRemove)=[];
    end



    Simulink.sdi.internal.safeTransaction(@addSignals,runId,signalNames,signals,signalFinalValues,signalSSID,signalSubPath);
end

function addSignals(runId,signalNames,signals,signalFinalValues,signalSSID,signalSubPath)


    if runId==0
        runId=Simulink.sdi.createRun('VerifyResultsFromSLRT');
    end
    signalIDs=Simulink.sdi.addToRun(runId,'namevalue',signalNames,signals);

    sdiEngine=Simulink.sdi.Instance.engine;

    for i=1:length(signalIDs)
        sdiEngine.setMetaDataV2(signalIDs(i),'IsAssessment',int32(1));
        sdiEngine.setMetaDataV2(signalIDs(i),'AssessmentResult',int32(signalFinalValues{i}));



        if(int32(signalSSID{i})~=0)
            sdiEngine.setMetaDataV2(signalIDs(i),'SSIDNumber',int32(signalSSID{i}));
        end
        sdiEngine.setMetaDataV2(signalIDs(i),'SubPath',signalSubPath{i});
        sdiEngine.sigRepository.setSignalIsEventBased(signalIDs(i),true);
    end

    sdiEngine.setRunMetaDataV2(runId,'ContainsVerify',int32(1));

end

function name=buildSignalName(blkPath,sfPath,msgId)
    r=regexp(msgId,'verify(.*','once');
    if(isempty(r)||r~=1)

        if(isempty(blkPath)&&isempty(sfPath))
            assertBlockSplit=strsplit(msgId,'/');
            name=char(assertBlockSplit(end));
        else

            name=msgId;
        end
    else



        separator=strfind(blkPath,'/');
        blkName=blkPath;
        blkName(1:separator(end))=[];
        name=[blkName,'/',sfPath,':',msgId];
    end
end
