function probStruct=compileNonlinearConstraints(probStruct,prob,inMemory,useParallel,constraints,sizeOfConstraints,NumNonlinIneqConstraints,...
    idxNonlinIneqConstraints,NumNonlinEqConstraints,idxNonlinEqConstraints,constraintFcnName)





























    varNames=fieldnames(prob.Variables);


    UniqueVarNames=matlab.lang.makeUniqueStrings(["cineq","ceq","cineqGrad",...
    "ceqGrad","inputVariables","extraParams"],varNames,namelengthmax);
    cineqValue=UniqueVarNames(1);
    ceqValue=UniqueVarNames(2);
    cineqGradValue=UniqueVarNames(3);
    ceqGradValue=UniqueVarNames(4);
    inputVariables=UniqueVarNames(5);
    extraParamsName=UniqueVarNames(6);


    PkgBlock="";

    NonlinVars=optim.internal.problemdef.compile.compileNonlinearVariables(prob,inputVariables)+newline+newline;


    extraParams={};

    numConstraints=numel(constraints);

    ineqIdxVector=[];
    eqIdxVector=[];


    numIneqArrayCon=numel(idxNonlinIneqConstraints);
    if numIneqArrayCon>1


        ineqIdx=optim.internal.problemdef.compile.createStartEndIndexVectors(...
        sizeOfConstraints(idxNonlinIneqConstraints));
        ineqIdxVector.Start=zeros(numConstraints,1);
        ineqIdxVector.Start(idxNonlinIneqConstraints)=ineqIdx.Start;
        ineqIdxVector.End=zeros(numConstraints,1);
        ineqIdxVector.End(idxNonlinIneqConstraints)=ineqIdx.End;
        FunInitializationBlock=cineqValue+" = zeros("+NumNonlinIneqConstraints+", 1);"+newline;
        IneqGradInitializationBlock=cineqGradValue+" = zeros("+probStruct.NumVars+", "+NumNonlinIneqConstraints+");"+newline;
    elseif numIneqArrayCon==1

        FunInitializationBlock="";
        IneqGradInitializationBlock="";
    else

        FunInitializationBlock=cineqValue+" = [];"+newline;
        IneqGradInitializationBlock=cineqGradValue+" = [];"+newline;
    end
    numEqArrayCon=numel(idxNonlinEqConstraints);
    if numEqArrayCon>1


        eqIdx=optim.internal.problemdef.compile.createStartEndIndexVectors(...
        sizeOfConstraints(idxNonlinEqConstraints));
        eqIdxVector.Start=zeros(numConstraints,1);
        eqIdxVector.Start(idxNonlinEqConstraints)=eqIdx.Start;
        eqIdxVector.End=zeros(numConstraints,1);
        eqIdxVector.End(idxNonlinEqConstraints)=eqIdx.End;
        FunInitializationBlock=FunInitializationBlock+ceqValue+" = zeros("+NumNonlinEqConstraints+", 1);"+newline;
        EqGradInitializationBlock=ceqGradValue+" = zeros("+probStruct.NumVars+", "+NumNonlinEqConstraints+");"+newline;
    elseif numEqArrayCon==1

        EqGradInitializationBlock="";
    else

        FunInitializationBlock=FunInitializationBlock+ceqValue+" = [];"+newline;
        EqGradInitializationBlock=ceqGradValue+" = [];"+newline;
    end


    isConstraintsMax=false(1,numel(constraints));

    if strcmpi(probStruct.constraintDerivative,"finite-differences")


        headerMsgId='shared_adlib:codeComments:ConstraintFunctionHeader';





        compiledGrad=("if nargout > 2"+newline+...
        "    "+cineqGradValue+" = [];"+newline+...
        "    "+ceqGradValue+" = [];"+newline+...
        "end"+newline+newline);
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        2,'InsertGradient',{'gradient'},'gradient');
        GradientBlock=GradientComment+compiledGrad;




        FunctionBlock="%% "+getString(message('shared_adlib:codeComments:ComputeInequalityConstraints'))+newline;
        [compiledNonlinFun,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstr(constraints,...
        idxNonlinIneqConstraints,ineqIdxVector,cineqValue,...
        probStruct.subfun,extraParams,extraParamsName,inMemory,prob.GeneratedFileFolder,...
        isConstraintsMax);
        FunctionBlock=FunctionBlock+FunInitializationBlock+compiledNonlinFun;


        FunctionBlock=FunctionBlock+newline+"%% "+getString(message('shared_adlib:codeComments:ComputeEqualityConstraints'))+newline;
        [compiledNonlinFun,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstr(constraints,...
        idxNonlinEqConstraints,eqIdxVector,ceqValue,...
        probStruct.subfun,extraParams,extraParamsName,inMemory,...
        prob.GeneratedFileFolder,isConstraintsMax);

        FunctionBlock=FunctionBlock+compiledNonlinFun;


        CombinedBlock=GradientBlock+newline+FunctionBlock;
    else


        headerMsgId='shared_adlib:codeComments:ConstraintFunctionHeaderWithGradient';


        VarsJacobians=optim.internal.problemdef.compile.compileVariableJacobians(prob,probStruct.NumVars)+newline;

        switch probStruct.constraintDerivative
        case "forward-AD"
            compilefun=@compileForwardAD;
            jointFunAndGrad=true;

        case "reverse-AD"
            compilefun=@compileReverseAD;
            VarsJacobians="";
            jointFunAndGrad=false;
        end




        FunctionBlock="%% "+getString(message('shared_adlib:codeComments:ComputeInequalityConstraints'))+newline;
        [compiledNonlinFun,compiledIneqGrad,...
        pkgDependsIneq,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstrWithAD(constraints,...
        compilefun,jointFunAndGrad,probStruct.NumVars,idxNonlinIneqConstraints,...
        ineqIdxVector,cineqValue,cineqGradValue,probStruct.subfun,extraParams,...
        extraParamsName,inMemory,prob.GeneratedFileFolder,false,isConstraintsMax);
        FunctionBlock=FunctionBlock+FunInitializationBlock+compiledNonlinFun;
        if jointFunAndGrad
            compiledIneqGrad=FunInitializationBlock+compiledIneqGrad;
        end
        compiledIneqGrad=IneqGradInitializationBlock+compiledIneqGrad;


        FunctionBlock=FunctionBlock+newline+"%% "+getString(message('shared_adlib:codeComments:ComputeEqualityConstraints'))+newline;
        [compiledNonlinFun,compiledEqGrad,...
        pkgDependsEq,extraParams,probStruct.subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstrWithAD(constraints,...
        compilefun,jointFunAndGrad,probStruct.NumVars,idxNonlinEqConstraints,...
        eqIdxVector,ceqValue,ceqGradValue,probStruct.subfun,extraParams,...
        extraParamsName,inMemory,prob.GeneratedFileFolder,false,isConstraintsMax);
        FunctionBlock=FunctionBlock+compiledNonlinFun;
        compiledEqGrad=EqGradInitializationBlock+compiledEqGrad;



        PkgBlock=optim.internal.problemdef.compile.compilePackageDependencies(...
        [pkgDependsIneq,pkgDependsEq]);


        GradientBlock=VarsJacobians+compiledIneqGrad+compiledEqGrad;

        numFcnOutputs=2;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        numFcnOutputs,'ComputeConstraintGradient',{},'gradient');
        GradientBlock=GradientComment+GradientBlock;


        gradientBlockFirst=false;
        CombinedBlock=optim.internal.problemdef.compile.combineBody(...
        FunctionBlock,GradientBlock,numFcnOutputs,...
        gradientBlockFirst,jointFunAndGrad);

    end





    helpThreeSpaces="   ";





    if isstrprop(constraintFcnName,"lower")
        helpFcnName=upper(constraintFcnName);
    else
        helpFcnName=constraintFcnName;
    end

    if isempty(extraParams)&&~inMemory





        functionSignature="function ["+cineqValue+", "+ceqValue+", "+cineqGradValue+", "+ceqGradValue+"] = "+...
        constraintFcnName+"("+inputVariables+")"+newline;

        helpText=helpFcnName+" "+getString(message(headerMsgId))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(cineqValue)+", "+upper(ceqValue)+"] = "+helpFcnName+"("+upper(inputVariables)+") "+...
        getString(message('shared_adlib:codeComments:ConstraintFunctionSyntax',...
        upper(cineqValue),upper(ceqValue),upper(inputVariables)))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(cineqValue)+", "+upper(ceqValue)+", "+upper(cineqGradValue)+", "+upper(ceqGradValue)+"] = "+...
        helpFcnName+"("+upper(inputVariables)+") ";

    else

        functionSignature="function ["+cineqValue+", "+ceqValue+", "+cineqGradValue+", "+ceqGradValue+"] = "+...
        constraintFcnName+"("+inputVariables+", "+extraParamsName+")"+newline;

        helpText=helpFcnName+" "+getString(message(headerMsgId))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(cineqValue)+", "+upper(ceqValue)+"] = "+helpFcnName+"("+upper(inputVariables)+", "+upper(extraParamsName)+") "+...
        getString(message('shared_adlib:codeComments:ConstraintFunctionSyntaxWithExtraParams',...
        upper(cineqValue),upper(ceqValue),upper(inputVariables),upper(extraParamsName)))+newline+...
        newline+...
        helpThreeSpaces+"["+upper(cineqValue)+", "+upper(ceqValue)+", "+upper(cineqGradValue)+", "+upper(ceqGradValue)+"] = "+...
        helpFcnName+"("+upper(inputVariables)+", "+upper(extraParamsName)+") ";
    end

    helpText=helpText+getString(message('shared_adlib:codeComments:ConstraintGradientSyntax',...
    upper(cineqGradValue),upper(ceqGradValue)))+newline+...
    newline+...
    helpThreeSpaces+getString(message('shared_adlib:codeComments:AutoGenerated',datestr(now)));

    helpText=matlab.internal.display.printWrapped(helpText,73);
    helpText(end)=[];

    helpText=strjoin("%"+splitlines(helpText),'\n')+newline+newline;


    constraintBody=functionSignature+helpText+PkgBlock+NonlinVars+...
    CombinedBlock+newline+"end";



    if inMemory


        constrhandle=optim.internal.problemdef.writeCompiledFun2VirtualFile(constraintFcnName,constraintBody,prob.GeneratedFileFolder);
        probStruct.nonlcon=optim.internal.problemdef.compile.snapExtraParams(constrhandle,extraParams);


        probStruct=optim.internal.problemdef.compile.writeFcnOnVFSWorkers(...
        probStruct,prob,useParallel,"confcn",constraintFcnName,...
        constraintBody,extraParams);
    else

        constrhandle=optim.internal.problemdef.writeCompiledFun2StandardFile(...
        constraintFcnName,constraintBody,probStruct.filePath);
        if isempty(extraParams)
            probStruct.nonlcon=constrhandle;
        else
            probStruct.nonlcon=optim.internal.problemdef.compile.snapExtraParams(constrhandle,extraParams);
        end
    end