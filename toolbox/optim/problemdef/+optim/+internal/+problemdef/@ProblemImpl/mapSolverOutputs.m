function[sol,varargout]=mapSolverOutputs(prob,x,fval,exitflag,output,lambda,solver,globalSolver,varargin)















    if isMultiObjective(prob)
        sol=optim.problemdef.OptimizationValues.createFromSolverBased(...
        prob,x,fval,output.probdefResiduals);
        output=rmfield(output,"probdefResiduals");
    else
        sol=makeSolutionStruct(prob,x);
    end


    solverFval=fval;
    solverExitflag=exitflag;


    output.solver=solver;

    if nargout>1


        varargout{1}=mapFvalSolution(prob,fval);

        if nargout>2


            probType=prob.className;
            exitflag=mapExitflag(prob,solverFval,exitflag,solver,varargin{:});
            if isempty(globalSolver)
                solverName4Exitflag=solver;
            else
                solverName4Exitflag=class(globalSolver);
            end
            varargout{2}=optim.problemdef.Exitflag(exitflag,solverName4Exitflag,probType);

            if nargout>3
                if isfield(output,'bestfeasible')&&isfield(output.bestfeasible,'x')
                    output.bestfeasible.x=makeSolutionStruct(prob,output.bestfeasible.x);
                end

                if isfield(output,'ineq')&&isstruct(prob.Constraints)


                    constraintNames=fieldnames(prob.Constraints);
                    ineqVals=output.ineq(:);
                    output.ineq=struct();
                    constrIdxBegin=1;
                    for idx=1:numel(constraintNames)
                        constrName=constraintNames{idx};
                        if isLinear(prob.Constraints.(constrName))






                            output.ineq.(constrName)=getValue(prob.Constraints.(constrName),sol);
                        else


                            numConstr=numel(prob.Constraints.(constrName));
                            constrIdxEnd=constrIdxBegin+numConstr-1;
                            output.ineq.(constrName)=ineqVals(constrIdxBegin:constrIdxEnd);
                            constrIdxBegin=constrIdxBegin+numConstr;
                        end
                    end
                end

                varargout{3}=output;

                if nargout>4

                    varargout{4}=mapLambdaSolution(prob,lambda);
                end
            end
        end
    end


    isDisplayOn=true;
    for i=1:length(varargin)
        if strcmp(varargin{i},'Options')
            opts=varargin{i+1};
            isDisplayOn=optim.internal.problemdef.display.allowsDisplay(opts);
            break
        end
    end


    if nargout>3||isDisplayOn
        varargout{3}=mapExitMessage(prob,solverFval,solverExitflag,output,varargin{:});
    end




    function sol=makeSolutionStruct(prob,x)





        varStruct=prob.Variables;
        varNames=fieldnames(varStruct);

        if~isempty(x)
            sol=varStruct;
            for k=1:numel(varNames)
                thisVarName=varNames{k};
                thisVar=varStruct.(thisVarName);
                thisVarOffset=getOffset(thisVar);
                thisVarSize=getSize(thisVar);
                sol.(thisVarName)=reshape(x(thisVarOffset:thisVarOffset+prod(thisVarSize)-1),...
                thisVarSize);
            end
        else

            sol=cell2struct(repmat({[]},numel(varNames),1),varNames,1);
        end
    end


end
