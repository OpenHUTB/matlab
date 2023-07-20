



function varargout=getSignalSizeInfo(covdata,block,portIdx)

    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    SlCov.CoverageAPI.checkCvdataInput(covdata);

    [covdata,blockCvId,~,sfPortEquiv]=SlCov.CoverageAPI.getCvdata(covdata,block);

    if isempty(blockCvId)||ischar(blockCvId)||blockCvId==0||~isfield(covdata.metrics,'sigsize')
        varargout=cell(1,nargout);
        return;
    end
    dataMat=covdata.metrics.sigsize;
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
    end

    if(~isempty(portIdx)&&(sf('Private','is_sf_chart_block',Simulink.ID.getHandle(Simulink.ID.getSID(block)))))

        portIdx=sf('Private','blkout2sfunout',Simulink.ID.getHandle(Simulink.ID.getSID(block)),portIdx)-1;
    end

    metricIsa=cv('get','default','sigrange.isa');
    if(cv('get',blockCvId,'.isa')~=metricIsa)
        [blockCvId,cvIsa]=cv('MetricGet',blockCvId,cvi.MetricRegistry.getEnum('sigsize'),'.id','.isa');
        if(isempty(blockCvId)||blockCvId==0||cvIsa~=metricIsa)
            varargout=cell(1,nargout);
            return;
        end
    end

    objCvId=cv('get',blockCvId,'.slsfobj');
    if cv('get',objCvId,'.isDisabled')
        varargout=cell(1,nargout);
        return;
    end
    [baseIdx,allWidths,isDynamic]=cv('get',blockCvId,'.cov.baseIdx','.cov.allWidths','.cov.isDynamic');

    allWidths(logical(isDynamic))=inf;

    if isempty(portIdx)
        lngth=numel(allWidths);
        mins=dataMat(baseIdx+(1:2:(2*lngth)));
        maxs=dataMat(baseIdx+1+(1:2:(2*lngth)));
        alloc=allWidths';
    else
        mins=dataMat(baseIdx+portIdx*2-1);
        maxs=dataMat(baseIdx+portIdx*2);
        alloc=allWidths(portIdx);
    end
    varargout{1}=mins;
    varargout{2}=maxs;
    varargout{3}=alloc;
