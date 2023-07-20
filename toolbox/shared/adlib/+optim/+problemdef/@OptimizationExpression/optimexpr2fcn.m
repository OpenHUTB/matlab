function[fh,extraParams]=optimexpr2fcn(expr,filename,inMemory,useParallel,ADMode,DerivativeType,DerivativeOnly)















































    if nargin<7
        DerivativeOnly=false;
        if nargin<6
            DerivativeType="gradient";
            if nargin<5
                ADMode="none";
                if nargin<4
                    useParallel=false;
                    if nargin<3
                        inMemory=false;
                        if nargin<2

                            filename=fullfile(pwd,"exprfcn.m");
                        end
                    end
                end
            end
        end
    end


    [filepath,fcnName]=fileparts(filename);



    if inMemory&&(isempty(filepath)||strlength(filepath)==0)
        filepath="exprID"+replace(matlab.lang.internal.uuid(),"-","0");
    end


    isExpressionMax=false;



    varNames=fieldnames(expr.Variables);


    UniqueVarNames=matlab.lang.makeUniqueStrings(["obj","grad","inputVariables","extraParams"],varNames,namelengthmax);
    functionValue=UniqueVarNames(1);
    gradientValue=UniqueVarNames(2);
    inputVariables=UniqueVarNames(3);
    extraParamsName=UniqueVarNames(4);


    PkgBlock="";


    TotalVar=optim.problemdef.OptimizationVariable.setVariableOffset(expr.Variables);

    NonlinVars=optim.internal.problemdef.compile.compileNonlinearVariables(expr,inputVariables)+newline;


    if strcmpi(ADMode,"none")


        numFcnOutputs=1;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        numFcnOutputs,'InsertGradient',{'gradient'},'gradient');

        GradientBlock=GradientComment+...
        gradientValue+" = [];"+newline;





        ObjectiveComment="%% "+getString(message('shared_adlib:codeComments:ComputeObjective'))+newline;


        extraParams={};
        [FunctionBlock,extraParams,subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstr({expr},...
        1,[],functionValue,struct,extraParams,...
        extraParamsName,inMemory,filepath,...
        isExpressionMax);


        ObjectiveBlock=ObjectiveComment+FunctionBlock;



        GradientBlockFirst=true;


        jointFunAndGrad=false;
        CombinedBlock=optim.internal.problemdef.compile.combineBody(...
        ObjectiveBlock,GradientBlock,numFcnOutputs,GradientBlockFirst,...
        jointFunAndGrad);
    else


        VarsJacobians=optim.internal.problemdef.compile.compileVariableJacobians(expr,TotalVar)+newline;

        switch ADMode
        case{"forward","forward-AD","forwardAD"}
            compilefun=@compileForwardAD;
            jointFunAndGrad=true;

        case{"reverse","reverse-AD","reverseAD"}
            compilefun=@compileReverseAD;
            VarsJacobians="";
            jointFunAndGrad=false;
        end


        IsJacobianReqd=strcmpi(DerivativeType,"jacobian");


        FunctionComment="%% "+getString(message('shared_adlib:codeComments:ComputeObjective'))+newline;

        extraParams={};
        [compiledNonlinFun,compiledGrad,pkgDepends,extraParams,subfun]=...
        optim.internal.problemdef.compile.compileNonlinearExprOrConstrWithAD({expr},...
        compilefun,jointFunAndGrad,TotalVar,1,...
        [],functionValue,gradientValue,struct,extraParams,...
        extraParamsName,inMemory,filepath,IsJacobianReqd,isExpressionMax);
        FunctionBlock=FunctionComment+compiledNonlinFun;
        GradientBlock=VarsJacobians+compiledGrad;



        PkgBlock=optim.internal.problemdef.compile.compilePackageDependencies(pkgDepends);




        numFcnOutputs=1;
        GradientComment=optim.internal.problemdef.compile.gradComment(...
        numFcnOutputs,'ComputeObjectiveGradient',{'gradient'},'gradient');
        GradientBlock=GradientComment+GradientBlock;


        gradientBlockFirst=false;
        CombinedBlock=optim.internal.problemdef.compile.combineBody(...
        FunctionBlock,GradientBlock,numFcnOutputs,...
        gradientBlockFirst,jointFunAndGrad);

    end


    funHeaderStr=optim.internal.problemdef.compile.objFunctionHeader(fcnName,true,...
    functionValue,gradientValue,inputVariables,extraParamsName,ADMode,'gradient');


    functionBody=funHeaderStr+PkgBlock+NonlinVars+CombinedBlock+"end";

    if inMemory


        fh=optim.internal.problemdef.writeCompiledFun2VirtualFile(fcnName,functionBody,filepath);
    else


        if isempty(filepath)||strlength(filepath)==0
            filepath=pwd;
        end



        subfun.(fcnName)=functionBody;


        fh=str2func(fcnName);
    end



    optim.internal.problemdef.writeCompiledFcn(subfun,inMemory,useParallel,filepath);



    if DerivativeOnly
        fh=@(x,extraParams)iCalcDerivativeOnly(fh,x,extraParams);
    end

    function derivative=iCalcDerivativeOnly(fh,x,extraParams)

        [~,derivative]=fh(x,extraParams);




