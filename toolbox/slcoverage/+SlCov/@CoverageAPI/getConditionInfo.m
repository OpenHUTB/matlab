



function varargout=getConditionInfo(data,block,varargin)

    if nargin<1
        error(message('Slvnv:simcoverage:conditioninfo:InvalidArgumentNumber'));
    end

    if SlCov.CoverageAPI.isCovDataUsedBySlicer(data)
        [status,msgId]=SlCov.CoverageAPI.checkSlicerLicense;
    else
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    end
    if status==0
        error(message(msgId));
    end


    opts=parseQueryFunctionArgs('conditioninfo',[0,1,1,1],varargin{:});


    [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(data);
    if hasMLCoderCov

        if nargin<2
            ids='';
        else
            ids=block;
        end
        [varargout{1:nargout}]=SlCov.CoverageAPI.getMLCoderCoverageInfoInternal(data,'condition',ids,opts.CovMode);
        return
    end


    if nargin<2
        error(message('Slvnv:simcoverage:conditioninfo:InvalidArgumentNumber'));
    end

    [hitNums,metricEnum,blockCvId,dataMat,codeCovRes,justifiedHit,cvd]=cvi.ReportData.getHitCount(data,block,'condition',opts.IgnoreDescendants,opts.IncludeAllSizes,opts.CovMode);

    if isempty(hitNums)
        varargout=cell(1,nargout);
        return;
    else
        hitNums(1)=hitNums(1)+justifiedHit;
        varargout{1}=hitNums;
    end

    if nargout>1
        isFiltered=cv('get',blockCvId,'.isDisabled');
        filterRationale=cvi.ReportUtils.getFilterRationale(blockCvId);

        if~isempty(codeCovRes)
            if isfield(codeCovRes,'isSFcnBlock')
                filterMode=0;
                if isFiltered
                    filterMode=1;
                elseif cv('get',blockCvId,'.isJustified')>0
                    filterMode=2;
                end
                extraArgs={filterMode,filterRationale};
            else
                extraArgs={};
            end
            varargout{2}=cvi.ReportData.getCodeCoverageInfo(codeCovRes,'condition',justifiedHit,extraArgs{:});
            return
        end

        condInfo.isFiltered=0;
        if~isempty(isFiltered)&&isFiltered
            condInfo.isFiltered=1;
        end
        condInfo.filterRationale=filterRationale;

        if SlCov.CoverageAPI.feature('justification')
            condInfo.justifiedCoverage=justifiedHit;
            condInfo.isJustified=cv('get',blockCvId,'.isJustified');
        end
        condInfo.condition=[];
        conditions=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');
        if isempty(conditions)
            varargout{2}=condInfo;
            return;
        end
        descriptions=[];
        for condId=conditions(:)'
            condEntry.isFiltered=0;
            condEntry.isJustified=0;
            condEntry.filterRationale='';

            [trueCountIdx,falseCountIdx,activeCondIdx,hasVariableSize]=cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx','.coverage.activeCondIdx','.hasVariableSize');
            isActive=true;
            if hasVariableSize
                isActive=any(dataMat(activeCondIdx+1)>0);
            end
            if isActive||opts.IncludeAllSizes
                condEntry.text=cv('TextOf',condId,-1,[],opts.TextDetailLevel);
                condEntry.trueCnts=dataMat(trueCountIdx+1,:);
                condEntry.falseCnts=dataMat(falseCountIdx+1,:);

                [isFiltered,isJustified,condEntry.filterRationale]=...
                SlCov.CoverageAPI.filterInheritanceLogic(cv('get',condId,'.isDisabled'),cv('get',condId,'.isJustified'),...
                condEntry.isFiltered,condEntry.isJustified,...
                cvi.ReportUtils.getFilterRationale(condId),condEntry.filterRationale);
                condEntry.isFiltered=double(isFiltered);
                condEntry.isJustified=double(isJustified);

                if isempty(condEntry.filterRationale)
                    condEntry.filterRationale=cvi.ReportUtils.getFilterRationale(condId);
                end
                condEntry=checkFilteredOutcome(condEntry,condId);

                if strcmpi(cv('Feature','Trace'),'on')
                    condEntry.trueExecutedIn=cvd.getTraceInfo('condition',trueCountIdx+1);
                    condEntry.falseExecutedIn=cvd.getTraceInfo('condition',falseCountIdx+1);
                end

                if isempty(descriptions)
                    descriptions=condEntry;
                else
                    descriptions(end+1)=condEntry;%#ok<AGROW>
                end

            end
        end
        condInfo.condition=descriptions;
        varargout{2}=condInfo;
    end

    function condEntry=checkFilteredOutcome(condEntry,condId)

        condEntry.trueOutcomeFilter=[];
        condEntry.falseOutcomeFilter=[];
        condEntry.trueOutcomeFilter.isFiltered=condEntry.isFiltered;
        condEntry.trueOutcomeFilter.isJustified=condEntry.isJustified;
        condEntry.trueOutcomeFilter.filterRationale='';
        condEntry.falseOutcomeFilter.isFiltered=condEntry.isFiltered;
        condEntry.falseOutcomeFilter.isJustified=condEntry.isJustified;
        condEntry.falseOutcomeFilter.filterRationale='';

        filteredOutcomes=cv('get',condId,'.filteredOutcomes');
        if isempty(filteredOutcomes)
            return;
        end
        filteredOutcomeModes=cv('get',condId,'.filteredOutcomeModes');
        rat=cvi.ReportUtils.getFilterRationale(condId,true);
        rats=split(string(rat),cvi.ReportUtils.rationaleSeparator);

        fidx=find(filteredOutcomes==1);
        ratIdx=1;
        if~isempty(fidx)
            modeTrue=filteredOutcomeModes(fidx);
            [isFiltered,isJustified]=...
            SlCov.CoverageAPI.filterInheritanceLogic(condEntry.isFiltered,condEntry.isJustified,...
            modeTrue==0,modeTrue==1,...
            condEntry.filterRationale,condEntry.filterRationale);
            condEntry.trueOutcomeFilter.isFiltered=double(isFiltered);
            condEntry.trueOutcomeFilter.isJustified=double(isJustified);
            condEntry.trueOutcomeFilter.filterRationale='';
            if ratIdx<=numel(rats)&&isJustified
                condEntry.trueOutcomeFilter.filterRationale=rats{ratIdx};
                ratIdx=ratIdx+1;
            end
        end
        fidx=find(filteredOutcomes==2);
        if~isempty(fidx)
            modeFalse=filteredOutcomeModes(fidx);
            [isFiltered,isJustified]=...
            SlCov.CoverageAPI.filterInheritanceLogic(condEntry.isFiltered,condEntry.isJustified,...
            modeFalse==0,modeFalse==1,...
            condEntry.filterRationale,condEntry.filterRationale);

            condEntry.falseOutcomeFilter.isJustified=double(isJustified);
            condEntry.falseOutcomeFilter.isFiltered=double(isFiltered);
            condEntry.falseOutcomeFilter.filterRationale='';
            if ratIdx<=numel(rats)&&isJustified
                condEntry.falseOutcomeFilter.filterRationale=rats{ratIdx};
            end

        end



