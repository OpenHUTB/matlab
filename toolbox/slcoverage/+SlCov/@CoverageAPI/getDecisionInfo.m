



function varargout=getDecisionInfo(data,block,varargin)

    if nargin<1
        error(message('Slvnv:simcoverage:decisioninfo:AtLeast2Input'));
    end

    if SlCov.CoverageAPI.isCovDataUsedBySlicer(data)
        [status,msgId]=SlCov.CoverageAPI.checkSlicerLicense;
    else
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    end
    if status==0
        error(message(msgId));
    end


    opts=parseQueryFunctionArgs('decisioninfo',[0,1,1,1],varargin{:});


    [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(data);
    if hasMLCoderCov

        if nargin<2
            ids='';
        else
            ids=block;
        end
        [varargout{1:nargout}]=SlCov.CoverageAPI.getMLCoderCoverageInfoInternal(data,'decision',ids,opts.CovMode);
        return
    end


    if nargin<2
        error(message('Slvnv:simcoverage:decisioninfo:AtLeast2Input'));
    end

    [hitNums,metricEnum,blockCvId,dataMat,codeCovRes,justifiedHit,cvd]=cvi.ReportData.getHitCount(data,block,'decision',opts.IgnoreDescendants,opts.IncludeAllSizes,opts.CovMode);

    if isempty(hitNums)
        varargout=cell(1,nargout);
        return;
    else
        hitNums(1)=hitNums(1)+justifiedHit;
        varargout{1}=hitNums;
    end

    if nargout>1
        description=[];
        description.isFiltered=cv('get',blockCvId,'.isDisabled');
        if SlCov.CoverageAPI.feature('justification')
            description.justifiedCoverage=justifiedHit;
            description.isJustified=cv('get',blockCvId,'.isJustified');
        end
        rationale=cvi.ReportUtils.getFilterRationale(blockCvId);
        if cvi.ReportUtils.checkInternalRationale(rationale)
            varargout=cell(1,nargout);
            return;
        end
        description.filterRationale=cvi.ReportUtils.getFilterRationale(blockCvId);

        if~isempty(codeCovRes)
            if isfield(codeCovRes,'isSFcnBlock')
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
            varargout{2}=cvi.ReportData.getCodeCoverageInfo(codeCovRes,'decision',justifiedHit,extraArgs{:});
            return
        end
        decisions=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');
        numOfInternallyFilteredDecision=0;
        for decId=decisions(:)'
            d=[];

            [outcomes,startIdx,activeOutcomeIdx,hasVariableSize]=cv('get',decId,'.dc.numOutcomes','.dc.baseIdx','.dc.activeOutcomeIdx','.hasVariableSize');
            isActive=true;
            if hasVariableSize
                maxActOutcome=dataMat(activeOutcomeIdx+1);
                isActive=maxActOutcome>0;
            end
            if isActive||opts.IncludeAllSizes
                d.text=cv('TextOf',decId,-1,[],opts.TextDetailLevel);
                [isFiltered,isJustified,d.filterRationale]=...
                SlCov.CoverageAPI.filterInheritanceLogic(cv('get',decId,'.isDisabled'),cv('get',decId,'.isJustified'),...
                description.isFiltered,description.isJustified,...
                cvi.ReportUtils.getFilterRationale(decId),description.filterRationale);
                d.isFiltered=double(isFiltered);
                d.isJustified=double(isJustified);
                filteredOutcomes=cv('get',decId,'.filteredOutcomes');
                filteredOutcomeModes=cv('get',decId,'.filteredOutcomeModes');
                rat=cvi.ReportUtils.getFilterRationale(decId,true);
                rats=split(string(rat),cvi.ReportUtils.rationaleSeparator);
                ratIdx=1;
                numOfInternallyFilteredOutcomes=0;

                for i=1:outcomes
                    out=[];
                    if~hasVariableSize||...
                        (hasVariableSize&&(opts.IncludeAllSizes||(isActive&&i<=maxActOutcome)))
                        out.text=cv('TextOf',decId,i-1,[],opts.TextDetailLevel);
                        out.executionCount=dataMat(startIdx+i);
                        if strcmpi(cv('Feature','Trace'),'on')
                            out.executedIn=cvd.getTraceInfo('decision',startIdx+i);
                        end

                        [isFilteredOutcome,isJustifiedOutcome]=SlCov.CoverageAPI.isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,i);
                        [isFiltered,isJustified]=SlCov.CoverageAPI.filterInheritanceLogic(isFilteredOutcome,isJustifiedOutcome,...
                        d.isFiltered,d.isJustified,...
                        d.filterRationale,d.filterRationale);
                        out.isFiltered=double(isFiltered);
                        out.isJustified=double(isJustified);
                        out.filterRationale='';
                        if ratIdx<=numel(rats)&&(isJustifiedOutcome||isFilteredOutcome)
                            out.filterRationale=rats{ratIdx};
                            ratIdx=ratIdx+1;
                        end
                        isInternal=cvi.ReportUtils.checkInternalRationale(out.filterRationale);
                        if isInternal
                            numOfInternallyFilteredOutcomes=numOfInternallyFilteredOutcomes+1;
                        else
                            if~isfield(d,'outcome')
                                d.outcome=out;
                            else
                                d.outcome(end+1)=out;
                            end
                        end
                    end
                end

                if numOfInternallyFilteredOutcomes==outcomes
                    numOfInternallyFilteredDecision=numOfInternallyFilteredDecision+1;
                end

                if isfield(d,'outcome')&&~isempty(d.outcome)
                    if isempty(description)||~isfield(description,'decision')
                        description.decision=d;
                    else
                        description.decision(end+1)=d;
                    end
                end
            end
        end
        if numOfInternallyFilteredDecision>0&&...
            numOfInternallyFilteredDecision==numel(decisions)
            varargout{2}=[];
        else
            varargout{2}=description;
        end
    end



