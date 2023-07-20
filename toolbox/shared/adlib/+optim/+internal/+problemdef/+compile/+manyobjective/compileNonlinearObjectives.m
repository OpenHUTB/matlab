function[compiledNonlinFun,compiledNonlinJac,...
    probStruct,extraParams,PkgBlock,jointFunAndGrad]=...
    compileNonlinearObjectives(objectives,...
    prob,probStruct,extraParams,extraParamsName,idxObjectives,idxVector,...
    objValue,gradientValue,inMemory)












    IsEquationProblem=isa(prob,'optim.problemdef.EquationProblem');
    JacobianRequired=IsEquationProblem;
    PkgBlock="";


    isFinDiff=strcmpi(probStruct.objectiveDerivative,"finite-differences");
    if isFinDiff
        [compiledNonlinFun,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstr(objectives,...
        idxObjectives.Nonlinear,idxVector,objValue,...
        probStruct.subfun,extraParams,extraParamsName,inMemory,...
        prob.GeneratedFileFolder,isObjectiveMax(prob));
        compiledNonlinJac="";
        jointFunAndGrad=false;
    else

        VarsJacobians=optim.internal.problemdef.compile.compileVariableJacobians(prob,probStruct.NumVars)+newline;

        switch probStruct.objectiveDerivative
        case "forward-AD"
            compilefun=@compileForwardAD;
            jointFunAndGrad=true;
        case "reverse-AD"
            compilefun=@compileReverseAD;
            VarsJacobians="";
            jointFunAndGrad=false;
        end


        [compiledNonlinFun,compiledNonlinJac,pkgDependsEq,...
        extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstrWithAD(objectives,...
        compilefun,jointFunAndGrad,probStruct.NumVars,idxObjectives.Nonlinear,...
        idxVector,objValue,gradientValue,probStruct.subfun,extraParams,...
        extraParamsName,inMemory,prob.GeneratedFileFolder,JacobianRequired,...
        isObjectiveMax(prob));
        compiledNonlinJac=VarsJacobians+compiledNonlinJac;



        PkgBlock=optim.internal.problemdef.compile.compilePackageDependencies(...
        [pkgDependsEq,pkgDependsEq]);
    end
