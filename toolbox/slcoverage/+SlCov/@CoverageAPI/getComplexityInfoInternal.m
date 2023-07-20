



function varargout=getComplexityInfoInternal(data,block,varargin)


    opts=parseQueryFunctionArgs('complexityinfo',[0,0,0,1],varargin{:});


    if nargin>0
        [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(data);
        if hasMLCoderCov

            if nargin<2
                ids='';
            else
                ids=block;
            end
            [varargout{1:nargout}]=SlCov.CoverageAPI.getMLCoderCoverageInfoInternal(data,'complexity',ids,opts.CovMode);
            return
        end
    end


    if nargin<2
        error(message('Slvnv:simcoverage:complexityinfo:AtLeast2Input'));
    end

    varargout=cell(1,nargout);

    if~isempty(data)
        SlCov.CoverageAPI.checkCvdataInput(data);

        [covdata,blockCvId,~,portIdx,codeInfo]=SlCov.CoverageAPI.getCvdata(data,block,opts.CovMode);

        if isa(covdata,'cvdata')
            cvi.ReportData.updateDataIdx(covdata);


            if codeInfo.mode~=SlCov.CovMode.Unknown
                if codeInfo.mode==SlCov.CovMode.SFunction
                    hitNums=cvi.ReportData.getSFunctionCodeResInfo(covdata,codeInfo,'complexity');
                elseif(codeInfo.mode==SlCov.CovMode.SFCustomCode||codeInfo.mode==SlCov.CovMode.SLCustomCode)
                    hitNums=cvi.ReportData.getSimCustomCodeResInfo(covdata,codeInfo,'complexity');
                else
                    hitNums=cvi.ReportData.getECCodeResInfo(covdata,codeInfo,'complexity',[],opts.CovMode);
                end
                if~isempty(hitNums)
                    varargout{1}=hitNums;
                end
                return
            end
        end

        if isempty(blockCvId)||ischar(blockCvId)||blockCvId==0||portIdx>0
            varargout{1}=[];
            return
        end
    else
        handle=block;
        sfId=[];
        if iscell(block)
            handle=block{1};
            sfId=block{2};
        end
        blockCvId=SlCov.CoverageAPI.getCovId(convertStringsToChars(handle),sfId,false);
    end

    allmetrics=cvi.MetricRegistry.getDDEnumVals;
    cycloEnum=allmetrics.MTRC_CYCLCOMPLEX;

    [cmplx_ismodule,cmplx_shallow,cmplx_deep]=cv('MetricGet',blockCvId,cycloEnum,...
    '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep');

    if isempty(cmplx_ismodule)
        return
    end
    if isScript(blockCvId)
        cmplx_deep=cmplx_deep+1;
        cmplx_shallow=1;
    end
    varargout{1}=[cmplx_deep,cmplx_shallow];
end

function res=isScript(blockCvId)
    modelcovId=cv('get',blockCvId,'.modelcov');
    res=cv('get',modelcovId,'.isScript');
end



