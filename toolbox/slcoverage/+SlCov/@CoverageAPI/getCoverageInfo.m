



function varargout=getCoverageInfo(covdata,block,varargin)

    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    if nargin<1
        error(message('Slvnv:simcoverage:getCoverageInfo:NotEnoughInputs'));
    end


    allowedArgs=[1,1,0,1];
    if nargin==4&&isstruct(varargin{2})
        opts=parseQueryFunctionArgs('getCoverageInfo',allowedArgs,varargin{2:end});
        opts.CvMetrics=varargin{1};
    else
        if nargin<3
            varargin={};
        end
        opts=parseQueryFunctionArgs('getCoverageInfo',allowedArgs,varargin{:});
    end


    if nargin>0
        [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(covdata);
        if hasMLCoderCov

            if nargin<2
                ids='';
            else
                ids=block;
            end

            if opts.CvMetrics==cvmetric.Structural.block
                metricName='execution';
            elseif opts.CvMetrics==cvmetric.Structural.relationalop
                metricName='relationalop';
            else
                varargout=repmat({[]},1,nargout);
                return
            end
            [varargout{1:nargout}]=SlCov.CoverageAPI.getMLCoderCoverageInfoInternal(covdata,metricName,ids,opts.CovMode);
            return
        end
    end


    if nargin<2
        error(message('Slvnv:simcoverage:getCoverageInfo:NotEnoughInputs'));
    end

    SlCov.CoverageAPI.checkCvdataInput(covdata);

    [cvd,blockCvId,~,~,codeInfo]=SlCov.CoverageAPI.getCvdata(covdata,block,opts.CovMode);
    if isempty(cvd)||isempty(blockCvId)||ischar(blockCvId)||blockCvId==0
        varargout=cell(1,nargout);
        return;
    end

    metricNames={};
    cvmetrics=opts.CvMetrics;
    if isempty(cvmetrics)
        [~,metricNames]=cvi.ReportUtils.get_common_metric_names(cvd);
    else
        if~iscell(cvmetrics)
            cvmetrics={cvmetrics};
        end
        for idx=1:numel(cvmetrics)
            metricNames{end+1}=cvi.MetricRegistry.cvmetricToStr(cvmetrics{idx});%#ok<AGROW>
        end
    end
    covCell={};
    descriptionCell={};
    needDescription=nargout>1;
    for idx=1:numel(metricNames)
        metricName=metricNames{idx};

        cov=[];
        description=[];

        if~isempty(blockCvId)
            if codeInfo.mode~=SlCov.CovMode.Unknown

                covFromCvEngine=false;
                if codeInfo.mode==SlCov.CovMode.SFunction

                    [cov,codeCovRes,justifiedHitNums]=cvi.ReportData.getSFunctionCodeResInfo(cvd,codeInfo,metricName);
                    [cveCov,description]=collectData(cvd,block,metricName,opts.IgnoreDescendants,needDescription,opts.TextDetailLevel);


                    if strcmpi(metricName,'cvmetric_Structural_block')
                        if isempty(codeInfo.fileName)&&isempty(codeInfo.fcnName)

                            covFromCvEngine=true;
                            cov=cveCov;
                        end
                        if~isempty(codeCovRes)
                            codeCovRes.sfcnInfo.description=description;
                            codeCovRes.sfcnInfo.covFromCvEngine=covFromCvEngine;
                        end
                    end
                elseif codeInfo.mode==SlCov.CovMode.SLCustomCode
                    [cov,codeCovRes,justifiedHitNums]=cvi.ReportData.getSimCustomCodeResInfo(cvd,codeInfo,metricName);
                else
                    [cov,codeCovRes,justifiedHitNums]=cvi.ReportData.getECCodeResInfo(cvd,codeInfo,metricName,opts.IgnoreDescendants,opts.CovMode);
                end
                if~isempty(cov)&&~covFromCvEngine
                    cov(1)=cov(1)+justifiedHitNums;
                end

                if needDescription&&~isempty(codeCovRes)
                    if codeInfo.mode==SlCov.CovMode.SFunction
                        filterRationale='';
                        isFiltered=isfield(description,'isFiltered')&&~isempty(description.isFiltered)&&(description.isFiltered>0);
                        isJustified=isfield(description,'isJustified')&&~isempty(description.isJustified)&&(description.isJustified>0);
                        if isFiltered||isJustified
                            filterRationale=description.filterRationale;
                        end
                        filterMode=0;
                        if isFiltered
                            filterMode=1;
                        elseif isJustified
                            filterMode=2;
                        end
                        extraArgs={filterMode,filterRationale};
                    else
                        extraArgs={};
                    end
                    description=cvi.ReportData.getCodeCoverageInfo(...
                    codeCovRes,metricName,justifiedHitNums,extraArgs{:});
                end
            else

                [cov,description]=collectData(cvd,block,metricName,opts.IgnoreDescendants,needDescription,opts.TextDetailLevel);
            end
        end

        if~isempty(cov)&&~isempty(cov(1))
            covCell{end+1}=cov;%#ok<AGROW>
            descriptionCell{end+1}=description;%#ok<AGROW>
        end
    end

    if isempty(covCell)
        varargout=cell(1,nargout);
        return;
    end

    if numel(covCell)>1
        varargout{1}=covCell;
    else
        varargout{1}=covCell{1};
    end

    if needDescription
        if numel(descriptionCell)>1
            varargout{2}=descriptionCell;
        else
            varargout{2}=descriptionCell{1};
        end
    end

    function[res,description]=collectData(data,block,metricName,ignoreDescendants,needDescription,txtDetail)

        res=[];
        description=[];
        if~isfield(data.metrics.testobjectives,metricName)||...
            isempty(data.metrics.testobjectives.(metricName))
            return;
        end

        testobjectiveEnum=cvi.MetricRegistry.getEnum(metricName);
        [data,blockCvId,newBlockCvId]=SlCov.CoverageAPI.getCvdata(data,block);
        cvi.ReportData.updateDataIdx(data);

        [dataMat,hitNums,justifiedHit]=cvi.ReportData.getAPIMetricInfo(data,metricName,blockCvId,ignoreDescendants,true);

        if isempty(hitNums)
            return;
        else
            hitNums(1)=hitNums(1)+justifiedHit;
            res=hitNums;
        end
        description=[];
        if needDescription
            description.isFiltered=cv('get',newBlockCvId,'.isDisabled');
            if description.isFiltered
                description.filterRationale=cvi.ReportUtils.getFilterRationale(newBlockCvId);
            end

            description.isJustified=cv('get',blockCvId,'.isJustified');
            description.justifiedCoverage=justifiedHit;
            description.filterRationale=cvi.ReportUtils.getFilterRationale(blockCvId);
            testObjs=cv('MetricGet',newBlockCvId,testobjectiveEnum,'.baseObjs');

            for testObjId=testObjs(:)'

                [startIdx,showTrueOutcome]=cv('get',testObjId,'.dc.baseIdx','.dc.showTrueOutcome');
                d=[];
                d.text=cv('TextOf',testObjId,-1,[],txtDetail);

                if showTrueOutcome
                    d.executionCount=dataMat(startIdx+2,:);
                else
                    reportData=cvi.ReportData({data});
                    toInfo=reportData.getDecisionInfo(metricName,dataMat,testObjId,txtDetail);

                    rat=cvi.ReportUtils.getFilterRationale(testObjId,true);
                    rats=split(string(rat),cvi.ReportUtils.rationaleSeparator);
                    ratIdx=1;
                    filteredOutcomes=cv('get',testObjId,'.filteredOutcomes');
                    filteredOutcomeModes=cv('get',testObjId,'.filteredOutcomeModes');
                    for idx=1:numel(toInfo.outcome)
                        to.execCount=toInfo.outcome(idx).execCount;
                        to.executionCount=to.execCount;
                        to.text=toInfo.outcome(idx).text;
                        [isFiltered,isJustified]=SlCov.CoverageAPI.isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,idx);
                        [isFiltered,isJustified]=SlCov.CoverageAPI.filterInheritanceLogic(isFiltered,isJustified,...
                        description.isFiltered,description.isJustified,...
                        description.filterRationale,description.filterRationale);
                        to.isFiltered=double(isFiltered);
                        to.isJustified=double(isJustified);
                        to.filterRationale='';
                        if strcmpi(cv('Feature','Trace'),'on')
                            to.executedIn=data.getTraceInfo(toInfo.metricName,startIdx+idx);
                        end

                        if ratIdx<=numel(rats)&&isJustified
                            to.filterRationale=rats{ratIdx};
                            ratIdx=ratIdx+1;
                        end
                        d.outcome(idx)=to;
                    end

                end


                if~isfield(description,'testobjects')
                    description.testobjects=d;
                else
                    description.testobjects(end+1)=d;
                end
            end
        end


