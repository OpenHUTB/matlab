function[mcdcData,mcdcObjs]=getMcdcBlock(this,blockInfo,currMcdcCnt)







    flags=[];
    mcdcData=[];

    metricEnum=cvi.MetricRegistry.getEnum('mcdc');
    [mcdcObjs,localIdx,localCnt,justifiedLocalIdx,varLocalCntIdx,hasLocalVariableSize]=cv('MetricGet',blockInfo.cvId,...
    metricEnum,'.baseObjs',...
    '.dataIdx.shallow','.dataCnt.shallow',...
    '.justifiedDataIdx.shallow',...
    '.dataCnt.varShallowIdx','.hasLocalVariableSize');


    if isempty(mcdcObjs)
        cascadeRoot=cvi.CascMCDC.getCascadeRoot(blockInfo.cvId);
        if~isempty(cascadeRoot)

            mcdcData.cascadeRoot.cvId=cascadeRoot;
            mcdcData.cascadeRoot.name=get_param(cv('get',cascadeRoot,'.handle'),'Name');
            mcdcData.flags.fullCoverage=0;
            mcdcData.flags.noCoverage=0;
            mcdcData.flags.leafUncov=0;
        end
    end

    if isempty(localCnt)||localCnt==0
        return;
    end

    if~isfield(mcdcData,'cascadeRoot')

        mcdcData.cascadeRoot=[];
    end


    mcdcMetricData=this.metricData.mcdc;

    mcdcData.mcdcIndex=currMcdcCnt+(1:length(mcdcObjs));
    mcdcData.inBlockIdx=1:numel(mcdcObjs);
    [mcdcData.localHits,mcdcData.justifiedLocalHits]=cvi.ReportData.getHits(mcdcMetricData,localIdx,justifiedLocalIdx);
    if hasLocalVariableSize
        localCnt=mcdcMetricData(varLocalCntIdx+1,end);
    end
    mcdcData.localCnt=localCnt;
    mcdcData.executedIn=this.cvd{1}.getTrace('mcdc',localIdx+1,true);
    if(mcdcData.localHits(end)==localCnt)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
    else
        flags.fullCoverage=0;
        flags.leafUncov=1;
        if(localCnt==(mcdcData.localHits(end)+mcdcData.justifiedLocalHits(end)))
            flags.leafUncov=0;
        end
        if mcdcData.localHits(end)==0
            flags.noCoverage=1;
        else
            flags.noCoverage=0;
        end
    end
    mcdcData.flags=flags;


