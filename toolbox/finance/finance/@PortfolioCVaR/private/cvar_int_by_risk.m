function[pwgt,status]=cvar_int_by_risk(obj,ProbStruct,risk)















    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;


    c=[-ProbStruct.RetnLin;0];



    Arisk=zeros(1,numel(ProbStruct.LB));
    Arisk(end)=1;
    brisk=risk;


    linearRiskCoef.A=Arisk;
    linearRiskCoef.b=brisk;




    fminconOptions=getFminconOptions(obj);
    Y=obj.localScenarioHandle([],[]);
    plevel=obj.ProbabilityLevel;

    nonLinObj=@(x)cvar_return_as_objective(x,ProbStruct.RetnLin,...
    solver.ObjectiveScalingFactor);
    nonLinConFcn=@(x)cvar_function_as_constraint(x,Y,plevel,brisk,...
    solver.NonlinearScalingFactor);

    NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
    ProbStruct.AIn(:,1:end-1),ProbStruct.bIn,...
    ProbStruct.AEq(:,1:end-1),ProbStruct.bEq,...
    [ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
    nonLinConFcn,fminconOptions);


    feasNLCons=@(x)cvar_feasibilityRiskConstraint(x,Y,plevel,brisk,...
    solver.NonlinearScalingFactor);
    NLPFeasProb=@(intVar,x0)fmincon(@cvar_feasibilityObjective,x0,...
    ProbStruct.AIn,ProbStruct.bIn,ProbStruct.AEq,ProbStruct.bEq,...
    [ProbStruct.LB(1:end-1-nAssets);intVar;0],...
    [ProbStruct.UB(1:end-1-nAssets);intVar;Inf],feasNLCons,...
    fminconOptions);

    [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,ProbStruct.NumAssets,c,...
    [ProbStruct.AIn;Arisk],[ProbStruct.bIn;brisk],...
    ProbStruct.AEq,ProbStruct.bEq,ProbStruct.LB,ProbStruct.UB,...
    hasExtraVars,[],ProbStruct.IntVarIndx,NLPfcnHandle,linearRiskCoef,...
    'NLPFeasProb',NLPFeasProb);

    if status==0
        warning(message('finance:internal:finance:PortfolioMixedInteger:int_by_risk:UnconvergedByRiskProblem'));
    end

    if status<0
        error(message('finance:internal:finance:PortfolioMixedInteger:int_by_risk:InfeasibleByRiskProblem'));
    end
    pwgt=pwgt(1:nAssets,:);
end
