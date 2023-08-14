function topCodeDesc=getCodeCoverageInfo(codeCovRes,metricName,justifiedHit,topFilterMode,topRationale)




    if nargin<5
        topRationale='';
    end

    if nargin<4
        topFilterMode=[];
    end

    if nargin<3||isempty(justifiedHit)
        justifiedHit=0;
    end

    if nargin<2
        metricName='';
    end

    block=[];
    objs=[];
    res=[];
    isSFcnBlock=false;
    resObj=codeCovRes;
    if isstruct(codeCovRes)
        if isfield(codeCovRes,'covRes')
            resObj=codeCovRes.covRes;
            if isfield(codeCovRes,'block')
                block=codeCovRes.block;
            end
            if isfield(codeCovRes,'objs')
                objs=codeCovRes.objs;
            end
            if isfield(codeCovRes,'res')
                res=codeCovRes.res;
            end
            if isfield(codeCovRes,'isSFcnBlock')
                isSFcnBlock=codeCovRes.isSFcnBlock;
            end
        end
    end

    if isempty(res)
        res=resObj.getAggregatedResults();
    end

    if isempty(topFilterMode)

        topIsFiltered=1;
        topIsJustified=0;
        topRationale='';
        for obj=objs(:)'
            filterDef=res.getEffectiveFilter(obj);
            if isempty(filterDef)
                topIsFiltered=0;
                topRationale='';
            elseif filterDef.mode==internal.codecov.FilterMode.EXCLUDED
                if isempty(topRationale)
                    topRationale=filterDef.filterRationale;
                end
            elseif filterDef.mode==internal.codecov.FilterMode.JUSTIFIED
                if topIsFiltered
                    topIsFiltered=0;
                    topRationale='';
                end
                topIsJustified=1;
                if isempty(topRationale)
                    topRationale=filterDef.filterRationale;
                end
            end
        end
        topFilterMode=0;
        if topIsFiltered
            topFilterMode=1;
        elseif topIsJustified
            topFilterMode=2;
        end
    else

        topIsFiltered=topFilterMode==1;
        topIsJustified=topFilterMode==2;
    end
    topIsFiltered=double(topIsFiltered);
    topIsJustified=double(topIsJustified);
    topFilterMode=double(topFilterMode);


    if isSFcnBlock&&~topIsFiltered&&topIsJustified
        globalFilterDef=res.getLocalFilter(resObj.CodeTr.Root);
        if isempty(globalFilterDef)||(globalFilterDef.mode~=internal.codecov.FilterMode.JUSTIFIED)
            topRationale='';
        end
    end
    topRationale=cvi.ReportUtils.decodeRationale(topRationale);


    isForSFunBlock=isstruct(codeCovRes)&&isfield(codeCovRes,'sfcnInfo');
    isSLCustomCode=resObj.CodeTr.SourceKind==internal.cxxfe.instrum.SourceKind.SLCustomCode;
    skipFunDetails=isForSFunBlock||isSLCustomCode;


    slModel=resObj.CodeTr.getSLModel();
    addModelElements=SlCov.CovMode.isGeneratedCode(resObj.Mode)&&...
    ~isempty(slModel);
    if addModelElements&&~isempty(block)
        objs=block;
    end


    isOutcomeFiltersEnabled=codeinstrumprivate('feature','enableOutcomeFilters');
    isAggregatedTestEnabled=codeinstrumprivate('feature','enableAggregatedTestInfo')&&...
    (resObj.getNumTests()~=0);

    try
        switch metricName
        case 'decision'
            decCovPts=resObj.CodeTr.getDecisionPoints(objs);

            decCodeDesc=repmat(newCodeDescStruct('d',topFilterMode,addModelElements),1,numel(decCovPts));

            for ii=1:numel(decCovPts)
                decCovPt=decCovPts(ii);
                decCovId=decCovPt.node.covId;
                numDecOutcomes=decCovPt.outcomes.Size();
                outcome=struct('text',cell(1,numDecOutcomes),...
                'executionCount',cell(1,numDecOutcomes),...
                'executedIn',[],...
                'isFiltered',0,...
                'isJustified',0,...
                'filterRationale','');
                numJustifiedUncovered=0;
                for jj=1:numDecOutcomes
                    outcome(jj).executionCount=int64(res.getNumHitsForCovId(decCovPt.outcomes(jj).covId));
                    if outcome(jj).executionCount==0
                        outcomeFilterDef=res.getEffectiveFilter(decCovPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            numJustifiedUncovered=numJustifiedUncovered+1;
                        end
                    end
                    if decCovId==0
                        outcome(jj).text=decCovPt.outcomes(jj).node.getSourceCode();
                    elseif decCovPt.outcomes(jj).covId==decCovId
                        outcome(jj).text='true';
                    else
                        outcome(jj).text='false';
                    end

                    if isAggregatedTestEnabled
                        testInfoSet=res.getTestInfosForOutcome(decCovPt.outcomes(jj));
                        if~isempty(testInfoSet)
                            outcome(jj).executedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                        end
                    end
                end

                decCodeDesc(ii).fileName=decCovPt.node.function.location.file.shortPath;
                decCodeDesc(ii).functionName=decCovPt.node.function.name;
                decCodeDesc(ii).text=decCovPt.node.getSourceCode();
                decCodeDesc(ii).sourceLocation=genSourceLocationStructure(decCovPt.node.startLocation,decCovPt.node.endLocation);
                decCodeDesc(ii).outcome=outcome;

                if int32(decCovPt.node.parentNode.kind)<int32(internal.cxxfe.instrum.ProgramNodeKind.OTHER_STATEMENT)
                    decCodeDesc(ii).kind=decCovPt.node.parentNode.kind.getPublicIdentifier();
                end

                if addModelElements
                    decCodeDesc(ii).modelElements=addModelElementInfo(slModel,decCovPt);
                end

                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(decCovPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                end

                decCodeDesc(ii)=addAnnotationInfo(decCodeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);


                decFilterMode=decCodeDesc(ii).isFiltered+2*decCodeDesc(ii).isJustified>0;
                if isOutcomeFiltersEnabled&&(decFilterMode==0)
                    for jj=1:numDecOutcomes
                        outcomeFilterDef=res.getLocalFilter(decCovPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            decCodeDesc(ii).outcome(jj).isJustified=1;
                            decCodeDesc(ii).outcome(jj).filterRationale=...
                            cvi.ReportUtils.decodeRationale(outcomeFilterDef.filterRationale);
                        end
                    end
                end
            end


            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.decision=removeInternalExclusion(decCodeDesc);

        case 'condition'
            condCovPts=resObj.CodeTr.getConditionPoints(objs);

            codeDesc=repmat(newCodeDescStruct('c',topFilterMode,addModelElements),1,numel(condCovPts));

            for ii=1:numel(condCovPts)
                condCovPt=condCovPts(ii);
                codeDesc(ii).fileName=condCovPt.node.function.location.file.shortPath;
                codeDesc(ii).functionName=condCovPt.node.function.name;
                codeDesc(ii).text=condCovPt.node.getSourceCode();
                codeDesc(ii).sourceLocation=genSourceLocationStructure(condCovPt.node.startLocation,condCovPt.node.endLocation);
                codeDesc(ii).falseCnts=int64(res.getNumHitsForCovId(condCovPt.outcomes(1).covId));
                codeDesc(ii).trueCnts=int64(res.getNumHitsForCovId(condCovPt.outcomes(2).covId));
                codeDesc(ii).trueOutcomeFilter=struct('isFiltered',0,'isJustified',0,'filterRationale','');
                codeDesc(ii).falseOutcomeFilter=codeDesc(ii).trueOutcomeFilter;
                codeDesc(ii).kind=condCovPt.node.parentNode.kind.getPublicIdentifier();

                if addModelElements
                    codeDesc(ii).modelElements=addModelElementInfo(slModel,condCovPt);
                end


                codeDesc(ii).trueExecutedIn=[];
                codeDesc(ii).falseExecutedIn=[];
                if isAggregatedTestEnabled
                    testInfoSet=res.getTestInfosForOutcome(condCovPt.outcomes(1));
                    if~isempty(testInfoSet)
                        codeDesc(ii).falseExecutedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                    end
                    testInfoSet=res.getTestInfosForOutcome(condCovPt.outcomes(2));
                    if~isempty(testInfoSet)
                        codeDesc(ii).trueExecutedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                    end
                end

                numJustifiedUncovered=0;
                if codeDesc(ii).falseCnts==0
                    outcomeFilterDef=res.getEffectiveFilter(condCovPt.outcomes(1));
                    if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        numJustifiedUncovered=numJustifiedUncovered+1;
                    end
                end
                if codeDesc(ii).trueCnts==0
                    outcomeFilterDef=res.getEffectiveFilter(condCovPt.outcomes(2));
                    if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        numJustifiedUncovered=numJustifiedUncovered+1;
                    end
                end

                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(condCovPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                end

                codeDesc(ii)=addAnnotationInfo(codeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);


                condFilterMode=codeDesc(ii).isFiltered+2*codeDesc(ii).isJustified;
                if isOutcomeFiltersEnabled&&(condFilterMode==0)
                    outcomeFilterDef=res.getLocalFilter(condCovPt.outcomes(1));
                    if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        codeDesc(ii).falseOutcomeFilter.isJustified=1;
                        codeDesc(ii).falseOutcomeFilter.filterRationale=...
                        cvi.ReportUtils.decodeRationale(outcomeFilterDef.filterRationale);
                    end
                    outcomeFilterDef=res.getLocalFilter(condCovPt.outcomes(2));
                    if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        codeDesc(ii).trueOutcomeFilter.isJustified=1;
                        codeDesc(ii).trueOutcomeFilter.filterRationale=...
                        cvi.ReportUtils.decodeRationale(outcomeFilterDef.filterRationale);
                    end
                end
            end

            codeDesc=rmfield(codeDesc,'justifiedCoverage');


            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.condition=removeInternalExclusion(codeDesc);

        case 'mcdc'
            mcdcPts=resObj.CodeTr.getMCDCPoints(objs);

            codeDesc=repmat(newCodeDescStruct('m',topFilterMode,addModelElements),1,numel(mcdcPts));

            for ii=1:numel(mcdcPts)
                mcdcPt=mcdcPts(ii);

                condDesc(1:mcdcPt.outcomes.Size())=struct(...
                'text','',...
                'achieved','',...
                'trueRslt','',...
                'falseRslt','',...
                'isFiltered',topIsFiltered,...
                'isJustified',topIsJustified,...
                'filterRationale',topRationale,...
                'trueExecutedIn',[],...
                'falseExecutedIn',[]...
                );

                mcdcResult=res.getMCDCResult(mcdcPt);
                numCols=mcdcPt.outcomes.Size()+1;
                truthTable=mcdcPt.truthTable.toArray();
                truthTable=reshape(truthTable,[mcdcPt.numCombinations,numCols]);

                numJustifiedUncovered=0;
                for jj=1:mcdcPt.outcomes.Size()
                    condDesc(jj).text=mcdcPt.outcomes(jj).node.getSourceCode();
                    condDesc(jj).achieved=mcdcResult.conditions(jj).mcdcOK;
                    if~condDesc(jj).achieved
                        outcomeFilterDef=res.getEffectiveFilter(mcdcPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            numJustifiedUncovered=numJustifiedUncovered+1;
                        end
                    end

                    trueRsltIdx=mcdcResult.conditions(jj).trueRsltCombIdx;
                    numTrueRslt=int64(res.getNumHitsForCovId(mcdcPt.covId+uint32(trueRsltIdx)));
                    trueRslt=truthTable(trueRsltIdx+1,1:end-1);
                    condDesc(jj).trueRslt=genMCDCCombinationStr(trueRslt,numTrueRslt);

                    if isAggregatedTestEnabled
                        testInfoSet=res.getTestInfosForCovId(mcdcPt.covId+uint32(trueRsltIdx));
                        if~isempty(testInfoSet)
                            condDesc(jj).trueExecutedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                        end
                    end

                    falseRsltIdx=mcdcResult.conditions(jj).falseRsltCombIdx;
                    numFalseRslt=int64(res.getNumHitsForCovId(mcdcPt.covId+uint32(falseRsltIdx)));
                    falseRslt=truthTable(falseRsltIdx+1,1:end-1);
                    condDesc(jj).falseRslt=genMCDCCombinationStr(falseRslt,numFalseRslt);

                    if isAggregatedTestEnabled
                        testInfoSet=res.getTestInfosForCovId(mcdcPt.covId+uint32(falseRsltIdx));
                        if~isempty(testInfoSet)
                            condDesc(jj).falseExecutedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                        end
                    end
                end

                codeDesc(ii).fileName=mcdcPt.node.function.location.file.shortPath;
                codeDesc(ii).functionName=mcdcPt.node.function.name;
                codeDesc(ii).text=mcdcPt.node.getSourceCode();
                codeDesc(ii).sourceLocation=genSourceLocationStructure(mcdcPt.node.startLocation,mcdcPt.node.endLocation);
                codeDesc(ii).condition=condDesc;

                if int32(mcdcPt.node.parentNode.kind)<int32(internal.cxxfe.instrum.ProgramNodeKind.OTHER_STATEMENT)
                    codeDesc(ii).kind=mcdcPt.node.parentNode.kind.getPublicIdentifier();
                end

                if addModelElements
                    codeDesc(ii).modelElements=addModelElementInfo(slModel,mcdcPt);
                end

                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(mcdcPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                end

                codeDesc(ii)=addAnnotationInfo(codeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);


                mcdcFilterMode=codeDesc(ii).isFiltered+2*codeDesc(ii).isJustified;
                if isOutcomeFiltersEnabled&&(mcdcFilterMode==0)
                    for jj=1:mcdcPt.outcomes.Size()
                        outcomeFilterDef=res.getLocalFilter(mcdcPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            codeDesc(ii).condition(jj).isJustified=1;
                            codeDesc(ii).condition(jj).filterRationale=...
                            cvi.ReportUtils.decodeRationale(outcomeFilterDef.filterRationale);
                        end
                    end
                end
            end

            codeDesc=rmfield(codeDesc,'justifiedCoverage');

            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.mcdc=removeInternalExclusion(codeDesc);

        case 'cvmetric_Structural_block'
            stmtCovPts=resObj.CodeTr.getStatementPoints(objs);

            execCodeDesc=repmat(newCodeDescStruct('s',topFilterMode,addModelElements,true),...
            1,numel(stmtCovPts));

            for ii=1:numel(stmtCovPts)
                stmtPt=stmtCovPts(ii);
                execCodeDesc(ii).text=message('Slvnv:simcoverage:getCoverageInfo:StatementExecuted').getString();
                execCodeDesc(ii).executionCount=int64(res.getNumHitsForCovId(stmtPt.outcomes(1).covId));
                execCodeDesc(ii).fileName=stmtPt.node.function.location.file.shortPath;
                execCodeDesc(ii).functionName=stmtPt.node.function.name;
                execCodeDesc(ii).sourceLocation=genSourceLocationStructure(stmtPt.node.startLocation,stmtPt.node.endLocation);
                execCodeDesc(ii).kind=stmtPt.node.kind.getPublicIdentifier();

                if addModelElements
                    execCodeDesc(ii).modelElements=addModelElementInfo(slModel,stmtPt);
                end

                numJustifiedUncovered=0;
                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(stmtPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                    if~execCodeDesc(ii).executionCount&&(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        numJustifiedUncovered=1;
                    end
                end

                execCodeDesc(ii)=addAnnotationInfo(execCodeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);
            end


            funCallInfo=[];
            if resObj.isActive(internal.cxxfe.instrum.MetricKind.FUN_CALL)&&~skipFunDetails
                fInfo=cvi.ReportData.getCodeCoverageInfo(codeCovRes,...
                'cvmetric_funcall',justifiedHit,topIsFiltered,topRationale);
                if isfield(fInfo,'testobjects')&&isstruct(fInfo.testobjects)
                    funCallInfo=fInfo.testobjects;
                end
            end


            if~isempty(funCallInfo)
                justifiedHit=justifiedHit+sum([funCallInfo.justifiedCoverage]);
            end

            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.testobjects=removeInternalExclusion(execCodeDesc);


            if~skipFunDetails
                funEntryKind=internal.cxxfe.instrum.ProgramNodeKind.FCN_ENTER.getPublicIdentifier();
                idxFunEntry=strcmp(funEntryKind,{execCodeDesc.kind});
                topCodeDesc.function=execCodeDesc(idxFunEntry);
                topCodeDesc.function=rmfield(topCodeDesc.function,'kind');
                for ii=1:numel(topCodeDesc.function)
                    topCodeDesc.function(ii).text=getString(message('Slvnv:simcoverage:cvhtml:SFcnFunEntry'));
                end
                topCodeDesc.function=removeInternalExclusion(topCodeDesc.function);
                topCodeDesc.functionCall=removeInternalExclusion(funCallInfo);
                topCodeDesc.executableStatement=removeInternalExclusion(execCodeDesc(~idxFunEntry));
            end






            if isForSFunBlock
                mDesc=codeCovRes.sfcnInfo.description;
                if~isempty(mDesc)
                    mDesc.details=execCodeDesc;
                    if~codeCovRes.sfcnInfo.covFromCvEngine
                        mDesc.justifiedCoverage=topCodeDesc.justifiedCoverage;
                    end
                end

                topCodeDesc=mDesc;
            end

        case 'cvmetric_funcall'
            callPts=resObj.CodeTr.getCallPoints(objs);

            execCodeDesc=repmat(newCodeDescStruct('f',topFilterMode,addModelElements),...
            1,numel(callPts));

            for ii=1:numel(callPts)
                callPt=callPts(ii);
                execCodeDesc(ii).text=message('Slvnv:simcoverage:getCoverageInfo:FunctionCalled').getString();
                execCodeDesc(ii).executionCount=int64(res.getNumHitsForCovId(callPt.outcomes(1).covId));
                execCodeDesc(ii).expression=callPt.node.getSourceCode();
                execCodeDesc(ii).fileName=callPt.node.function.location.file.shortPath;
                execCodeDesc(ii).functionName=callPt.node.function.name;
                execCodeDesc(ii).sourceLocation=genSourceLocationStructure(callPt.node.startLocation,callPt.node.endLocation);

                if addModelElements
                    execCodeDesc(ii).modelElements=addModelElementInfo(slModel,callPt);
                end

                numJustifiedUncovered=0;
                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(callPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                    if~execCodeDesc(ii).executionCount&&(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                        numJustifiedUncovered=1;
                    end
                end

                execCodeDesc(ii)=addAnnotationInfo(execCodeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);
            end

            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.testobjects=removeInternalExclusion(execCodeDesc);

        case 'cvmetric_Structural_relationalop'
            relBoundCovPts=resObj.CodeTr.getRelationalBoundaryPoints(objs);

            relOpCodeDesc=repmat(newCodeDescStruct('r',topFilterMode,addModelElements),1,numel(relBoundCovPts));

            for ii=1:numel(relBoundCovPts)
                relBoundCovPt=relBoundCovPts(ii);
                numOutcomes=relBoundCovPt.outcomes.Size();
                if numOutcomes==3
                    outcome=struct('text',{'-1','0','+1'},...
                    'executionCount',num2cell(int64([res.getNumHitsForCovId(relBoundCovPt.outcomes(1).covId),...
                    res.getNumHitsForCovId(relBoundCovPt.outcomes(2).covId),...
                    res.getNumHitsForCovId(relBoundCovPt.outcomes(3).covId)])),...
                    'isFiltered',{0,0,0},...
                    'isJustified',{0,0,0},...
                    'filterRationale',{'','',''},...
                    'executedIn',{[],[],[]});
                else
                    switch relBoundCovPt.node.kind
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_EQ,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_NE}
                        outcomesText={'[-tol..0)','(0..tol]'};
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_GT,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_LE}
                        outcomesText={'[-tol..0]','(0..tol]'};
                    case{internal.cxxfe.instrum.ProgramNodeKind.FLOAT_LT,...
                        internal.cxxfe.instrum.ProgramNodeKind.FLOAT_GE}
                        outcomesText={'[-tol..0)','[0..tol]'};
                    otherwise

                        assert(false);
                    end
                    outcome=struct('text',outcomesText,...
                    'executionCount',num2cell(int64([res.getNumHitsForCovId(relBoundCovPt.outcomes(1).covId),...
                    res.getNumHitsForCovId(relBoundCovPt.outcomes(2).covId)])),...
                    'isFiltered',{0,0},...
                    'isJustified',{0,0},...
                    'filterRationale',{'',''},...
                    'executedIn',{[],[]});
                end
                relOpCodeDesc(ii).fileName=relBoundCovPt.node.function.location.file.shortPath;
                relOpCodeDesc(ii).functionName=relBoundCovPt.node.function.name;
                relOpCodeDesc(ii).text=[relBoundCovPt.node.subNodes(1).getSourceCode(),' - ',relBoundCovPt.node.subNodes(2).getSourceCode()];
                relOpCodeDesc(ii).sourceLocation=genSourceLocationStructure(relBoundCovPt.node.subNodes(1).startLocation,...
                relBoundCovPt.node.subNodes(2).endLocation);
                relOpCodeDesc(ii).outcome=outcome;

                numJustifiedUncovered=0;
                for jj=1:numOutcomes
                    if~res.getNumHitsForCovId(relBoundCovPt.outcomes(jj).covId)
                        outcomeFilterDef=res.getEffectiveFilter(relBoundCovPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            numJustifiedUncovered=numJustifiedUncovered+1;
                        end
                    end
                end

                filterMode=0;
                filterRationale='';
                filterDef=res.getEffectiveFilter(relBoundCovPt);
                if~isempty(filterDef)
                    filterMode=double(filterDef.mode==internal.codecov.FilterMode.EXCLUDED)+...
                    2*double(filterDef.mode==internal.codecov.FilterMode.JUSTIFIED);
                    filterRationale=filterDef.filterRationale;
                end

                relOpCodeDesc(ii)=addAnnotationInfo(relOpCodeDesc(ii),...
                topFilterMode,topRationale,justifiedHit,...
                filterMode,filterRationale,...
                numJustifiedUncovered);


                relopFilterMode=relOpCodeDesc(ii).isFiltered+2*relOpCodeDesc(ii).isJustified;
                if isOutcomeFiltersEnabled&&(relopFilterMode==0)
                    for jj=1:numOutcomes
                        outcomeFilterDef=res.getLocalFilter(relBoundCovPt.outcomes(jj));
                        if~isempty(outcomeFilterDef)&&(outcomeFilterDef.mode==internal.codecov.FilterMode.JUSTIFIED)
                            relOpCodeDesc(ii).outcome(jj).isJustified=1;
                            relOpCodeDesc(ii).outcome(jj).filterRationale=...
                            cvi.ReportUtils.decodeRationale(outcomeFilterDef.filterRationale);
                        end
                    end
                end


                if isAggregatedTestEnabled
                    for jj=1:numOutcomes
                        testInfoSet=res.getTestInfosForOutcome(relBoundCovPt.outcomes(jj));
                        if~isempty(testInfoSet)
                            relOpCodeDesc(ii).outcome(jj).executedIn=codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure(testInfoSet.tests);
                        end
                    end
                end
            end

            topCodeDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit);
            topCodeDesc.testobjects=removeInternalExclusion(relOpCodeDesc);

        otherwise

            topCodeDesc=struct([]);
            return
        end
    catch Mex

        rethrow(Mex);
    end

    function rsltStr=genMCDCCombinationStr(rslt,numRslt)
        rsltStr=char(zeros(1,numel(rslt)));
        rsltStr(rslt==1)='T';
        rsltStr(rslt==0)='F';
        rsltStr(rslt<0)='x';
        if numRslt==0
            rsltStr=['(',rsltStr,')'];
        end
    end

    function posStruct=genSourceLocationStructure(startLocation,endLocation)
        startLineNum=0;
        startColNum=0;
        if~isempty(startLocation)
            startLineNum=startLocation.lineNum;
            startColNum=startLocation.colNum;
        end
        endLineNum=0;
        endColNum=0;
        if~isempty(endLocation)
            endLineNum=endLocation.lineNum;
            endColNum=endLocation.colNum;
        end
        posStruct=struct('startLine',int64(startLineNum),'startCol',int64(startColNum),...
        'endLine',int64(endLineNum),'endCol',int64(endColNum));
    end
end


function topDesc=newTopDescStruct(topFilterMode,topRationale,justifiedHit)

    topDesc.isFiltered=double(topFilterMode==1);
    topDesc.justifiedCoverage=justifiedHit;
    topDesc.isJustified=double(topFilterMode==2);
    topDesc.filterRationale='';
    if topDesc.isFiltered||topDesc.isJustified
        topDesc.filterRationale=topRationale;
    end

end


function descStruct=newCodeDescStruct(kind,topFilterMode,addModelElements,addKind)

    if nargin<4
        addKind=false;
    end

    descStruct=newTopDescStruct(topFilterMode,'',0);
    descStruct.text='';

    switch kind
    case{'d','r'}

        descStruct.outcome=[];

    case{'s','f'}

        descStruct.executionCount=[];

    case 'c'

        descStruct.trueCnts=[];
        descStruct.falseCnts=[];

    case 'm'

        descStruct.condition=[];
    end

    descStruct.filterRationale='';
    descStruct.fileName='';
    descStruct.functionName='';
    descStruct.sourceLocation=[];
    if kind=='f'
        descStruct.expression='';
    end
    if addKind
        descStruct.kind='';
    end
    if addModelElements
        descStruct.modelElements=[];
    end
end


function codeDesc=addAnnotationInfo(codeDesc,topFilterMode,topRationale,topJustifiedHit,locFilterMode,locRational,locJustifiedHit)


    [codeDesc.isFiltered,codeDesc.isJustified,codeDesc.filterRationale]=...
    resolveFilterInfo(topFilterMode,topRationale,locFilterMode,locRational);

    if topFilterMode>0

        codeDesc.justifiedCoverage=topJustifiedHit;
    else

        codeDesc.justifiedCoverage=locJustifiedHit;
    end

end


function[isFiltered,isJustified,rationale]=resolveFilterInfo(topFilterMode,topRationale,locFilterMode,locRational)

    if(topFilterMode>0)&&~isempty(topRationale)
        isFiltered=double(topFilterMode==1);
        isJustified=double(topFilterMode==2);
        rationale=cvi.ReportUtils.decodeRationale(topRationale);
    else
        isFiltered=double(locFilterMode==1);
        isJustified=double(locFilterMode==2);
        rationale=cvi.ReportUtils.decodeRationale(locRational);
    end

end


function modelElements=addModelElementInfo(slModel,covPt)

    modelElements=[];
    entry=slModel.covPtToSLModelElemsMap.getByKey(covPt.UUID);
    if~isempty(entry)
        numModelElements=entry.slModelElements.Size();
        modelElements=cell(1,numModelElements);
        try
            for ii=1:numModelElements
                modelElements{ii}=Simulink.ID.getFullName(covPt.slModelElements(ii).sid);
            end
        catch
            modelElements=[];
        end
    end

end


function codeDesc=removeInternalExclusion(codeDesc)

    persistent msgExclusion;
    if isempty(msgExclusion)
        msgExclusion=getString(message('CodeInstrumentation:instrumenter:excludedInternallyHidden'));
    end

    if isempty(codeDesc)||...
        ~isstruct(codeDesc)||...
        ~isfield(codeDesc(1),'isFiltered')||...
        ~isfield(codeDesc(1),'filterRationale')
        return
    end

    codeDesc(strcmp({codeDesc.filterRationale},msgExclusion))=[];

end



