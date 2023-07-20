function[pwgt,status]=cvar_int_min_risk(obj,ProbStruct)













    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;


    c=zeros(numel(ProbStruct.LB),1);
    c(end)=1;


    linearRiskCoef=[];



    fminconOptions=getFminconOptions(obj);
    Y=obj.localScenarioHandle([],[]);
    plevel=obj.ProbabilityLevel;

    nonLinObj=@(x)cvar_function_as_objective(x,Y,plevel,...
    solver.ObjectiveScalingFactor);
    NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
    ProbStruct.AIn(:,1:end-1),ProbStruct.bIn,...
    ProbStruct.AEq(:,1:end-1),ProbStruct.bEq,...
    [ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
    [],fminconOptions);

    [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,ProbStruct.NumAssets,c,...
    [ProbStruct.AIn],[ProbStruct.bIn],...
    ProbStruct.AEq,ProbStruct.bEq,ProbStruct.LB,ProbStruct.UB,...
    hasExtraVars,[],ProbStruct.IntVarIndx,NLPfcnHandle,linearRiskCoef);

    if status==0
        warning(message('finance:internal:finance:PortfolioMixedInteger:int_min_risk:UnconvergedMinRiskProblem'));
    end

    if status<0
        error(message('finance:internal:finance:PortfolioMixedInteger:int_min_risk:InfeasibleMinRiskProblem'));
    end
    pwgt=pwgt(1:nAssets,:);

end
