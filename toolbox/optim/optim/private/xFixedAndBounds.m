function trialStep=xFixedAndBounds(xCurrent,xIndices,trialStep,lb,ub,sizes)















    trialStep.primal(xIndices.fixed)=0.0;
    workArray=xCurrent+trialStep.primal(1:sizes.nVar);
    violatedLowerBnds_idx=workArray(xIndices.finiteLb)<=lb(xIndices.finiteLb);
    violatedUpperBnds_idx=workArray(xIndices.finiteUb)>=ub(xIndices.finiteUb);
    if any(violatedLowerBnds_idx)||any(violatedUpperBnds_idx)
        trialStep.autoReject=true;
    end
