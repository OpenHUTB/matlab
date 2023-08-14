function probStruct=compileObjectives(prob,probStruct,inMemory,useParallel,fcnname)






















    objective=prob.Objective;
    objectiveSense=prob.ObjectiveSense;
    probStruct.f0=0;


    varNames=fieldnames(prob.Variables);


    UniqueVarNames=matlab.lang.makeUniqueStrings(...
    ["obj","grad","inputVariables","extraParams","Jac"],varNames,namelengthmax);



    if isempty(objective)

        probStruct=compileConstantObjective(prob,[],probStruct,fcnname,inMemory,useParallel,UniqueVarNames);
        return;
    end


    if isMultiObjective(prob)
        probStruct=compileMultipleObjectives(prob,probStruct,inMemory,useParallel,fcnname);
        return
    end

    if isstruct(objective)

        objName=fieldnames(objective);
        nonEmptyObj=structfun(@(obj)~isempty(obj),objective);
        if isempty(nonEmptyObj)||~any(nonEmptyObj)

            probStruct=compileConstantObjective(prob,[],probStruct,fcnname,inMemory,useParallel,UniqueVarNames);
            return;
        end
        objective=objective.(objName{nonEmptyObj});
    end



    switch getExprType(objective)
    case optim.internal.problemdef.ImplType.Nonlinear

        probStruct=optim.internal.problemdef.compile.compileNonlinearObjective(prob,...
        objective,objectiveSense,probStruct,fcnname,inMemory,useParallel,...
        UniqueVarNames);

    case optim.internal.problemdef.ImplType.Quadratic

        probStruct=compileQuadraticObjective(prob,objective,objectiveSense,...
        probStruct,fcnname,inMemory,useParallel,UniqueVarNames);

    case optim.internal.problemdef.ImplType.Linear
        probStruct=compileLinearObjective(prob,objective,objectiveSense,...
        probStruct,fcnname,inMemory,useParallel,UniqueVarNames);
    otherwise

        probStruct=compileConstantObjective(prob,objective,probStruct,fcnname,...
        inMemory,useParallel,UniqueVarNames);
    end


    if~isempty(probStruct.f0)
        probStruct.f0=full(probStruct.f0);
    end
end



function probStruct=compileQuadraticObjective(prob,objective,objectiveSense,...
    probStruct,objectiveFcnName,inMemory,useParallel,UniqueVarNames)

    if strncmpi(objectiveSense,'min',3)


        [iss,eSOS,c]=createExprIfSumSquares(objective);
        if iss

            [C,d]=extractLinearCoefficients(eSOS,probStruct.NumVars);
            C=sqrt(2)*C';
            d=-sqrt(2)*d;
            probStruct.f0=c;


            if any(isfield(probStruct,{'nonlcon','socConstraints'}))||~isempty(probStruct.intcon)




                nlfunStruct.singleLine=true;
                nlfunStruct.funh="0.5*dot(residual, residual)";
                nlfunStruct.fcnBody="";
                nlfunStruct.extraParams={C,d};
                hasExtraParams=true;


                probStruct=generateNLfields(prob,probStruct,objectiveFcnName,...
                nlfunStruct,hasExtraParams,inMemory,useParallel,UniqueVarNames,"SumSquares");



                if isfield(probStruct,'socConstraints')&&~isempty(probStruct.socConstraints)
                    probStruct=optim.internal.problemdef.compile.createSecondOrderConeConstraintFcn(probStruct);
                end

            else

                probStruct.solver='lsqlin';
                probStruct.C=C;
                probStruct.d=d;
            end
        else



            [H,A,b]=prob.Compiler.compileQuadraticObjective(objective,probStruct.NumVars);


            H=2.*H;
            probStruct=generateQPfields(prob,probStruct,H,A,b,...
            objectiveFcnName,inMemory,useParallel,UniqueVarNames);
        end
    else



        [H,A,b]=prob.Compiler.compileQuadraticObjective(objective,probStruct.NumVars);


        H=-2.*H;
        A=-A;
        b=-b;
        probStruct=generateQPfields(prob,probStruct,H,A,b,...
        objectiveFcnName,inMemory,useParallel,UniqueVarNames);
    end

end


