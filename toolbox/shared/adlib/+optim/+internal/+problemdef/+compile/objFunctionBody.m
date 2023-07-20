function objBody=objFunctionBody(nlfunStruct,objectiveValue,gradientValue,...
    inputVariables,extraParamsName,objType)

















    FcnBlock="";

    AutoGrad="[]";

    switch objType
    case "Constant"

        AutoGrad="zeros(numel("+inputVariables+"), 1)";
    case "Linear"

        fstr="f = "+extraParamsName+"{1}(:);"+newline;
        xstr="x = "+inputVariables+"(:);"+newline;
        FcnBlock=xstr+fstr+newline;
        AutoGrad="f";
    case "Quadratic"

        Hstr="H = "+extraParamsName+"{1};"+newline;
        xstr="x = "+inputVariables+"(:);"+newline;
        fstr="f = "+extraParamsName+"{2}(:);"+newline;
        HxStr="Hx = H*x;";
        AutoGrad="Hx + f";
        FcnBlock=Hstr+xstr+fstr+newline+HxStr+newline;
    case "SumSquares"


        Cstr="C = "+extraParamsName+"{1};"+newline;
        xstr="x = "+inputVariables+"(:);"+newline;
        dstr="d = "+extraParamsName+"{2}(:);"+newline;
        residStr="residual = C*x - d;";
        AutoGrad="C'*residual";
        FcnBlock=Cstr+xstr+dstr+newline+residStr+newline;
    end




    FcnComment="%% "+getString(message('shared_adlib:codeComments:ComputeObjective'))+newline;
    FunctionBlock=FcnComment+FcnBlock+...
    optim.internal.problemdef.compile.compileNonlinearOutput(nlfunStruct,objectiveValue);


    compiledGrad=gradientValue+" = "+AutoGrad+";"+newline;

    numFcnOutputs=1;
    GradientComment=optim.internal.problemdef.compile.gradComment(...
    numFcnOutputs,'ComputeObjectiveGradient',{'gradient'},'gradient');
    GradientBlock=GradientComment+compiledGrad;


    gradientBlockFirst=false;
    jointFunAndGrad=false;
    objBody=optim.internal.problemdef.compile.combineBody(...
    FunctionBlock,GradientBlock,numFcnOutputs,...
    gradientBlockFirst,jointFunAndGrad);

end
