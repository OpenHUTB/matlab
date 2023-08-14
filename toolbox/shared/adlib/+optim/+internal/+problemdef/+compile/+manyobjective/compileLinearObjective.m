function[compiledLinFun,compiledLinJac,extraParams]=...
    compileLinearObjective(objectives,...
    extraParams,extraParamsName,idxObjectives,sizeOfObjectives,idxVector,...
    objValue,gradientValue,inputVariables,prob,probStruct,jointFunAndGrad)












    isFinDiff=strcmpi(probStruct.objectiveDerivative,"finite-differences");
    IsEquationProblem=isa(prob,'optim.problemdef.EquationProblem');
    JacobianRequired=IsEquationProblem;


    [A,b]=optim.internal.problemdef.compile.compileLinearExprOrConstr(objectives,...
    idxObjectives.Linear,sizeOfObjectives,probStruct.NumVars);


    nParams=numel(extraParams);
    extraParams(end+1:end+2)={A,b};

    [linIdx,gradIdx,linIdxArray]=optim.internal.problemdef.compile.manyobjective.createClosedFormIdxString(...
    idxObjectives.Linear,idxVector,JacobianRequired);
    if IsEquationProblem
        binaryOp=" - ";
    else
        binaryOp=" + ";
    end
    compiledLinFun=...
    objValue+linIdx+" = "+...
    extraParamsName+"{"+(nParams+1)+"}*"+inputVariables+"(:)"+...
    binaryOp+extraParamsName+"{"+(nParams+2)+"} ;"+newline;


    isMax=isObjectiveMax(prob);
    isLinearMax=isMax(idxObjectives.Linear);
    hasMaxObjective=any(isLinearMax);

    if hasMaxObjective
        [negFcnIdx,negGradIdx]=optim.internal.problemdef.compile.manyobjective.negateIdxClosedForm(linIdxArray,isLinearMax);
        if~isempty(negFcnIdx)
            compiledLinFun=compiledLinFun+objValue+negFcnIdx+" = -"...
            +objValue+negFcnIdx+";"+newline;
        end
    end

    compiledLinJac="";
    if~isFinDiff

        compiledLinJac=...
        gradientValue+gradIdx+" = "+extraParamsName+"{"+(nParams+1)+"};"+newline;

        if hasMaxObjective
            compiledLinJac=compiledLinJac+gradientValue+negGradIdx+" = -"...
            +gradientValue+negGradIdx+";"+newline;
        end

        if jointFunAndGrad


            compiledLinJac=compiledLinFun+compiledLinJac;
        end

    end
