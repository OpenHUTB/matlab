function setDecisionOutcomeFilter(this,id,objectiveIdx,outcomeIdx,outcomeMode,rationale,varargin)






    descr=[];
    if~isempty(varargin)
        descr=varargin{1};
    end

    this.addMetricFilter(id,'decision',objectiveIdx,outcomeIdx,outcomeMode,rationale,descr);





