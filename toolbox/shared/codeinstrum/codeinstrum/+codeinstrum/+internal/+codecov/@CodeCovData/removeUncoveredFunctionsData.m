



function removeUncoveredFunctionsData(this)


    if~this.isActive(internal.cxxfe.instrum.MetricKind.FUN_ENTRY)
        return
    end

    res=this.getAggregatedResults();

    funEntryCovPts=this.CodeTr.getFunEntryPoints(this.CodeTr.Root);

    for ii=1:numel(funEntryCovPts)
        funEntryCovPt=funEntryCovPts(ii);
        numHits=res.getNumHitsForOutcome(funEntryCovPt.outcomes(1));
        if numHits==0
            fcn=funEntryCovPt.node.function;
            covPts=[this.CodeTr.getStatementPoints(fcn)...
            ,this.CodeTr.getCallPoints(fcn)...
            ,this.CodeTr.getFunExitPoints(fcn)...
            ,this.CodeTr.getDecisionPoints(fcn)...
            ,this.CodeTr.getMCDCPoints(fcn)...
            ,this.CodeTr.getConditionPoints(fcn)...
            ,this.CodeTr.getRelationalBoundaryPoints(fcn)];
            msgExclusion=getString(message('CodeInstrumentation:instrumenter:excludedInternallyHidden'));
            for jj=1:numel(covPts)
                for instIdx=1:this.getNumInstances()
                    this.CodeCovDataImpl.addFilter(instIdx,...
                    internal.codecov.FilterKind.FUNCTION,...
                    internal.codecov.FilterSource.INTERNAL,...
                    internal.codecov.FilterMode.EXCLUDED,msgExclusion,covPts(jj));
                end
            end
        end
    end

end
