function[compiledQuadFun,compiledQuadGrad,extraParams]=...
    compileQuadraticObjective(...
    objectives,extraParams,extraParamsName,...
    idxObjectives,numObjectives,idxVector,objValue,gradientValue,...
    inputVariables,prob,probStruct,jointFunAndGrad)












    isFinDiff=strcmpi(probStruct.objectiveDerivative,"finite-differences");
    IsEquationProblem=isa(prob,'optim.problemdef.EquationProblem');
    JacobianRequired=IsEquationProblem;


    varNames=fieldnames(prob.Variables);


    UniqueVarNames=matlab.lang.makeUniqueStrings(["eqnsQuad","jacQuad",...
    "Heq","Heqmvec","feq","rhseq","HeqmvecCell"],varNames,namelengthmax);
    eqQuadValue=UniqueVarNames(1);
    jacQuadValue=UniqueVarNames(2);
    HessNameEq=UniqueVarNames(3);
    HessEqTimesX=UniqueVarNames(4);
    FNameEq=UniqueVarNames(5);
    RHSNameEq=UniqueVarNames(6);
    HessEqTimeXcell=UniqueVarNames(7);


    [compiledQuadFun,compiledQuadGrad,extraParams]=...
    optim.internal.problemdef.compile.writeQPConstrGradientBlock(objectives,...
    probStruct.NumVars,numObjectives.Quadratic,idxObjectives.Quadratic,...
    eqQuadValue,jacQuadValue,inputVariables,extraParams,extraParamsName,...
    HessNameEq,HessEqTimesX,FNameEq,RHSNameEq,HessEqTimeXcell);


    [quadIdx,gradIdx,quadIdxArray]=optim.internal.problemdef.compile.manyobjective.createClosedFormIdxString(...
    idxObjectives.Quadratic,idxVector,JacobianRequired);
    compiledQuadFun=compiledQuadFun+...
    objValue+quadIdx+" = "+eqQuadValue+";"+newline;


    isMax=isObjectiveMax(prob);
    isQuadraticMax=isMax(idxObjectives.Quadratic);
    hasMaxObjective=any(isQuadraticMax);
    if hasMaxObjective
        [negFcnIdx,negGradIdx]=optim.internal.problemdef.compile.manyobjective.negateIdxClosedForm(quadIdxArray,isQuadraticMax);
        compiledQuadFun=compiledQuadFun+objValue+negFcnIdx+" = -"...
        +objValue+negFcnIdx+";"+newline;
    end


    if~isFinDiff

        if JacobianRequired
            jacTranspose="'";
        else
            jacTranspose="";
        end
        compiledQuadGrad=compiledQuadGrad+...
        gradientValue+gradIdx+" = "+jacQuadValue+...
        jacTranspose+";"+newline;

        if hasMaxObjective
            compiledQuadGrad=compiledQuadGrad+gradientValue+negGradIdx+" = -"...
            +gradientValue+negGradIdx+";"+newline;
        end

        if jointFunAndGrad


            compiledQuadGrad=compiledQuadFun+compiledQuadGrad;
        end
    end
