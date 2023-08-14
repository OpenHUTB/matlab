function[pwgt,status]=mv_int_by_return(obj,ProbStruct,retn)














    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;
    d=ProbStruct.BaseBound;


    c=[ProbStruct.RiskLin;0.5];



    Aretn=[-ProbStruct.RetnLin;0]';
    bretn=-retn+ProbStruct.RetnScalar;

    if~ProbStruct.TEflag



        linearRiskCoef=[];

        quadoptions=getQuadprogOptions(obj);
        NLPfcnHandle=@(intVar,x0)quadprog(...
        ProbStruct.RiskQuad,ProbStruct.RiskLin,...
        [ProbStruct.AIn(:,1:end-1);Aretn(:,1:end-1)],...
        [ProbStruct.bIn;bretn],[],[],...
        [ProbStruct.LB(1:end-1-nAssets);intVar],...
        [ProbStruct.UB(1:end-1-nAssets);intVar],x0,quadoptions);
        [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,ProbStruct.NumAssets,c,...
        [ProbStruct.AIn;Aretn],[ProbStruct.bIn;bretn],...
        ProbStruct.AEq,ProbStruct.bEq,ProbStruct.LB,ProbStruct.UB,...
        hasExtraVars,[],ProbStruct.IntVarIndx,NLPfcnHandle,linearRiskCoef);
    else



        linearRiskCoef.A=ProbStruct.AteIn;
        linearRiskCoef.b=ProbStruct.bteIn;



        fminconOptions=getFminconOptions(obj);

        nonLinObj=@(x)mv_risk_as_objective(x,ProbStruct.RiskQuad,...
        ProbStruct.RiskLin,solver.ObjectiveScalingFactor);
        nonLinConFcn=@(x)mv_tracking_error_as_constraint(x,...
        ProbStruct.RiskQuad,ProbStruct.TeLin,ProbStruct.TeScalar,...
        solver.NonlinearScalingFactor);

        NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
        [ProbStruct.AIn(:,1:end-1);Aretn(:,1:end-1)],[ProbStruct.bIn;bretn],...
        [],[],[ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
        nonLinConFcn,fminconOptions);


        feasNLCons=@(x)mv_feasibilityTEconstraint(x,ProbStruct.RiskQuad,...
        ProbStruct.TeLin,ProbStruct.TeScalar,...
        solver.NonlinearScalingFactor);
        NLPFeasProb=@(intVar,x0)fmincon(@mv_feasibilityObjective,x0,...
        [ProbStruct.AIn;Aretn],[ProbStruct.bIn;bretn],[],[],...
        [ProbStruct.LB(1:end-1-nAssets);intVar;0],...
        [ProbStruct.UB(1:end-1-nAssets);intVar;Inf],feasNLCons,...
        fminconOptions);


        [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,...
        ProbStruct.NumAssets,c,[ProbStruct.AIn;ProbStruct.AteIn;Aretn],...
        [ProbStruct.bIn;ProbStruct.bteIn;bretn],ProbStruct.AEq,ProbStruct.bEq,...
        ProbStruct.LB,ProbStruct.UB,hasExtraVars,[],ProbStruct.IntVarIndx,...
        NLPfcnHandle,linearRiskCoef,'NLPFeasProb',NLPFeasProb);
    end

    if status==0
        warning(message('finance:Portfolio:mv_int_by_return:UnconvergedByRetnProblem'));
    end

    if status<0
        error(message('finance:Portfolio:mv_int_by_return:InfeasibleByRetnProblem'));
    end
    pwgt=pwgt(1:nAssets,:)+d(1:nAssets);
end
