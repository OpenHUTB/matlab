function[pwgt,status]=cvar_int_max_return(obj,ProbStruct)













    solver=obj.solverMINLP;
    nAssets=ProbStruct.NumAssets;


    c=[-ProbStruct.RetnLin;0];
    [pwgt,~,status]=intlinprog(c(1:end-1),ProbStruct.IntVarIndx,...
    ProbStruct.AIn(:,1:end-1),ProbStruct.bIn,[],[],...
    ProbStruct.LB(1:end-1),ProbStruct.UB(1:end-1),...
    solver.IntMasterSolverOptions);

    if status==0
        warning(message('finance:internal:finance:PortfolioMixedInteger:int_max_return:UnconvergedMaxRetnProblem'));
    end

    if status<0
        error(message('finance:internal:finance:PortfolioMixedInteger:int_max_return:InfeasibleMaxRetnProblem'));
    end
    pwgt=pwgt(1:nAssets);
end