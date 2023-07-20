function[pwgt,status]=mv_int_by_risk(obj,ProbStruct,riskStd)















    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;
    d=ProbStruct.BaseBound;

    c=[-ProbStruct.RetnLin;0];




    Arisk=[2*ProbStruct.RiskLin;1]';
    brisk=riskStd^2-ProbStruct.RiskScalar;




    fminconOptions=getFminconOptions(obj);

    nonLinObj=@(x)mv_return_as_objective(x,ProbStruct.RetnLin,...
    solver.ObjectiveScalingFactor);

    if~ProbStruct.TEflag


        nonLinConFcn=@(x)mv_risk_as_constraint(x,riskStd,...
        ProbStruct.RiskQuad,ProbStruct.RiskLin,ProbStruct.RiskScalar,...
        solver.NonlinearScalingFactor);
        feasNLCons=@(x)mv_feasibilityRiskConstraint(x,ProbStruct.RiskQuad,...
        ProbStruct.RiskLin,ProbStruct.RiskScalar,riskStd,...
        solver.NonlinearScalingFactor);
    else
        nonLinConFcn=@(x)mv_riskAndTrackingError_as_constraint(x,...
        ProbStruct.RiskQuad,ProbStruct.RiskLin,ProbStruct.RiskScalar,...
        ProbStruct.TeLin,ProbStruct.TeScalar,riskStd,...
        solver.NonlinearScalingFactor);
        feasNLCons=@(x)mv_feasibilityRiskAndTEconstraint(x,...
        ProbStruct.RiskQuad,ProbStruct.RiskLin,ProbStruct.RiskScalar,...
        ProbStruct.TeLin,ProbStruct.TeScalar,riskStd,...
        solver.NonlinearScalingFactor);
    end



    linearRiskCoef.A=[ProbStruct.AteIn;Arisk];
    linearRiskCoef.b=[ProbStruct.bteIn;brisk];



    NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
    ProbStruct.AIn(:,1:end-1),[ProbStruct.bIn],...
    [],[],[ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
    nonLinConFcn,fminconOptions);


    NLPFeasProb=@(intVar,x0)fmincon(@mv_feasibilityObjective,x0,...
    ProbStruct.AIn,ProbStruct.bIn,[],[],...
    [ProbStruct.LB(1:end-1-nAssets);intVar;0],...
    [ProbStruct.UB(1:end-1-nAssets);intVar;Inf],feasNLCons,...
    fminconOptions);


    [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,...
    ProbStruct.NumAssets,c,[ProbStruct.AIn;ProbStruct.AteIn;Arisk],...
    [ProbStruct.bIn;ProbStruct.bteIn;brisk],ProbStruct.AEq,ProbStruct.bEq,...
    ProbStruct.LB,ProbStruct.UB,hasExtraVars,[],ProbStruct.IntVarIndx,...
    NLPfcnHandle,linearRiskCoef,'NLPFeasProb',NLPFeasProb);

    if status==0
        warning(message('finance:Portfolio:mv_int_by_risk:UnconvergedByRiskProblem'));
    end

    if status<0
        error(message('finance:Portfolio:mv_int_by_risk:InfeasibleByRiskProblem'));
    end
    pwgt=pwgt(1:nAssets,:)+d(1:nAssets);
end
