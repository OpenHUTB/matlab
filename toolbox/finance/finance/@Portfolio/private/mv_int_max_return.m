function[pwgt,status]=mv_int_max_return(obj,ProbStruct)













    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;
    d=ProbStruct.BaseBound;


    c=[-ProbStruct.RetnLin;0];
    if~ProbStruct.TEflag
        [pwgt,~,status]=intlinprog(c(1:end-1),ProbStruct.IntVarIndx,...
        ProbStruct.AIn(:,1:end-1),ProbStruct.bIn,[],[],...
        ProbStruct.LB(1:end-1),ProbStruct.UB(1:end-1),...
        solver.IntMasterSolverOptions);
    else



        linearRiskCoef.A=ProbStruct.AteIn;
        linearRiskCoef.b=ProbStruct.bteIn;



        fminconOptions=getFminconOptions(obj);

        nonLinObj=@(x)mv_return_as_objective(x,ProbStruct.RetnLin,...
        solver.ObjectiveScalingFactor);
        nonLinConFcn=@(x)mv_tracking_error_as_constraint(x,...
        ProbStruct.RiskQuad,ProbStruct.TeLin,ProbStruct.TeScalar,...
        solver.NonlinearScalingFactor);
        NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
        ProbStruct.AIn(:,1:end-1),ProbStruct.bIn,...
        [],[],[ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
        nonLinConFcn,fminconOptions);


        feasNLCons=@(x)mv_feasibilityTEconstraint(x,ProbStruct.RiskQuad,...
        ProbStruct.TeLin,ProbStruct.TeScalar,...
        solver.NonlinearScalingFactor);
        NLPFeasProb=@(intVar,x0)fmincon(@mv_feasibilityObjective,x0,...
        ProbStruct.AIn,ProbStruct.bIn,[],[],...
        [ProbStruct.LB(1:end-1-nAssets);intVar;0],...
        [ProbStruct.UB(1:end-1-nAssets);intVar;Inf],feasNLCons,...
        fminconOptions);


        [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,...
        ProbStruct.NumAssets,c,[ProbStruct.AIn;ProbStruct.AteIn],...
        [ProbStruct.bIn;ProbStruct.bteIn],ProbStruct.AEq,ProbStruct.bEq,...
        ProbStruct.LB,ProbStruct.UB,hasExtraVars,[],ProbStruct.IntVarIndx,...
        NLPfcnHandle,linearRiskCoef,'NLPFeasProb',NLPFeasProb);
    end

    if status==0
        warning(message('finance:Portfolio:mv_int_max_return:UnconvergedMaxRetnProblem'));
    end

    if status<0
        error(message('finance:Portfolio:mv_int_max_return:InfeasibleMaxRetnProblem'));
    end
    pwgt=pwgt(1:nAssets,:)+d(1:nAssets);
end
