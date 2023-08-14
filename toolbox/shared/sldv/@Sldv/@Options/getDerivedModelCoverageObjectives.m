function mdlCovObjs=getDerivedModelCoverageObjectives(this)




    mode=this.Mode;
    if strcmp(mode,'TestGeneration')
        mdlCovObjs=this.ModelCoverageObjectives;
        if strcmp(mdlCovObjs,'EnhancedMCDC')
            mdlCovObjs='MCDC';
        end
    elseif strcmp(mode,'DesignErrorDetection')&&strcmp(this.DetectDeadLogic,'on')
        if slfeature('SldvMcdcInDeadLogic')
            mdlCovObjs=this.DeadLogicObjectives;
        else
            mdlCovObjs='ConditionDecision';
        end
    else
        mdlCovObjs='None';
    end
end
