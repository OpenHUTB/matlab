function setConditionOutcomeFilter(this,id,objectiveIdx,outcomeIdx,outcomeMode,rationale,varargin)






    descr=[];
    if~isempty(varargin)
        descr=varargin{1};
    end
    this.addMetricFilter(id,'condition',objectiveIdx,outcomeIdx,outcomeMode,rationale,descr);





