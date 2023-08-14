



function varargout=getMcdcInfo(data,block,varargin)

    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end


    opts=parseQueryFunctionArgs('mcdcinfo',[0,1,1,1],varargin{:});


    if nargin>0
        [~,hasMLCoderCov]=SlCov.CoverageAPI.hasSLOrMLCoderCovData(data);
        if hasMLCoderCov

            if nargin<2
                ids='';
            else
                ids=block;
            end
            [varargout{1:nargout}]=SlCov.CoverageAPI.getMLCoderCoverageInfoInternal(data,'mcdc',ids,opts.CovMode);
            return
        end
    end


    if nargin<2
        error(message('Slvnv:simcoverage:mcdcinfo:AtLeast2Input'));
    end

    [hitNums,metricEnum,blockCvId,dataMat,codeCovRes,justifiedHit,cvd]=cvi.ReportData.getHitCount(data,block,'mcdc',opts.IgnoreDescendants,opts.IncludeAllSizes,opts.CovMode);

    if isempty(hitNums)
        varargout=cell(1,nargout);
        return;
    else
        hitNums(1)=hitNums(1)+justifiedHit;
        varargout{1}=hitNums;
    end


    if nargout>1
        descriptions=[];
        isBlockExcluded=cv('get',blockCvId,'.isDisabled');
        isBlockJustified=cv('get',blockCvId,'.isJustified');
        blockFilterRationale='';
        if isBlockExcluded||isBlockJustified
            blockFilterRationale=cvi.ReportUtils.getFilterRationale(blockCvId);
        end


        if~isempty(codeCovRes)
            if isfield(codeCovRes,'isSFcnBlock')
                filterMode=0;
                if isBlockExcluded
                    filterMode=1;
                elseif isBlockJustified
                    filterMode=2;
                end
                extraArgs={filterMode,blockFilterRationale};
            else
                extraArgs={};
            end
            varargout{2}=cvi.ReportData.getCodeCoverageInfo(codeCovRes,'mcdc',justifiedHit,extraArgs{:});
            return
        end

        mcdcentries=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');

        for mcdcId=mcdcentries(:)'
            mcdcEntry=[];
            mcdcEntry.text=cv('TextOf',mcdcId,-1,[],opts.TextDetailLevel);
            [conditions,achevIdx,truePathIdx,falsePathIdx,activeCondIdx,hasVariableSize]=cv('get',mcdcId...
            ,'.conditions'...
            ,'.dataBaseIdx.predSatisfied'...
            ,'.dataBaseIdx.trueTableEntry'...
            ,'.dataBaseIdx.falseTableEntry'...
            ,'.dataBaseIdx.activeCondIdx'...
            ,'.hasVariableSize');
            isActive=true;
            if hasVariableSize
                maxActiveCondIdx=dataMat(activeCondIdx+1);
                isActive=maxActiveCondIdx>0;
            end


            if isActive||opts.IncludeAllSizes
                for i=1:length(conditions)
                    condId=conditions(i);
                    condEntry.text=SlCov.CoverageAPI.getTextOf(condId,-1,[],opts.TextDetailLevel);
                    condValEnum=dataMat(achevIdx+i,:);
                    condEntry.achieved=condValEnum==SlCov.PredSatisfied.Fully_Satisfied;

                    isActiveCond=true;
                    if hasVariableSize
                        isActiveCond=isActive&&maxActiveCondIdx>=i;
                    end
                    if isActiveCond||opts.IncludeAllSizes
                        switch condValEnum
                        case SlCov.PredSatisfied.Unsatisfied
                            condEntry.trueRslt=['(',cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end)),')'];
                            condEntry.falseRslt=['(',cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end)),')'];
                        case SlCov.PredSatisfied.True_Only
                            condEntry.trueRslt=cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end));
                            condEntry.falseRslt=['(',cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end)),')'];
                        case SlCov.PredSatisfied.False_Only
                            condEntry.trueRslt=['(',cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end)),')'];
                            condEntry.falseRslt=cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end));
                        case SlCov.PredSatisfied.Fully_Satisfied
                            condEntry.trueRslt=cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end));
                            condEntry.falseRslt=cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end));
                        otherwise
                            condEntry.trueRslt='N/A';
                            condEntry.falseRslt='N/A';
                        end

                        if~isActiveCond
                            condEntry.trueRslt=[];
                            condEntry.falseRslt=[];
                        elseif hasVariableSize
                            condEntry.trueRslt=markUnusedConditions(condEntry.trueRslt,conditions,dataMat,opts.IncludeAllSizes);
                            condEntry.falseRslt=markUnusedConditions(condEntry.falseRslt,conditions,dataMat,opts.IncludeAllSizes);
                        end


                        [isPredExcluded,isPredJustified,predFilterRationale]=SlCov.CoverageAPI.checkMcdcPredicateFiltering(...
                        mcdcId,condId,i,...
                        isBlockExcluded,isBlockJustified,blockFilterRationale);

                        condEntry.isFiltered=double(isPredExcluded);
                        condEntry.isJustified=double(isPredJustified);
                        condEntry.filterRationale=predFilterRationale;

                        condEntry.trueRslt=markFilteredConditions(condEntry.trueRslt,conditions,condId);
                        condEntry.falseRslt=markFilteredConditions(condEntry.falseRslt,conditions,condId);

                        if strcmpi(cv('Feature','Trace'),'on')
                            condEntry.trueExecutedIn=cvd.getTraceInfo('mcdcTrue',achevIdx+i);
                            condEntry.falseExecutedIn=cvd.getTraceInfo('mcdcFalse',achevIdx+i);
                        end

                        mcdcEntry.condition(i)=condEntry;
                    end
                end
                if~isBlockExcluded
                    mcdcEntry.isFiltered=all(cv('get',conditions,'.isDisabled'));
                    mcdcEntry.filterRationale=cvi.ReportUtils.getFilterRationale(conditions(1));
                else
                    mcdcEntry.isFiltered=isBlockExcluded;
                    mcdcEntry.filterRationale=blockFilterRationale;
                end
                mcdcEntry.justifiedCoverage=justifiedHit;
                if justifiedHit>0
                    mcdcEntry.filterRationale=cvi.ReportUtils.getFilterRationale(blockCvId);
                end

                if isempty(descriptions)
                    descriptions=mcdcEntry;
                else
                    descriptions(end+1)=mcdcEntry;%#ok<AGROW>
                end
            end
        end

        varargout{2}=descriptions;
    end


    function text=disableText(text,k)
        if strcmpi(text(1),'(')
            k=k+1;
        end
        text(k)='';

        function text=markFilteredConditions(text,subconditions,thisCondId)
            if isempty(text)
                return;
            end
            if cv('get',thisCondId,'.isDisabled')

                text='-';
            else


                for k=1:numel(subconditions)
                    condId=subconditions(k);
                    if cv('get',condId,'.isDisabled')
                        text=disableText(text,k);
                    end
                end
                text=strtrim(text);
            end

            function text=markUnusedConditions(text,subconditions,dataMat,includeAllSizes)

                for k=1:numel(subconditions)
                    condId=subconditions(k);
                    condActiveCondIdx=cv('get',condId,'.coverage.activeCondIdx');
                    if dataMat(condActiveCondIdx+1)==0
                        if includeAllSizes
                            text(k)='-';
                        else
                            disableText(text,k);
                        end
                    end
                end
                text=strtrim(text);


