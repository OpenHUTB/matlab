function probStruct=createFunction(prob,probStruct,...
    compiledEqnFun,compiledEqJac,...
    extraParams,extraParamsName,inMemory,objValue,gradientValue,...
    equationFcnName,inputVariables,useParallel,PkgBlock,jointFunAndGrad)










    isFinDiff=strcmpi(probStruct.objectiveDerivative,"finite-differences");
    IsEquationProblem=isa(prob,'optim.problemdef.EquationProblem');

    if IsEquationProblem
        ComputeCommentId="shared_adlib:codeComments:ComputeEquation";
        ComputeCommentGradientId="ComputeEquationJacobian";
        ComputeCommentGradientParam={};
        GradCommentName="Jacobian";
    else
        ComputeCommentId="shared_adlib:codeComments:ComputeObjective";
        ComputeCommentGradientId="ComputeObjectiveGradient";
        ComputeCommentGradientParam={'gradient'};
        GradCommentName="gradient";
    end




    compiledEqnFunComment="%% "+getString(message(ComputeCommentId))+newline;
    compiledEqnFun=compiledEqnFunComment+compiledEqnFun;


    functionSignatureAndHelp=optim.internal.problemdef.compile.manyobjective.generateSignatureAndHelp(...
    prob,extraParams,extraParamsName,inMemory,objValue,gradientValue,...
    equationFcnName,inputVariables,isFinDiff);



    VariableStr=optim.internal.problemdef.compile.compileNonlinearVariables(prob,inputVariables)+newline;




    if isFinDiff


        GradientBlock=gradientValue+" = [];"+newline;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        1,'InsertGradient',{GradCommentName},GradCommentName);
        GradientStr=GradientComment+GradientBlock;


        EqnAndGradStr=GradientStr+newline+compiledEqnFun;
    else


        GradientComment=optim.internal.problemdef.compile.gradComment(...
        1,ComputeCommentGradientId,ComputeCommentGradientParam,GradCommentName);
        GradientStr=GradientComment+compiledEqJac;


        numFcnOutputs=1;
        gradientBlockFirst=false;
        EqnAndGradStr=optim.internal.problemdef.compile.combineBody(...
        compiledEqnFun,GradientStr,numFcnOutputs,...
        gradientBlockFirst,jointFunAndGrad);
    end


    equationBody=functionSignatureAndHelp+PkgBlock+...
    VariableStr+EqnAndGradStr+newline+"end";





    if inMemory


        objhandle=optim.internal.problemdef.writeCompiledFun2VirtualFile(equationFcnName,equationBody,prob.GeneratedFileFolder);
        probStruct.objective=optim.internal.problemdef.compile.snapExtraParams(objhandle,extraParams);


        probStruct=optim.internal.problemdef.compile.writeFcnOnVFSWorkers(...
        probStruct,prob,useParallel,"funfcn",equationFcnName,...
        equationBody,extraParams);

    else



        objhandle=optim.internal.problemdef.writeCompiledFun2StandardFile(...
        equationFcnName,equationBody,probStruct.filePath);

        if isempty(extraParams)
            probStruct.objective=objhandle;
        else
            probStruct.objective=optim.internal.problemdef.compile.snapExtraParams(objhandle,extraParams);
        end
    end

end

