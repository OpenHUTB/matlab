function res=getDataResult(this)




    refModelCovObjs=this.getModelCovIdsForReporting;
    res=[];
    if~isempty(refModelCovObjs)
        allTestIds=cv('get',refModelCovObjs,'.currentTest');
        allTestIds(allTestIds==0)=[];
        allTestIds=num2cell(allTestIds');
        adjustSimStopTime(this,allTestIds);
        if length(allTestIds)==1
            res=cvdata(allTestIds{:});
        else
            res=cv.cvdatagroup(allTestIds{:});
            setMdlBlkToCopyMdlInfo(this,res);
        end
    end
    if~isempty(res)
        this.lastCovData=res;
    end
end




function adjustSimStopTime(this,allTestIds)
    stopTime=get_param(this.topModelH,'SimulationTime');
    scriptStopTime=stopTime;
    for idx=1:numel(allTestIds)
        cId=allTestIds{idx};
        if cv('get',cId,'.simStopTime')<stopTime
            cv('set',cId,'.simStopTime',stopTime)
        end
        scriptStopTime=cv('get',cId,'.simStopTime');
    end
    adjustScriptStopTime(allTestIds,scriptStopTime);
end


function adjustScriptStopTime(allTestIds,scriptStopTime)
    for idx=1:numel(allTestIds)
        cId=allTestIds{idx};
        if cv('get',cv('get',cId,'.modelcov'),'.isScript')
            cv('set',cId,'.simStopTime',scriptStopTime)
        end
    end
end


function setMdlBlkToCopyMdlInfo(this,res)
    if~isempty(this.covModelRefData)&&~isempty(this.covModelRefData.mdlBlkToCopyMdlMap)
        res.mdlBlkToCopyMdlMap=this.covModelRefData.mdlBlkToCopyMdlMap;
    end
end

