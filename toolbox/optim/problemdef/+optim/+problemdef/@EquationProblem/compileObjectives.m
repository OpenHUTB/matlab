function probStruct=compileObjectives(prob,probStruct,inMemory,useParallel,fcnname)















    [equations,idxEquations,numEquations,sizeOfEquations]=...
    optim.internal.problemdef.compile.manyobjective.gatherDataForCompile(prob);


    probStruct.f0=0;



    if isempty(equations)
        probStruct.C=[];
        probStruct.d=[];
        probStruct.solver='lsqlin';
        return;
    end


    if numEquations.Nonlinear>0||numEquations.Quadratic>0
        probStruct=compileNonlinearEquations(probStruct,prob,inMemory,...
        useParallel,equations,sizeOfEquations,numEquations,...
        idxEquations,fcnname);
    else

        [Aeq,beq]=optim.internal.problemdef.compile.compileLinearExprOrConstr(equations,...
        idxEquations.Linear,sizeOfEquations,probStruct.NumVars);

        probStruct.solver='lsqlin';
        probStruct.C=Aeq;
        probStruct.d=beq;
    end

end


function probStruct=compileNonlinearEquations(probStruct,prob,inMemory,...
    useParallel,equations,sizeOfEquations,numEquations,...
    idxEquations,equationFcnName)



    varNames=fieldnames(prob.Variables);


    isBounded=any(isfinite(probStruct.lb))||any(isfinite(probStruct.ub));

    if isBounded

        probStruct.solver='lsqnonlin';
    elseif numel(varNames)==1&&numel(prob.Variables.(varNames{1}))==1&&...
        numel(equations)==1&&numel(equations{1})==1


        probStruct.solver='fzero';
    else

        probStruct.solver='fsolve';
    end







    UniqueVarNames=matlab.lang.makeUniqueStrings(["eqns","Jac",...
    "inputVariables","extraParams"],varNames,namelengthmax);
    objValue=UniqueVarNames(1);
    gradientValue=UniqueVarNames(2);
    inputVariables=UniqueVarNames(3);
    extraParamsName=UniqueVarNames(4);


    probStruct=optim.internal.problemdef.compile.updateEqConDerivative(...
    probStruct,equations,"objectiveDerivative");


    [idxVector,initEqnFun,initEqJac,extraParams]=...
    optim.internal.problemdef.compile.manyobjective.initializeFunAndJac(prob,...
    numEquations,idxEquations,sizeOfEquations,objValue,gradientValue,...
    probStruct);


    if numEquations.Nonlinear>0
        [compiledNonlinEqnFun,compiledNonlinEqJac,...
        probStruct,extraParams,PkgBlock,jointFunAndGrad]=...
        optim.internal.problemdef.compile.manyobjective.compileNonlinearObjectives(...
        equations,prob,probStruct,extraParams,...
        extraParamsName,idxEquations,idxVector,objValue,gradientValue,inMemory);
        compiledEqnFun=initEqnFun+compiledNonlinEqnFun;
        compiledEqJac=initEqJac+compiledNonlinEqJac;
        if jointFunAndGrad
            compiledEqJac=initEqnFun+compiledEqJac;
        end
    else





        probStruct.objectiveDerivative="closed-form";
        PkgBlock="";
        compiledEqnFun=initEqnFun;
        compiledEqJac=initEqJac;
        jointFunAndGrad=false;
    end


    if numEquations.Linear>0
        [compiledLinEqnFun,compiledLinEqJac,extraParams]=...
        optim.internal.problemdef.compile.manyobjective.compileLinearObjective(...
        equations,extraParams,extraParamsName,idxEquations,sizeOfEquations,idxVector,...
        objValue,gradientValue,inputVariables,prob,probStruct,jointFunAndGrad);
        compiledEqnFun=compiledEqnFun+compiledLinEqnFun;
        compiledEqJac=compiledEqJac+compiledLinEqJac;
    end


    if numEquations.Quadratic>0
        [compiledQuadFun,compiledQuadJac,extraParams]=...
        optim.internal.problemdef.compile.manyobjective.compileQuadraticObjective(...
        equations,extraParams,extraParamsName,idxEquations,numEquations,idxVector,...
        objValue,gradientValue,inputVariables,prob,probStruct,jointFunAndGrad);
        compiledEqnFun=compiledEqnFun+compiledQuadFun;
        compiledEqJac=compiledEqJac+compiledQuadJac;
    end


    probStruct=optim.internal.problemdef.compile.manyobjective.createFunction(prob,...
    probStruct,compiledEqnFun,compiledEqJac,...
    extraParams,extraParamsName,inMemory,objValue,gradientValue,...
    equationFcnName,inputVariables,useParallel,PkgBlock,jointFunAndGrad);

end