function probStruct=generateQPfields(prob,probStruct,H,A,b,...
    objectiveFcnName,inMemory,useParallel,UniqueVarNames)


    if any(isfield(probStruct,{'nonlcon','socConstraints'}))||...
        (~isempty(H)&&~isempty(probStruct.intcon))



        if~issymmetric(H)
            H=(H+H.')/2;
        end



        nlfunStruct.singleLine=true;
        nlfunStruct.funh="0.5*dot(x, Hx) + dot(f, x)";
        nlfunStruct.fcnBody="";
        nlfunStruct.extraParams={H,A};
        hasExtraParams=true;


        probStruct=generateNLfields(prob,probStruct,objectiveFcnName,...
        nlfunStruct,hasExtraParams,inMemory,useParallel,UniqueVarNames,"Quadratic");



        if isfield(probStruct,'socConstraints')&&~isempty(probStruct.socConstraints)
            probStruct=optim.internal.problemdef.compile.createSecondOrderConeConstraintFcn(probStruct);
        end

    else

        probStruct.solver='quadprog';
        probStruct.H=H;
        probStruct.f=A;

        probStruct=updateIfLinear(probStruct);
    end

    probStruct.f0=b;

end



function probStruct=updateIfLinear(probStruct)

    if nnz(probStruct.H)==0

        probStruct=rmfield(probStruct,'H');
        if~isempty(probStruct.intcon)
            probStruct.solver='intlinprog';
        else
            probStruct.solver='linprog';
        end
    end
end


function probStruct=compileLinearObjective(prob,objective,objectiveSense,...
    probStruct,objectiveFcnName,inMemory,useParallel,UniqueVarNames)

    [f,probStruct.f0]=extractLinearCoefficients(objective,probStruct.NumVars);
    f=full(f);

    if strncmpi(objectiveSense,'max',3)

        f=-f;
        probStruct.f0=-probStruct.f0;
    end

    if nnz(f)==0

        probStruct=compileConstantObjective(prob,objective,probStruct,...
        objectiveFcnName,inMemory,useParallel,UniqueVarNames);
    else

        if isfield(probStruct,'nonlcon')





            nlfunStruct.singleLine=true;
            nlfunStruct.funh="dot(f, x)";
            nlfunStruct.fcnBody="";
            nlfunStruct.extraParams={f};
            hasExtraParams=true;


            probStruct=generateNLfields(prob,probStruct,objectiveFcnName,...
            nlfunStruct,hasExtraParams,inMemory,useParallel,UniqueVarNames,"Linear");

        elseif isfield(probStruct,'socConstraints')

            probStruct.f=f;


            probStruct.solver='coneprog';

        else

            probStruct.f=f;
            if~isempty(probStruct.intcon)
                probStruct.solver='intlinprog';
            else
                probStruct.solver='linprog';
            end
        end
    end

end


function probStruct=compileConstantObjective(prob,objective,probStruct,...
    objectiveFcnName,inMemory,useParallel,UniqueVarNames)

    objval=0;

    if~isempty(objective)



        [~,objval]=extractLinearCoefficients(objective,probStruct.NumVars);
    end



    if isfield(probStruct,'nonlcon')



        extraParamsName=UniqueVarNames(4);



        nlfunStruct.singleLine=true;
        nlfunStruct.funh=extraParamsName+"{1}";
        nlfunStruct.fcnBody="";
        nlfunStruct.extraParams={objval};
        hasExtraParams=true;


        probStruct=generateNLfields(prob,probStruct,objectiveFcnName,...
        nlfunStruct,hasExtraParams,inMemory,useParallel,UniqueVarNames,"Constant");
    else

        probStruct.f=[];
        probStruct.f0=objval;
        if isfield(probStruct,'socConstraints')
            probStruct.solver='coneprog';
        elseif~isempty(probStruct.intcon)
            probStruct.solver='intlinprog';
        else
            probStruct.solver='linprog';
        end
    end

end




function probStruct=generateNLfields(prob,probStruct,objectiveFcnName,...
    nlfunStruct,hasExtraParams,inMemory,useParallel,UniqueVarNames,objType)








    probStruct.objectiveDerivative="closed-form";


    objectiveValue=UniqueVarNames(1);
    gradientValue=UniqueVarNames(2);
    inputVariables=UniqueVarNames(3);
    extraParamsName=UniqueVarNames(4);


    objBody=optim.internal.problemdef.compile.objFunctionBody(...
    nlfunStruct,objectiveValue,gradientValue,inputVariables,extraParamsName,objType);


    derivativeName="gradient";
    funHeaderStr=optim.internal.problemdef.compile.objFunctionHeader(objectiveFcnName,hasExtraParams,...
    objectiveValue,gradientValue,inputVariables,extraParamsName,...
    probStruct.objectiveDerivative,derivativeName);


    objectiveBody=funHeaderStr+objBody+"end";



    extraParams=nlfunStruct.extraParams;

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

