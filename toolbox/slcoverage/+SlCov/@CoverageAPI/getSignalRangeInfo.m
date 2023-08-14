



function varargout=getSignalRangeInfo(covdata,block,portIdx,includeAllSizes)

    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    SlCov.CoverageAPI.checkCvdataInput(covdata);

    [covdata,blockCvId,~,sfPortEquiv]=SlCov.CoverageAPI.getCvdata(covdata,block);

    if isempty(blockCvId)||ischar(blockCvId)||blockCvId==0||~isfield(covdata.metrics,'sigrange')
        varargout=cell(1,nargout);
        return;
    end
    dataMat=covdata.metrics.sigrange;
    if isempty(dataMat)
        varargout=cell(1,nargout);
        return;
    end

    if nargin<3||isempty(portIdx)
        if sfPortEquiv>=0
            portIdx=sfPortEquiv;
        else
            portIdx=[];
        end
    else
        portIdx=getSFPortIdx(block,portIdx);
    end

    if nargin<4||isempty(includeAllSizes)
        includeAllSizes=0;
    end

    [minsize,maxsize]=SlCov.CoverageAPI.getSignalSizeInfo(covdata,block,portIdx);
    isVariableSize=~isempty(minsize);


    metricName='sigrange';

    metricIsa=cv('get','default',[metricName,'.isa']);
    if(cv('get',blockCvId,'.isa')~=metricIsa)
        [blockCvId,cvIsa]=cv('MetricGet',blockCvId,cvi.MetricRegistry.getEnum(metricName),'.id','.isa');
        if(isempty(blockCvId)||blockCvId==0||cvIsa~=metricIsa)
            varargout=cell(1,nargout);
            return;
        end
    end

    [baseIdx,allWidths]=cv('get',blockCvId,'.cov.baseIdx','.cov.allWidths');



    if~isempty(portIdx)&&(portIdx>numel(allWidths)||portIdx<=0)
        error(message('Slvnv:simcoverage:sigrangeinfo:PortIdxOutOfRange_OrControlSignal'));
    end

    if isempty(portIdx)
        lngth=sum(allWidths);
        if isVariableSize&&~includeAllSizes
            startIdx=baseIdx+[0,2*cumsum(allWidths)];
            mins=[];
            maxs=[];
            for idx=1:numel(allWidths)
                start=startIdx(idx);
                lngth=maxsize(idx);
                mins=[mins;dataMat(start+(1:2:(2*lngth)))];%#ok<AGROW>
                maxs=[maxs;dataMat(start+(2:2:(2*lngth)))];%#ok<AGROW>
            end
        else
            mins=dataMat(baseIdx+(1:2:(2*lngth)));
            maxs=dataMat(baseIdx+(2:2:(2*lngth)));
        end
    else
        lngth=allWidths(portIdx);
        if isVariableSize&&abs(maxsize)~=Inf&&~includeAllSizes
            lngth=maxsize;
        end

        if portIdx==1
            mins=dataMat(baseIdx+(1:2:(2*lngth)));
            maxs=dataMat(baseIdx+(2:2:(2*lngth)));
        else
            startIdx=baseIdx+[0,2*cumsum(allWidths)];
            start=startIdx(portIdx);
            mins=dataMat(start+(1:2:(2*lngth)));
            maxs=dataMat(start+(2:2:(2*lngth)));
        end
    end
    varargout{1}=mins;
    varargout{2}=maxs;

    function portIdx=getSFPortIdx(block,portIdx)
        blockH=Simulink.ID.getHandle(Simulink.ID.getSID(block));
        if~isempty(portIdx)&&...
            slprivate('is_stateflow_based_block',blockH)


            portIdx=sf('Private','blkout2sfunout',blockH,portIdx)-1;
        end
