




classdef CovDataReader<handle

    properties(SetAccess=protected,GetAccess=public,Hidden=true)



Id2CovInfo



Id2CovFilterInfo



Id2CovInternalFilterInfo



        IsUnknownIdCovered logical=false


        CovFilterObj=[]
    end

    methods



        function this=CovDataReader(covFilterObj)
            narginchk(0,1);

            this.Id2CovInfo=containers.Map('KeyType','char','ValueType','any');
            this.Id2CovFilterInfo=containers.Map('KeyType','char','ValueType','any');
            this.Id2CovInternalFilterInfo=containers.Map('KeyType','char','ValueType','any');


            if nargin==1&&~isempty(covFilterObj)&&...
                (isa(covFilterObj,'SlCov.FilterEditor')||isa(covFilterObj,'Sldv.Filter'))
                try

                    covFilterObj.getAllCodeInfo();
                    this.CovFilterObj=covFilterObj;
                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery')
                        rethrow(ME);
                    end

                    this.CovFilterObj=[];
                end
            end
        end






        function status=isExcludedInternally(this,blkH,covId,moduleName)

            if nargin<4
                moduleName='';
            end


            status=false;

            try

                codeFilterData=this.getCodeFilterInternalExclusionData(blkH,moduleName,covId);
                if~isempty(codeFilterData)
                    if codeFilterData.FilterInfoIds.isKey(covId)
                        status=true;
                        return
                    end
                end
            catch

            end
        end






        function status=isMcdcExcludedInternally(this,blkH,decId,condId,moduleName)

            if nargin<5
                moduleName='';
            end


            status=false;

            try

                codeFilterData=this.getCodeFilterInternalExclusionData(blkH,moduleName,decId);
                if~isempty(codeFilterData)
                    if codeFilterData.FilterInfoMCDC.isKey(decId)
                        status=true;
                        return
                    end

                    if codeFilterData.FilterInfoMCDCCond.isKey(condId)
                        status=true;
                        return
                    end
                end
            catch

            end
        end




        function[status,filterInfo]=isFiltered(this,blkH,covId,moduleName)


            if nargin<4
                moduleName='';
            end


            status=false;
            filterInfo=sldv.code.internal.CovDataReader.newFilterInfo();

            try

                codeFilterData=this.getCodeFilterData(blkH,moduleName,covId);
                if~isempty(codeFilterData)
                    if~isempty(blkH)&&is_simulink_handle(blkH)&&codeFilterData.FilterInfoByHandle.isKey(blkH)
                        status=true;
                        filterInfo=codeFilterData.FilterInfoByHandle(blkH);
                        return
                    end
                    if codeFilterData.FilterInfoIds.isKey(covId)
                        status=true;
                        filterInfo=codeFilterData.FilterInfoIds(covId);
                        return
                    end
                end
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end

            end
        end





        function[status,filterInfo]=isMcdcFiltered(this,blkH,decId,condId,moduleName)


            if nargin<5
                moduleName='';
            end


            status=false;
            filterInfo=sldv.code.internal.CovDataReader.newFilterInfo();

            try

                codeFilterData=this.getCodeFilterData(blkH,moduleName,decId);
                if~isempty(codeFilterData)
                    if~isempty(blkH)&&is_simulink_handle(blkH)&&codeFilterData.FilterInfoByHandle.isKey(blkH)
                        status=true;
                        filterInfo=codeFilterData.FilterInfoByHandle(blkH);
                        return
                    end
                    if codeFilterData.FilterInfoMCDC.isKey(decId)
                        status=true;
                        filterInfo=codeFilterData.FilterInfoMCDC(decId);
                        return
                    end

                    if codeFilterData.FilterInfoMCDCCond.isKey(condId)
                        status=true;
                        filterInfo=codeFilterData.FilterInfoMCDCCond(condId);
                        return
                    end
                end
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end

            end
        end






        function[isCovered,hasCoverage,filterInfo]=isCovered(this,blkH,covData,covId,moduleName)
            hasCoverage=false;
            filterInfo=sldv.code.internal.CovDataReader.newFilterInfo();

            if nargin<5
                moduleName='';
            end
            try
                codeCovData=this.getCodeCovData(blkH,covData,moduleName,covId);
                if isempty(codeCovData)

                    isCovered=this.IsUnknownIdCovered;
                else
                    isCovered=any(codeCovData.CoveredIds==covId);
                    hasCoverage=true;
                    if codeCovData.FilterInfoIds.isKey(covId)
                        isCovered=true;
                        filterInfo=codeCovData.FilterInfoIds(covId);
                    end
                end
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                isCovered=this.IsUnknownIdCovered;
            end
        end






        function[isCovered,hasCoverage,filterInfo]=isMcdcCovered(this,blkH,covData,decId,condId,moduleName)
            hasCoverage=false;
            filterInfo=sldv.code.internal.CovDataReader.newFilterInfo();

            if nargin<6
                moduleName='';
            end
            try
                isCovered=false;
                codeCovData=this.getCodeCovData(blkH,covData,moduleName,decId);
                if isempty(codeCovData)

                    isCovered=this.IsUnknownIdCovered;
                elseif codeCovData.CoveredMCDC.isKey(decId)
                    coveredConditions=codeCovData.CoveredMCDC(decId);
                    isCovered=any(coveredConditions==condId);
                    hasCoverage=true;
                    if codeCovData.FilterInfoMCDC.isKey(decId)
                        isCovered=true;
                        filterInfo=codeCovData.FilterInfoMCDC(decId);
                    end
                end
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                isCovered=this.IsUnknownIdCovered;
            end
        end
    end

    methods(Abstract,Access=protected)



        codeCovData=getCodeCovData(this,blkH,covData,moduleName,covOrDecId)




        codeFilterData=getCodeFilterData(this,blkH,moduleName,covOrDecId)




        codeFilterData=getCodeFilterInternalExclusionData(this,blkH,moduleName,covOrDecId)
    end

    methods(Static,Access=protected)



        function filterInfo=newFilterInfo(isFiltered,mode,rational)
            if nargin<3
                rational='';
            end
            if nargin<2
                mode=-1;
            end
            if nargin<1
                isFiltered=false;
            end
            filterInfo.isFiltered=logical(isFiltered);
            filterInfo.mode=double(mode);
            filterInfo.rationale=rational;
        end




        function instanceInfo=getInstanceCovDataInfo(codeCovData,instIdx)
            res=codeCovData.getInstanceResults(instIdx);


            instanceInfo=sldv.code.internal.CovDataReader.newInstanceCovDataInfo();

            if codeCovData.isActive(internal.cxxfe.instrum.MetricKind.CONDITION)
                condCovPts=codeCovData.CodeTr.getConditionPoints(codeCovData.CodeTr.Root);
                coveredConditions=zeros(numel(condCovPts)*2,1);
                for ii=1:numel(condCovPts)
                    condCovPt=condCovPts(ii);
                    for jj=1:2
                        instrPt=condCovPt.outcomes(jj);
                        if res.getNumHitsForCovId(instrPt.covId)>0
                            coveredConditions((ii-1)*2+jj)=instrPt.covId;
                        else
                            filterDef=res.getEffectiveFilter(instrPt);
                            if~isempty(filterDef)
                                filterInfo=sldv.code.internal.CovDataReader.newFilterInfo(...
                                true,(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED),filterDef.filterRationale);
                                instanceInfo.FilterInfoIds(instrPt.covId)=filterInfo;
                            end
                        end
                    end
                end
                coveredConditions(coveredConditions==0)=[];
            else
                coveredConditions=[];
            end


            if codeCovData.isActive(internal.cxxfe.instrum.MetricKind.DECISION)
                decCovPts=codeCovData.CodeTr.getDecisionPoints(codeCovData.CodeTr.Root);
                coveredDecisions=zeros(numel(decCovPts)*2,1);
                numDecOutcomes=0;
                for ii=1:numel(decCovPts)
                    decCovPt=decCovPts(ii);
                    for jj=1:decCovPt.outcomes.Size()
                        instrPt=decCovPt.outcomes(jj);
                        if res.getNumHitsForCovId(instrPt.covId)>0
                            numDecOutcomes=numDecOutcomes+1;
                            coveredDecisions(numDecOutcomes)=instrPt.covId;
                        else
                            filterDef=res.getEffectiveFilter(instrPt);
                            if~isempty(filterDef)
                                filterInfo=sldv.code.internal.CovDataReader.newFilterInfo(...
                                true,(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED),filterDef.filterRationale);
                                instanceInfo.FilterInfoIds(instrPt.covId)=filterInfo;
                            end
                        end
                    end
                end
                coveredDecisions(coveredDecisions==0)=[];
            else
                coveredDecisions=[];
            end


            if codeCovData.isActive(internal.cxxfe.instrum.MetricKind.RELATIONAL_BOUNDARY)
                relOpCovPts=codeCovData.CodeTr.getRelationalBoundaryPoints(codeCovData.CodeTr.Root);
                coveredRelationalBoundaries=zeros(numel(relOpCovPts)*3,1);
                numRelOpOutcomes=0;
                for ii=1:numel(relOpCovPts)
                    relOpCovPt=relOpCovPts(ii);
                    for jj=1:relOpCovPt.outcomes.Size()
                        instrPt=relOpCovPt.outcomes(jj);
                        if res.getNumHitsForCovId(instrPt.covId)>0
                            numRelOpOutcomes=numRelOpOutcomes+1;
                            coveredRelationalBoundaries(numRelOpOutcomes)=instrPt.covId;
                        else
                            filterDef=res.getEffectiveFilter(instrPt);
                            if~isempty(filterDef)
                                filterInfo=sldv.code.internal.CovDataReader.newFilterInfo(...
                                true,(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED),filterDef.filterRationale);
                                instanceInfo.FilterInfoIds(instrPt.covId)=filterInfo;
                            end
                        end
                    end
                end
                coveredRelationalBoundaries(coveredRelationalBoundaries==0)=[];
            else
                coveredRelationalBoundaries=[];
            end
            instanceInfo.CoveredIds=[coveredConditions;coveredDecisions;coveredRelationalBoundaries];


            if codeCovData.isActive(internal.cxxfe.instrum.MetricKind.MCDC)
                mcdcCovPts=codeCovData.CodeTr.getMCDCPoints(codeCovData.CodeTr.Root);
                for m=1:numel(mcdcCovPts)
                    mcdcCovPt=mcdcCovPts(m);
                    currentCovId=mcdcCovPt.node.covId;



                    filterDef=res.getEffectiveFilter(mcdcCovPt);
                    if~isempty(filterDef)
                        filterInfo=sldv.code.internal.CovDataReader.newFilterInfo(...
                        true,(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED),...
                        filterDef.filterRationale);
                        instanceInfo.FilterInfoMCDC(currentCovId)=filterInfo;
                    end

                    conditions=[];
                    for c=1:mcdcCovPt.outcomes.Size()
                        instrPt=mcdcCovPt.outcomes(c);
                        id=instrPt.node.covId;
                        if res.getNumHitsForCovId(id)>0||res.getNumHitsForCovId(id+1)>0
                            if res.getNumHitsForCovId(id)>0
                                conditions=[conditions,id];%#ok
                            end
                            if res.getNumHitsForCovId(id+1)>0
                                conditions=[conditions,(id+1)];%#ok
                            end
                        elseif isempty(filterDef)

                            outcomeFilterDef=res.getEffectiveFilter(instrPt);
                            if~isempty(outcomeFilterDef)
                                filterInfo=sldv.code.internal.CovDataReader.newFilterInfo(...
                                true,(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED),outcomeFilterDef.filterRationale);
                                covId=instrPt.node.covId;

                                instanceInfo.FilterInfoMCDCCond(covId)=filterInfo;
                                instanceInfo.FilterInfoMCDCCond(covId+1)=filterInfo;
                            end
                        end
                    end

                    if~isempty(conditions)
                        instanceInfo.CoveredMCDC(currentCovId)=conditions;
                    end
                end
            end
        end




        function instanceInfo=newInstanceCovDataInfo()
            instanceInfo=struct(...
            'CoveredIds',[],...
            'CoveredMCDC',containers.Map('KeyType','int64','ValueType','any'),...
            'FilterInfoByHandle',containers.Map('KeyType','double','ValueType','any'),...
            'FilterInfoIds',containers.Map('KeyType','int64','ValueType','any'),...
            'FilterInfoMCDC',containers.Map('KeyType','int64','ValueType','any'),...
            'FilterInfoMCDCCond',containers.Map('KeyType','int64','ValueType','any')...
            );
        end
    end
end


