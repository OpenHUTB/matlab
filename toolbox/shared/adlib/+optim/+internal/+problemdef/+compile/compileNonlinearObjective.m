function probStruct=compileNonlinearObjective(prob,objective,...
    objectiveSense,probStruct,objectiveFcnName,inMemory,useParallel,...
    UniqueVarNames)























    objectiveValue=UniqueVarNames(1);
    inputVariables=UniqueVarNames(3);
    extraParamsName=UniqueVarNames(4);


    PkgBlock="";

    NonlinVars=optim.internal.problemdef.compile.compileNonlinearVariables(prob,inputVariables)+newline;




    iss=strcmp(probStruct.solver,'lsqnonlin');



    if~iss
        compileExpression=objective;
        derivativeName="gradient";

        gradientValue=UniqueVarNames(2);
    else

        [~,compileExpression,probStruct.f0]=createExprIfSumSquares(objective);

        derivativeName="Jacobian";

        gradientValue=UniqueVarNames(5);
    end


    probStruct=optim.internal.problemdef.compile.updateObjectiveDerivative(...
    probStruct,compileExpression,iss);

    if strcmpi(probStruct.objectiveDerivative,"finite-differences")


        numFcnOutputs=1;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        numFcnOutputs,'InsertGradient',{'gradient'},'gradient');

        GradientBlock=GradientComment+...
        gradientValue+" = [];"+newline;





        ObjectiveComment="%% "+getString(message('shared_adlib:codeComments:ComputeObjective'))+newline;


        extraParams={};
        [FunctionBlock,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstr({compileExpression},...
        1,[],objectiveValue,probStruct.subfun,extraParams,...
        extraParamsName,inMemory,prob.GeneratedFileFolder,...
        isObjectiveMax(prob));


        ObjectiveBlock=ObjectiveComment+FunctionBlock;



        GradientBlockFirst=true;


        jointFunAndGrad=false;
        CombinedBlock=optim.internal.problemdef.compile.combineBody(...
        ObjectiveBlock,GradientBlock,numFcnOutputs,GradientBlockFirst,...
        jointFunAndGrad);
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


        ObjectiveComment="%% "+getString(message('shared_adlib:codeComments:ComputeObjective'))+newline;

        extraParams={};

        isJacobianReqd=iss;
        [compiledNonlinFun,compiledGrad,pkgDepends,...
        extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstrWithAD({compileExpression},...
        compilefun,jointFunAndGrad,probStruct.NumVars,1,...
        [],objectiveValue,gradientValue,probStruct.subfun,extraParams,...
        extraParamsName,inMemory,prob.GeneratedFileFolder,isJacobianReqd,...
        isObjectiveMax(prob));


        ObjectiveBlock=ObjectiveComment+compiledNonlinFun;


        GradientBlock=VarsJacobians+compiledGrad;


        PkgBlock=optim.internal.problemdef.compile.compilePackageDependencies(pkgDepends);


        numFcnOutputs=1;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        numFcnOutputs,'ComputeObjectiveGradient',{derivativeName},...
        derivativeName);
        GradientBlock=GradientComment+GradientBlock;


        gradientBlockFirst=false;
        CombinedBlock=optim.internal.problemdef.compile.combineBody(...
        ObjectiveBlock,GradientBlock,numFcnOutputs,...
        gradientBlockFirst,jointFunAndGrad);

    end





    hasExtraParams=~isempty(extraParams)||inMemory;

    funHeaderStr=optim.internal.problemdef.compile.objFunctionHeader(objectiveFcnName,hasExtraParams,...
    objectiveValue,gradientValue,inputVariables,extraParamsName,...
    probStruct.objectiveDerivative,derivativeName);


    objectiveBody=funHeaderStr+PkgBlock+NonlinVars+CombinedBlock+"end";

    if inMemory


        objhandle=optim.internal.problemdef.writeCompiledFun2VirtualFile(objectiveFcnName,objectiveBody,prob.GeneratedFileFolder);
        probStruct.objective=optim.internal.problemdef.compile.snapExtraParams(objhandle,extraParams);


        probStruct=optim.internal.problemdef.compile.writeFcnOnVFSWorkers(...
        probStruct,prob,useParallel,"funfcn",objectiveFcnName,...
        objectiveBody,extraParams);
    else

        objhandle=optim.internal.problemdef.writeCompiledFun2StandardFile(...
        objectiveFcnName,objectiveBody,probStruct.filePath);
        if isempty(extraParams)
            probStruct.objective=objhandle;
        else
            probStruct.objective=optim.internal.problemdef.compile.snapExtraParams(objhandle,extraParams);
        end
    end

end
