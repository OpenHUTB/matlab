function probStruct=compileMultipleObjectives(prob,probStruct,inMemory,useParallel,objectiveFcnName)












    [objectives,idxObjectives,numObjectives,sizeOfObjectives]=...
    optim.internal.problemdef.compile.manyobjective.gatherDataForCompile(prob);






    varNames=fieldnames(prob.Variables);
    UniqueVarNames=matlab.lang.makeUniqueStrings(["obj","grad",...
    "inputVariables","extraParams"],varNames,namelengthmax);
    objValue=UniqueVarNames(1);
    gradientValue=UniqueVarNames(2);
    inputVariables=UniqueVarNames(3);
    extraParamsName=UniqueVarNames(4);


    [idxVector,initObjFun,initObjGrad,extraParams]=...
    optim.internal.problemdef.compile.manyobjective.initializeFunAndJac(prob,...
    numObjectives,idxObjectives,sizeOfObjectives,objValue,gradientValue,probStruct);




    probStruct=optim.internal.problemdef.compile.updateEqConDerivative(...
    probStruct,objectives,"objectiveDerivative");


    if numObjectives.Nonlinear>0
        [compiledNonlinObjFun,compiledNonlinObjGrad,...
        probStruct,extraParams,PkgBlock,jointFunAndGrad]=...
        optim.internal.problemdef.compile.manyobjective.compileNonlinearObjectives(...
        objectives,prob,probStruct,extraParams,...
        extraParamsName,idxObjectives,idxVector,objValue,gradientValue,inMemory);
        compiledObjFun=initObjFun+compiledNonlinObjFun;
        compiledObjGrad=initObjGrad+compiledNonlinObjGrad;
        if jointFunAndGrad
            compiledObjGrad=initObjFun+compiledObjGrad;
        end
    else
        PkgBlock="";
        compiledObjFun=initObjFun;
        compiledObjGrad=initObjGrad;
        jointFunAndGrad=false;
    end


    if numObjectives.Linear>0
        [compiledLinObjFun,compiledLinObjGrad,extraParams]=...
        optim.internal.problemdef.compile.manyobjective.compileLinearObjective(...
        objectives,extraParams,extraParamsName,idxObjectives,sizeOfObjectives,idxVector,...
        objValue,gradientValue,inputVariables,prob,probStruct,jointFunAndGrad);
        compiledObjFun=compiledObjFun+compiledLinObjFun;
        compiledObjGrad=compiledObjGrad+compiledLinObjGrad;
    end


    if numObjectives.Quadratic>0
        [compiledQuadFun,compiledQuadObjGrad,extraParams]=...
        optim.internal.problemdef.compile.manyobjective.compileQuadraticObjective(...
        objectives,extraParams,extraParamsName,idxObjectives,numObjectives,idxVector,...
        objValue,gradientValue,inputVariables,prob,probStruct,jointFunAndGrad);
        compiledObjFun=compiledObjFun+compiledQuadFun;
        compiledObjGrad=compiledObjGrad+compiledQuadObjGrad;
    end




    probStruct=optim.internal.problemdef.compile.manyobjective.createFunction(...
    prob,probStruct,compiledObjFun,compiledObjGrad,...
    extraParams,extraParamsName,inMemory,objValue,gradientValue,...
    objectiveFcnName,inputVariables,useParallel,PkgBlock,jointFunAndGrad);
