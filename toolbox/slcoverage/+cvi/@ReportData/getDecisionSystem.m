function[decData,decObjs]=getDecisionSystem(this,sysEntry,currDecCount)





    decisionData=this.metricData.decision;


    metricEnum=cvi.MetricRegistry.getEnum('decision');
    [decObjs,justifiedLocalIdx,justifiedTotalIdx,...
    localIdx,localCnt,varLocalCntIdx,totalIdx,totalCnt,varTotalCntIdx,hasVariableSize,hasLocalVariableSize]=cv('MetricGet',sysEntry.cvId,metricEnum,...
    '.baseObjs',...
    '.justifiedDataIdx.shallow','.justifiedDataIdx.deep',...
    '.dataIdx.shallow','.dataCnt.shallow','.dataCnt.varShallowIdx',...
    '.dataIdx.deep','.dataCnt.deep','.dataCnt.varDeepIdx','.hasVariableSize','.hasLocalVariableSize');

    if isempty(totalCnt)||totalCnt==0
        decData=[];
        return;
    end

    decData.decisionIdx=currDecCount+(1:length(decObjs));
    decData.inBlockIdx=1:numel(decObjs);
    if localIdx==-1
        decData.outlocalCnts=[];
        decData.justifiedOutlocalCnts=[];
        decData.executedIn='';
    else
        [decData.outlocalCnts,decData.justifiedOutlocalCnts]=cvi.ReportData.getHits(decisionData,localIdx,justifiedLocalIdx);
        decData.executedIn='';
    end

    [decData.outTotalCnts,decData.justifiedOutTotalCnts]=cvi.ReportData.getHits(decisionData,totalIdx,justifiedTotalIdx);
    if hasVariableSize
        totalCnt=decisionData(varTotalCntIdx+1,end);
    end
    if hasLocalVariableSize
        localCnt=decisionData(varLocalCntIdx+1,end);
    end
    decData.totalLocalCnts=localCnt;
    decData.totalTotalCnts=totalCnt;
    decData.totalExecutedIn='';

    if(decData.outTotalCnts(end)==totalCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        if(~isempty(decData.outlocalCnts)&&(decData.outlocalCnts(end)~=localCnt))&&...
            (localCnt~=(decData.outlocalCnts(end)+decData.justifiedOutlocalCnts(end)))
            flags.leafUncov=1;
        else
            flags.leafUncov=0;
        end
        if decData.outTotalCnts==0
            flags.noCoverage=1;
        end
    end
    decData.flags=flags;


