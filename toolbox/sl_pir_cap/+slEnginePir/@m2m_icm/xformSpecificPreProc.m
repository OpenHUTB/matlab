function errMsg=xformSpecificPreProc(this)


    this.fTraceabilityMap=struct('Before',{},'After',{});

    errMsg=[];
    this.fXformedBlks={};
    for cIdx=1:length(this.fCandidateInfo)
        clsInfo=this.fCandidateInfo(cIdx);
        for oIdx=1:length(clsInfo.Objects)
            objInfo=clsInfo.Objects(oIdx);
            for fIdx=1:length(objInfo.FcnCalls)
                this.fXformedBlks=[this.fXformedBlks,objInfo.FcnCalls(fIdx).LinkedSS];
            end
            if~this.fIsForBosch
                for fIdx=1:length(objInfo.GetCalls)
                    this.fXformedBlks=[this.fXformedBlks,objInfo.GetCalls(fIdx)];
                end
                for fIdx=1:length(objInfo.SetCalls)
                    this.fXformedBlks=[this.fXformedBlks,objInfo.SetCalls(fIdx)];
                end
            end
        end
    end
end
