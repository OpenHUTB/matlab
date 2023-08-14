



function varargout=getTableInfo(data,block,ignoreDescendants)

    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    if nargin<2
        error(message('Slvnv:simcoverage:tableinfo:AtLeast2Input'));
    end

    if nargin<3||isempty(ignoreDescendants)
        ignoreDescendants=0;
    end

    [hitNums,metricEnum,blockCvId,dataMat,~,justifiedHit,cvd]=cvi.ReportData.getHitCount(data,block,'tableExec',ignoreDescendants,true);

    if isempty(hitNums)
        varargout=cell(1,nargout);
        return;
    else
        hitNums(1)=hitNums(1)+justifiedHit;
        varargout{1}=hitNums;
    end
    if nargout>1
        needBrkPtOut=nargout>2;
        needTraceOut=nargout>3;
        tables=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');

        if length(tables)==1
            [brkDims,offset]=cv('get',tables,'table.dimBrkSizes','table.dataBaseIdx.intervalExec');
            intervalCnt=prod(brkDims+1);
            rawData=dataMat(offset+(1:intervalCnt));
            if length(brkDims)>1
                varargout{2}=reshape(rawData,brkDims+1);
            else
                varargout{2}=rawData;
            end
            if needBrkPtOut
                brkEqOffset=cv('get',tables,'table.dataBaseIdx.brkPtEquality');
                rawData=dataMat(brkEqOffset+(1:sum(brkDims)));
                base=0;
                for i=1:length(brkDims)
                    eqOut{i}=rawData(base+(1:brkDims(i)));%#ok<AGROW>
                    base=base+brkDims(i);
                end
                varargout{3}=eqOut;
            end
            if needTraceOut
                if cvd.traceOn&&strcmpi(cv('Feature','Trace'),'on')
                    rawTrace=getTableTrace(cvd,offset+(1:intervalCnt));
                    if length(brkDims)>1
                        varargout{4}=reshape(rawTrace,brkDims+1);
                    else
                        varargout{4}=rawTrace;
                    end
                else
                    varargout{4}=[];
                end
            end

        else
            if isempty(tables)
                varargout{2}=[];
                if needBrkPtOut
                    varargout{3}=[];
                end
                if needTraceOut
                    varargout{4}=[];
                end
            else


            end
        end
    end
end

function trace=getTableTrace(cvd,size)
    trace=cell(numel(size),1);
    cidx=1;
    for idx=size
        trace{cidx,1}=cvd.getTraceInfo('tableExec',idx);
        cidx=cidx+1;
    end
end
