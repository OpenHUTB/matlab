function probStruct=compileConstraints(prob,probStruct,inMemory,useParallel,fcnname)




















    if isempty(prob.Constraints)
        probStruct.Aineq=[];
        probStruct.bineq=[];
        probStruct.Aeq=[];
        probStruct.beq=[];
        return;
    end


    numVars=probStruct.NumVars;


    if isstruct(prob.Constraints)
        constraints=struct2cell(prob.Constraints);
        numConstrObjects=numel(constraints);
        allOperators=cell(numConstrObjects,1);
        islinear=false(numConstrObjects,1);
        constrTypes=zeros(numConstrObjects,1,'like',optim.internal.problemdef.ImplType.Numeric);
        sizeOfConstraints=zeros(numConstrObjects,1);
        for k=1:numConstrObjects
            if~isempty(constraints{k})
                allOperators{k}=getRelation(constraints{k});
                islinear(k)=isLinear(constraints{k});
                constrTypes(k)=getType(constraints{k});
                sizeOfConstraints(k)=numel(constraints{k});
            end
        end
    else
        constraints={prob.Constraints};
        allOperators={getRelation(prob.Constraints)};
        islinear=isLinear(prob.Constraints);
        constrTypes=getType(prob.Constraints);
        sizeOfConstraints=numel(prob.Constraints);
    end


    idxIneqConstraints=strcmp('<=',allOperators)|strcmp('>=',allOperators);

    idxLinIneqConstraints=find(islinear&idxIneqConstraints);

    idxNonlinIneqConstraints=find(~islinear&idxIneqConstraints);


    [probStruct.Aineq,probStruct.bineq]=optim.internal.problemdef.compile.compileLinearExprOrConstr(constraints,...
    idxLinIneqConstraints,sizeOfConstraints,numVars);

    idxEqConstraints=strcmp('==',allOperators);

    idxLinEqConstraints=find(islinear&idxEqConstraints);

    idxNonlinEqConstraints=find(~islinear&idxEqConstraints);


    [probStruct.Aeq,probStruct.beq]=optim.internal.problemdef.compile.compileLinearExprOrConstr(constraints,...
    idxLinEqConstraints,sizeOfConstraints,numVars);


    NumNonlinIneqConstraints=sum(sizeOfConstraints(idxNonlinIneqConstraints));
    NumNonlinEqConstraints=sum(sizeOfConstraints(idxNonlinEqConstraints));
    probStruct.NumNonlinEqConstraints=NumNonlinEqConstraints;

    if any(NumNonlinIneqConstraints+NumNonlinEqConstraints)

        if all(constrTypes<=optim.internal.problemdef.ImplType.Quadratic)








            probStruct.constraintDerivative="closed-form";
            probStruct=optim.internal.problemdef.compile.compileQuadraticConstraints(probStruct,prob,inMemory,useParallel,constraints,NumNonlinIneqConstraints,...
            idxNonlinIneqConstraints,NumNonlinEqConstraints,idxNonlinEqConstraints,fcnname);

        elseif strcmp(probStruct.solver,'coneprog')



            socConstraints=...
            repmat(optim.coneprog.SecondOrderConeConstraint,1,NumNonlinIneqConstraints);
            curIdx=0;


            for i=1:numel(idxNonlinIneqConstraints)
                socCone=extractConicCoefficients(constraints{idxNonlinIneqConstraints(i)},probStruct.NumVars);
                numConi=numel(socCone);
                socConstraints(curIdx+1:curIdx+numConi)=socCone;
                curIdx=curIdx+numConi;
            end
            probStruct.socConstraints=socConstraints;

        else


            if~isempty(probStruct.intcon)&&optim.internal.utils.hasGlobalOptimizationToolbox



                if~strcmpi(probStruct.constraintDerivative,"closed-form")
                    probStruct.constraintDerivative="finite-differences";
                end
            else
                if isMultiObjective(prob)
                    probStruct.solver='gamultiobj';
                else
                    probStruct.solver='fmincon';
                end


                probStruct=optim.internal.problemdef.compile.updateEqConDerivative(probStruct,constraints,"constraintDerivative");
            end


            probStruct=optim.internal.problemdef.compile.compileNonlinearConstraints(probStruct,prob,inMemory,useParallel,constraints,sizeOfConstraints,NumNonlinIneqConstraints,...
            idxNonlinIneqConstraints,NumNonlinEqConstraints,idxNonlinEqConstraints,fcnname);

        end

    else
        probStruct.constraintDerivative="closed-form";
    end

end
