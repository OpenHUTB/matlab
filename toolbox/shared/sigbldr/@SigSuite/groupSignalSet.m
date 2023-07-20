function groupSignalSet(this,sigIdx,grpIdx,time,data)












    [sigIdx,grpIdx]=groupSignalIndexCheck(this,sigIdx,grpIdx,'SG');
    SigSuite.timeDataConsistencyCheck(time,data);
    [time,data]=SigSuite.canonicalMake(time,data,[],[]);

    newSigCnt=length(sigIdx);
    newGrpCnt=length(grpIdx);
    [dataSigs,dataGrps]=size(data);

    if(newSigCnt~=dataSigs)
        DAStudio.error('Sigbldr:sigsuite:SignalDataMismatch',...
        newSigCnt,dataSigs);
    end

    if(newGrpCnt~=dataGrps)
        DAStudio.error('Sigbldr:sigsuite:GroupDataMismatch',...
        newGrpCnt,dataGrps);
    end

    for gidx=1:newGrpCnt
        m=grpIdx(gidx);
        for sidx=1:newSigCnt
            n=sigIdx(sidx);



            minTime=this.Groups(m).Signals(n).XData(1);
            maxTime=this.Groups(m).Signals(n).XData(end);

            newTime=time{sidx,gidx};
            newMinTime=newTime(1);
            newMaxtime=newTime(end);

            if newMinTime>=maxTime||newMaxtime<=minTime
                DAStudio.error('Sigbldr:sigbldr:ValidSignalData');
            end

            this.Groups(m).Signals(n).XData=time{sidx,gidx};
            this.Groups(m).Signals(n).YData=double(data{sidx,gidx});
        end
    end
end