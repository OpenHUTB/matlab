function[mode,switchViolations]=checkFeasibilityMode(trialStep,c_ip,JacTrans_ip,iter,latestPrimalFeasError,switchViolations,sizes,options)















    rhs=norm(c_ip);
    lhs=c_ip+JacTrans_ip'*trialStep.normal;
    lhsEq=norm(lhs(1:sizes.mEq));
    lhsIneq=norm(lhs(sizes.mEq+1:end));



    if lhsEq+lhsIneq>=options.TangentToFeasThresh*rhs...
        &&latestPrimalFeasError(end)>(1-options.InsufInfeasDecrease)*latestPrimalFeasError(end-1)
        switchViolations=switchViolations+1;
    else



        switchViolations=0;
    end

    if iter>options.MinIterToFeasMode&&switchViolations>=options.MinSwitchViolations
        mode='cgfeas';
    else
        mode='cg';
    end
end