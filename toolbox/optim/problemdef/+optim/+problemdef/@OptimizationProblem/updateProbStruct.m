function probStruct=updateProbStruct(~,caller,probStruct,userDefinedSolver)














    if nargin<2||isempty(userDefinedSolver)
        userDefinedSolver=probStruct.solver;
    end
    applySolver=solverMap(probStruct.solver,userDefinedSolver,caller);



    autoSelectedSolver=probStruct.solver;
    probStruct.solver=userDefinedSolver;


    try
        probStruct=applySolver(probStruct);
    catch ME
        if strcmp(caller,'prob2struct')||strcmp(ME.identifier,'optim_problemdef:UnsupportedSolver')
            throwAsCaller(iErrorIncompatibleSolver(userDefinedSolver,caller,autoSelectedSolver));
        else
            rethrow(ME);
        end
    end

end


function probStruct=do_nothing(probStruct)

end


function probStruct=linprog_to_quadprog_conversion(probStruct)
    probStruct.H=[];
end

function probStruct=linprog_to_coneprog_conversion(probStruct)
    probStruct.socConstraints=[];
end

function probStruct=linprog_to_fminunc_conversion(probStruct)

    X0_COLUMN_STORAGE=true;

    if isConstrained(probStruct)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=linprog_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;

    probStruct=createLinearObjectiveFcn(probStruct,fname,X0_COLUMN_STORAGE);
    probStruct.nonlcon=[];
    probStruct=rmfield(probStruct,'x0');
end

function probStruct=linprog_to_particleswarm_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);

    probStruct=rmfield(probStruct,"x0");

end

function probStruct=linprog_to_simulannealbnd_conversion(probStruct)


    X0_COLUMN_STORAGE=true;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=linprog_to_surrogateopt_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
    probStruct=rmfield(probStruct,'x0');
end


function probStruct=quadprog_to_linprog_conversion(probStruct)
    if nnz(probStruct.H)==0
        probStruct=rmfield(probStruct,'H');
    else

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
end

function probStruct=quadprog_to_lsq_error(probStruct,solverName)%#ok<INUSL>
    throwAsCaller(MException(message('optim_problemdef:OptimizationProblem:solve:notSumOfSquares',solverName)));
end

function probStruct=quadprog_to_coneprog_conversion(probStruct)
    if nnz(probStruct.H)==0
        probStruct=rmfield(probStruct,'H');
        probStruct.socConstraints=[];
    else

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
end

function probStruct=quadprog_to_fminunc_conversion(probStruct)

    X0_COLUMN_STORAGE=true;

    if isConstrained(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
    probStruct=createQuadraticObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=quadprog_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;

    probStruct=createQuadraticObjectiveFcn(probStruct,fname,X0_COLUMN_STORAGE);
    probStruct.nonlcon=[];
    probStruct=rmfield(probStruct,'x0');
end

function probStruct=quadprog_to_particleswarm_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createQuadraticObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);

    probStruct=rmfield(probStruct,"x0");
end

function probStruct=quadprog_to_simulannealbnd_conversion(probStruct)


    X0_COLUMN_STORAGE=true;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createQuadraticObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=quadprog_to_surrogateopt_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createQuadraticObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
    probStruct=rmfield(probStruct,'x0');
end


function probStruct=lsqlin_to_linprog_conversion(probStruct)
    if nnz(probStruct.C)==0
        nVar=size(probStruct.C,2);
        probStruct.f=sparse(nVar,1);
        d=probStruct.d;
        probStruct.f0=probStruct.f0+0.5*(d'*d);
        probStruct=rmfield(probStruct,{'C','d'});
    else

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
end

function probStruct=lsqlin_to_quadprog_conversion(probStruct)





    C=probStruct.C;
    d=probStruct.d;
    probStruct.H=C'*C;
    probStruct.f=-C'*d;
    probStruct.f0=probStruct.f0+0.5*(d'*d);
    probStruct=rmfield(probStruct,{'C','d'});
end

function probStruct=lsqlin_to_coneprog_conversion(probStruct)
    probStruct=lsqlin_to_linprog_conversion(probStruct);
    probStruct.socConstraints=[];
end

function probStruct=lsqlin_to_fminunc_conversion(probStruct)

    X0_COLUMN_STORAGE=true;

    if isConstrained(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
    probStruct=createLinearSumSquaresObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=lsqlin_to_lsqnonneg_conversion(probStruct)


    if isempty(probStruct.lb)||any(probStruct.lb,'all')
        throwAsCaller(MException('optim_problemdef:OptimizationProblem:solve:LsqnonnegLB',...
        getString(message('optim_problemdef:ProblemImpl:solve:LsqnonnegLB'))));
    end


    if~all(isinf(probStruct.ub),'all')||~isempty(probStruct.Aineq)||~isempty(probStruct.Aeq)
        throwAsCaller(MException('optim_problemdef:OptimizationProblem:solve:LsqnonnegConstr',...
        getString(message('optim_problemdef:ProblemImpl:solve:LsqnonnegConstr'))));
    end

end

function probStruct=lsqlin_to_lsqnonlin_conversion(probStruct)

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
    probStruct=createLinearLeastSquaresObjectiveFcn(probStruct);
end

function probStruct=lsqlin_to_lsqcurvefit_conversion(probStruct)
    probStruct=lsqlin_to_lsqnonlin_conversion(probStruct);
    probStruct=convertToLsqnonlin(probStruct);
end

function probStruct=lsqlin_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;

    probStruct=createLinearSumSquaresObjectiveFcn(probStruct,fname,X0_COLUMN_STORAGE);
    probStruct.nonlcon=[];
    probStruct=rmfield(probStruct,'x0');
end

function probStruct=lsqlin_to_particleswarm_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearSumSquaresObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);

    probStruct=rmfield(probStruct,"x0");
end

function probStruct=lsqlin_to_simulannealbnd_conversion(probStruct)


    X0_COLUMN_STORAGE=true;

    if hasLinearConstraints(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearSumSquaresObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
end

function probStruct=lsqlin_to_surrogateopt_conversion(probStruct)


    X0_COLUMN_STORAGE=false;

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createLinearSumSquaresObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);
    probStruct=rmfield(probStruct,'x0');
end



function probStruct=coneprog_to_nonlin_conversion(probStruct)

    X0_COLUMN_STORAGE=true;


    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);



    probStruct=optim.internal.problemdef.compile.createSecondOrderConeConstraintFcn(probStruct);
end

function probStruct=coneprog_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;

    probStruct=createLinearObjectiveFcn(probStruct,fname,X0_COLUMN_STORAGE);
    probStruct=optim.internal.problemdef.compile.createSecondOrderConeConstraintFcn(probStruct);

    if~isfield(probStruct,'nonlcon')
        probStruct.nonlcon=[];
    end
end

function probStruct=coneprog_to_surrogateopt_conversion(probStruct)

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;


    probStruct=createLinearObjectiveFcn(probStruct,"objective",X0_COLUMN_STORAGE);



    probStruct=optim.internal.problemdef.compile.createSecondOrderConeConstraintFcn(probStruct);


    if isfield(probStruct,'nonlcon')
        if~isempty(probStruct.nonlcon)
            probStruct.objective=...
            @(x)struct('Fval',probStruct.objective(x),'Ineq',probStruct.nonlcon(x));
            probStruct.FcnHandleForWorkers.funfcn=...
            @(x)struct('Fval',probStruct.FcnHandleForWorkers.funfcn(x),'Ineq',probStruct.FcnHandleForWorkers.confcn(x));
        end
        probStruct=rmfield(probStruct,'nonlcon');
        probStruct.FcnHandleForWorkers.confcn={};
    end
end



function probStruct=lsqnonlin_to_fminunc_conversion(probStruct)

    X0_COLUMN_STORAGE=true;

    if isConstrained(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end
    probStruct=createNonlinearSumSquaresObjectiveFcn(probStruct,X0_COLUMN_STORAGE);
end

function probStruct=lsqnonlin_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    X0_COLUMN_STORAGE=false;

    probStruct=rmfield(probStruct,"x0");
    probStruct=createNonlinearSumSquaresObjectiveFcn(probStruct,X0_COLUMN_STORAGE);
    if strcmpi(fname,"fitnessfcn")
        probStruct.fitnessfcn=probStruct.objective;
        probStruct=rmfield(probStruct,"objective");
    end
    probStruct.nonlcon=[];
end

function probStruct=lsqnonlin_to_surrogateopt_conversion(probStruct)

    X0_COLUMN_STORAGE=false;

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    probStruct=createNonlinearSumSquaresObjectiveFcn(probStruct,X0_COLUMN_STORAGE);
    probStruct=rmfield(probStruct,'x0');
end



function probStruct=nonlin_global_nvar_conversion(probStruct,fname,customSolver)

    if probStruct.NumNonlinEqConstraints>0&&~globalSolverSupportsNonlinEq(customSolver)
        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end


    probStruct=setInitialPoints(probStruct);

    probStruct=rmfield(probStruct,"x0");

    if strcmpi(fname,"fitnessfcn")
        probStruct.fitnessfcn=probStruct.objective;
        probStruct=rmfield(probStruct,"objective");
    end


    if~isfield(probStruct,'nonlcon')
        probStruct.nonlcon=[];
    end
end



function probStruct=fmincon_to_lsqnonlin_error(probStruct,solverName)%#ok<INUSL>
    throwAsCaller(...
    MException(message('optim_problemdef:OptimizationProblem:solve:notSumOfSquares',solverName)));
end

function probStruct=fmincon_to_particleswarm_conversion(probStruct)



    probStruct=setInitialPoints(probStruct);

    hasNonlconField=isfield(probStruct,'nonlcon');

    if hasLinearConstraints(probStruct)||...
        (hasNonlconField&&~isempty(probStruct.nonlcon))

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    if hasNonlconField
        probStruct=rmfield(probStruct,'nonlcon');
    end

    probStruct=rmfield(probStruct,"x0");
end

function probStruct=fmincon_to_simulannealbnd_conversion(probStruct)


    hasNonlconField=isfield(probStruct,'nonlcon');

    if hasLinearConstraints(probStruct)||...
        (hasNonlconField&&~isempty(probStruct.nonlcon))

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    if hasNonlconField
        probStruct=rmfield(probStruct,'nonlcon');
    end
end

function probStruct=fmincon_to_surrogateopt_conversion(probStruct)


    probStruct=setInitialPoints(probStruct);

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end


    if isfield(probStruct,'nonlcon')
        if~isempty(probStruct.nonlcon)
            probStruct.objective=...
            @(x)struct('Fval',probStruct.objective(x),'Ineq',probStruct.nonlcon(x));
            probStruct.FcnHandleForWorkers.funfcn=...
            @(x)struct('Fval',probStruct.FcnHandleForWorkers.funfcn(x),...
            'Ineq',probStruct.FcnHandleForWorkers.confcn(x));
        end
        probStruct=rmfield(probStruct,'nonlcon');
        probStruct.FcnHandleForWorkers.confcn={};
    end
    probStruct=rmfield(probStruct,'x0');
end



function probStruct=ga_to_ga_conversion(probStruct)



    probStruct.fitnessfcn=probStruct.objective;
    probStruct=rmfield(probStruct,'objective');

    if~isfield(probStruct,'nonlcon')
        probStruct.nonlcon=[];
    end

end

function probStruct=gamultiobj_to_gamultiobj_conversion(probStruct)




    probStruct.fitnessfcn=probStruct.objective;
    probStruct=rmfield(probStruct,'objective');

    if~isfield(probStruct,'nonlcon')
        probStruct.nonlcon=[];
    end


    probStruct=setInitialPoints(probStruct);


    if isfield(probStruct,'x0')
        probStruct=rmfield(probStruct,'x0');
    end

end

function probStruct=gamultiobj_to_paretosearch_conversion(probStruct)




    if probStruct.NumNonlinEqConstraints>0

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end

    if~isfield(probStruct,'nonlcon')
        probStruct.nonlcon=[];
    end


    probStruct=setInitialPoints(probStruct);


    if isfield(probStruct,'x0')
        probStruct=rmfield(probStruct,'x0');
    end

end

function probStruct=ga_to_surrogateopt_conversion(probStruct)

    if isSurrogateoptUnsupported(probStruct)

        throw(MException('optim_problemdef:UnsupportedSolver','UnsupportedSolver'));
    end


    if isfield(probStruct,'nonlcon')
        if~isempty(probStruct.nonlcon)
            probStruct.objective=...
            @(x)struct('Fval',probStruct.objective(x),'Ineq',probStruct.nonlcon(x));
            probStruct.FcnHandleForWorkers.funfcn=...
            @(x)struct('Fval',probStruct.FcnHandleForWorkers.funfcn(x),'Ineq',probStruct.FcnHandleForWorkers.confcn(x));
        end
        probStruct=rmfield(probStruct,'nonlcon');
        probStruct.FcnHandleForWorkers.confcn={};
    end
end





function probStruct=createLinearObjectiveFcn(probStruct,fname,colwise)



    f=probStruct.f;
    if colwise
        if isempty(f)
            nVar=probStruct.NumVars;
            probStruct.(fname)=@(x)zeroObjectiveFcn_Columnwise(x,nVar);
        else
            probStruct.(fname)=@(x)linearObjectiveFcn_Columnwise(x,f);
        end
    else
        if isempty(f)
            nVar=probStruct.NumVars;
            probStruct.(fname)=@(x)zeroObjectiveFcn_Rowwise(x,nVar);
        else
            probStruct.(fname)=@(x)linearObjectiveFcn_Rowwise(x,f);
        end
    end
    probStruct=rmfield(probStruct,'f');



    probStruct.objectiveDerivative="closed-form";

end



function probStruct=createQuadraticObjectiveFcn(probStruct,fname,colwise)



    if~issymmetric(probStruct.H)
        H=(probStruct.H+probStruct.H')/2;
    else
        H=probStruct.H;
    end
    f=probStruct.f;

    if colwise
        probStruct.(fname)=@(x)quadraticObjectiveFcn_Columnwise(x,H,f);
    else
        probStruct.(fname)=@(x)quadraticObjectiveFcn_Rowwise(x,H,f);
    end

    probStruct=rmfield(probStruct,{'H','f'});



    probStruct.objectiveDerivative="closed-form";

end

function probStruct=createLinearSumSquaresObjectiveFcn(probStruct,fname,colwise)



    C=probStruct.C;
    d=probStruct.d;

    if colwise
        probStruct.(fname)=@(x)linearSumSquaresObjectiveFcn_Columnwise(x,C,d);
    else
        probStruct.(fname)=@(x)linearSumSquaresObjectiveFcn_Rowwise(x,C',d');
    end

    probStruct=rmfield(probStruct,{'C','d'});



    probStruct.objectiveDerivative="closed-form";

end

function probStruct=createLinearLeastSquaresObjectiveFcn(probStruct)



    C=probStruct.C;
    d=probStruct.d;
    probStruct.objective=@(x)linearLeastSquaresObjectiveFcn_Columnwise(x,C,d);
    probStruct.FcnHandleForWorkers.funfcn={};
    probStruct=rmfield(probStruct,{'C','d'});



    probStruct.objectiveDerivative="closed-form";

end

function probStruct=createNonlinearSumSquaresObjectiveFcn(probStruct,colwise)



    objfcn=probStruct.objective;
    workerfcn=probStruct.FcnHandleForWorkers.funfcn;

    if colwise
        probStruct.objective=@(x)nonlinearSumSquaresObjectiveFcn_Columnwise(x,objfcn);
        probStruct.FcnHandleForWorkers.funfcn=@(x)nonlinearSumSquaresObjectiveFcn_Columnwise(x,workerfcn);
    else
        probStruct.objective=@(x)nonlinearSumSquaresObjectiveFcn_Rowwise(x,objfcn);
        probStruct.FcnHandleForWorkers.funfcn=@(x)nonlinearSumSquaresObjectiveFcn_Rowwise(x,workerfcn);
    end

end


function probStruct=convertToLsqnonlin(probStruct)


    if optim.internal.problemdef.display.allowsDisplay(probStruct.options)
        selectLsqnonlinMsg=...
        getString(message('optim_problemdef:OptimizationProblem:solve:SelectLsqnonlin'));
        fprintf('\n%s\n',selectLsqnonlinMsg);
    end


    if isa(probStruct.options,'optim.options.Lsqcurvefit')
        probStruct.options=optimoptions('lsqnonlin',probStruct.options);
    end


    probStruct.solver='lsqnonlin';
end


function iscon=isConstrained(probStruct)

    iscon=any(~isinf(probStruct.lb))||any(~isinf(probStruct.ub))||...
    hasLinearConstraints(probStruct);

end


function hasLincon=hasLinearConstraints(probStruct)

    hasLincon=~isempty(probStruct.Aineq)||~isempty(probStruct.Aeq);

end



function tf=isSurrogateoptUnsupported(probStruct)
    tf=isempty(probStruct.lb)||isempty(probStruct.ub)||...
    any(isinf(probStruct.lb))||any(isinf(probStruct.ub))||...
    probStruct.NumNonlinEqConstraints>0;
end



function supportsNonlinEq=globalSolverSupportsNonlinEq(customSolver)

    supportsNonlinEq=~any(strcmp(customSolver,["paretosearch","particleswarm"]));

end



function MEx=iErrorIncompatibleSolver(solvername,caller,autoSelectedSolver)


    MEx=MException(...
    "optim_problemdef:OptimizationProblem:"+caller+":IncompatibleSolver",...
    string(message("optim_problemdef:ProblemImpl:"+caller+":IncompatibleSolver",...
    solvername,autoSelectedSolver)));

end


function[Fval,grad]=nonlinearSumSquaresObjectiveFcn_Columnwise(x,objfcn)





    if nargout>1
        [fvec,jac]=objfcn(x);
        grad=2*jac'*fvec(:);
    else
        fvec=objfcn(x);
    end

    fvec=fvec(:);
    Fval=sum(fvec.^2);

end

function[fval,grad]=zeroObjectiveFcn_Columnwise(~,nVar)

    fval=0;
    if nargout>1
        grad=zeros(nVar,1);
    end

end

function[fval,grad]=linearObjectiveFcn_Columnwise(x,f)

    fval=f'*x;
    if nargout>1
        grad=f;
    end

end

function[fval,grad]=quadraticObjectiveFcn_Columnwise(x,H,f)



    Hx=H'*x;
    fval=0.5*(x'*Hx)+f'*x;
    if nargout>1
        grad=Hx+f;
    end

end

function[fval,grad]=linearSumSquaresObjectiveFcn_Columnwise(x,C,d)

    fval=0.5*sum((C*x-d).^2);
    if nargout>1
        grad=C'*(C*x-d);
    end


end

function[fval,jac]=linearLeastSquaresObjectiveFcn_Columnwise(x,C,d)

    fval=C*x-d;
    if nargout>1
        jac=C;
    end

end


function[Fval,grad]=nonlinearSumSquaresObjectiveFcn_Rowwise(x,objfcn)





    if nargout>1
        [fvec,jac]=objfcn(x.');
        grad=2*jac'*fvec(:);
    else
        fvec=objfcn(x.');
    end

    fvec=fvec(:).';
    Fval=sum(fvec.^2,2);

end

function[fval,grad]=zeroObjectiveFcn_Rowwise(~,nVar)

    fval=0;
    if nargout>1
        grad=zeros(nVar,1);
    end

end

function[fval,grad]=linearObjectiveFcn_Rowwise(x,f)

    fval=x*f(:);
    if nargout>1
        grad=f;
    end


end

function[fval,grad]=quadraticObjectiveFcn_Rowwise(x,H,f)






    Hxt=H'*x';
    fval=0.5*(x*Hxt)+x*f;
    if nargout>1
        grad=Hxt+f;
    end


end

function[fval,grad]=linearSumSquaresObjectiveFcn_Rowwise(x,C_trans,d_trans)





    res=x*C_trans-d_trans;
    fval=0.5*sum(res.^2,2);
    if nargout>1
        grad=res*C_trans';
    end


end

function fhdl=solverMap(probStructSolver,userDefinedSolver,caller)



    persistent optimSolverMap globalSolverMap
    if isempty(optimSolverMap)
























        X0_COLUMN_STORAGE=true;



        optimSolverMap=struct;


        optimSolverMap.("linprog_to_linprog")=@do_nothing;
        optimSolverMap.("linprog_to_intlinprog")=@do_nothing;
        optimSolverMap.("linprog_to_quadprog")=@linprog_to_quadprog_conversion;
        optimSolverMap.("linprog_to_coneprog")=@linprog_to_coneprog_conversion;
        optimSolverMap.("linprog_to_fminunc")=@linprog_to_fminunc_conversion;
        optimSolverMap.("linprog_to_fmincon")=@(p)createLinearObjectiveFcn(p,'objective',X0_COLUMN_STORAGE);


        optimSolverMap.("intlinprog_to_linprog")=@do_nothing;
        optimSolverMap.("intlinprog_to_intlinprog")=@do_nothing;


        optimSolverMap.("quadprog_to_linprog")=@(p)quadprog_to_linprog_conversion(p);
        optimSolverMap.("quadprog_to_intlinprog")=@(p)quadprog_to_linprog_conversion(p);
        optimSolverMap.("quadprog_to_quadprog")=@do_nothing;
        optimSolverMap.("quadprog_to_lsqlin")=@(p)quadprog_to_lsq_error(p,"lsqlin");
        optimSolverMap.("quadprog_to_coneprog")=@quadprog_to_coneprog_conversion;
        optimSolverMap.("quadprog_to_fminunc")=@quadprog_to_fminunc_conversion;
        optimSolverMap.("quadprog_to_fmincon")=@(p)createQuadraticObjectiveFcn(p,'objective',X0_COLUMN_STORAGE);
        optimSolverMap.("quadprog_to_lsqnonneg")=@(p)quadprog_to_lsq_error(p,"lsqnonneg");
        optimSolverMap.("quadprog_to_lsqnonlin")=@(p)quadprog_to_lsq_error(p,"lsqnonlin");
        optimSolverMap.("quadprog_to_lsqcurvefit")=@(p)quadprog_to_lsq_error(p,"lsqcurvefit");


        optimSolverMap.("lsqlin_to_linprog")=@(p)lsqlin_to_linprog_conversion(p);
        optimSolverMap.("lsqlin_to_intlinprog")=@(p)lsqlin_to_linprog_conversion(p);
        optimSolverMap.("lsqlin_to_quadprog")=@lsqlin_to_quadprog_conversion;
        optimSolverMap.("lsqlin_to_lsqlin")=@do_nothing;
        optimSolverMap.("lsqlin_to_coneprog")=@lsqlin_to_coneprog_conversion;
        optimSolverMap.("lsqlin_to_fminunc")=@lsqlin_to_fminunc_conversion;
        optimSolverMap.("lsqlin_to_fmincon")=@(p)createLinearSumSquaresObjectiveFcn(p,"objective",X0_COLUMN_STORAGE);
        optimSolverMap.("lsqlin_to_lsqnonneg")=@lsqlin_to_lsqnonneg_conversion;
        optimSolverMap.("lsqlin_to_lsqnonlin")=@(p)lsqlin_to_lsqnonlin_conversion(p);
        optimSolverMap.("lsqlin_to_lsqcurvefit")=@lsqlin_to_lsqcurvefit_conversion;


        optimSolverMap.("coneprog_to_coneprog")=@do_nothing;
        optimSolverMap.("coneprog_to_fmincon")=@coneprog_to_nonlin_conversion;


        optimSolverMap.("lsqnonlin_to_fminunc")=@lsqnonlin_to_fminunc_conversion;
        optimSolverMap.("lsqnonlin_to_lsqnonlin")=@do_nothing;
        optimSolverMap.("lsqnonlin_to_lsqcurvefit")=@convertToLsqnonlin;
        optimSolverMap.("lsqnonlin_to_fmincon")=@(p)createNonlinearSumSquaresObjectiveFcn(p,X0_COLUMN_STORAGE);


        optimSolverMap.("fminunc_to_fminunc")=@do_nothing;
        optimSolverMap.("fminunc_to_fmincon")=@do_nothing;


        optimSolverMap.("fmincon_to_lsqnonlin")=@(p)fmincon_to_lsqnonlin_error(p,"lsqnonlin");
        optimSolverMap.("fmincon_to_lsqcurvefit")=@(p)fmincon_to_lsqnonlin_error(p,"lsqcurvefit");
        optimSolverMap.("fmincon_to_fmincon")=@do_nothing;





        globalSolverMap.("linprog_to_ga")=@(p)linprog_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("linprog_to_gamultiobj")=@(p)linprog_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("linprog_to_paretosearch")=@(p)linprog_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("linprog_to_particleswarm")=@linprog_to_particleswarm_conversion;
        globalSolverMap.("linprog_to_patternsearch")=@(p)createLinearObjectiveFcn(p,"objective",X0_COLUMN_STORAGE);
        globalSolverMap.("linprog_to_simulannealbnd")=@linprog_to_simulannealbnd_conversion;
        globalSolverMap.("linprog_to_surrogateopt")=@linprog_to_surrogateopt_conversion;


        globalSolverMap.("intlinprog_to_ga")=@(p)linprog_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("intlinprog_to_gamultiobj")=@(p)linprog_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("intlinprog_to_surrogateopt")=@linprog_to_surrogateopt_conversion;


        globalSolverMap.("quadprog_to_ga")=@(p)quadprog_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("quadprog_to_gamultiobj")=@(p)quadprog_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("quadprog_to_paretosearch")=@(p)quadprog_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("quadprog_to_particleswarm")=@quadprog_to_particleswarm_conversion;
        globalSolverMap.("quadprog_to_patternsearch")=@(p)createQuadraticObjectiveFcn(p,"objective",X0_COLUMN_STORAGE);
        globalSolverMap.("quadprog_to_simulannealbnd")=@quadprog_to_simulannealbnd_conversion;
        globalSolverMap.("quadprog_to_surrogateopt")=@quadprog_to_surrogateopt_conversion;


        globalSolverMap.("lsqlin_to_ga")=@(p)lsqlin_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("lsqlin_to_gamultiobj")=@(p)lsqlin_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("lsqlin_to_paretosearch")=@(p)lsqlin_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("lsqlin_to_particleswarm")=@lsqlin_to_particleswarm_conversion;
        globalSolverMap.("lsqlin_to_patternsearch")=@(p)createLinearSumSquaresObjectiveFcn(p,"objective",X0_COLUMN_STORAGE);
        globalSolverMap.("lsqlin_to_simulannealbnd")=@lsqlin_to_simulannealbnd_conversion;
        globalSolverMap.("lsqlin_to_surrogateopt")=@lsqlin_to_surrogateopt_conversion;


        globalSolverMap.("coneprog_to_ga")=@(p)coneprog_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("coneprog_to_gamultiobj")=@(p)coneprog_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("coneprog_to_paretosearch")=@(p)coneprog_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("coneprog_to_patternsearch")=@coneprog_to_nonlin_conversion;
        globalSolverMap.("coneprog_to_surrogateopt")=@coneprog_to_surrogateopt_conversion;


        globalSolverMap.("lsqnonlin_to_ga")=@(p)lsqnonlin_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("lsqnonlin_to_gamultiobj")=@(p)lsqnonlin_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("lsqnonlin_to_paretosearch")=@(p)lsqnonlin_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("lsqnonlin_to_particleswarm")=@(p)lsqnonlin_global_nvar_conversion(p,"objective","particleswarm");
        globalSolverMap.("lsqnonlin_to_patternsearch")=@(p)createNonlinearSumSquaresObjectiveFcn(p,X0_COLUMN_STORAGE);
        globalSolverMap.("lsqnonlin_to_simulannealbnd")=@(p)createNonlinearSumSquaresObjectiveFcn(p,X0_COLUMN_STORAGE);
        globalSolverMap.("lsqnonlin_to_surrogateopt")=@lsqnonlin_to_surrogateopt_conversion;


        globalSolverMap.("fminunc_to_ga")=@(p)nonlin_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("fminunc_to_gamultiobj")=@(p)nonlin_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("fminunc_to_paretosearch")=@(p)nonlin_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("fminunc_to_particleswarm")=@(p)nonlin_global_nvar_conversion(p,"objective","particleswarm");
        globalSolverMap.("fminunc_to_patternsearch")=@do_nothing;
        globalSolverMap.("fminunc_to_simulannealbnd")=@do_nothing;



        globalSolverMap.("fmincon_to_ga")=@(p)nonlin_global_nvar_conversion(p,"fitnessfcn","ga");
        globalSolverMap.("fmincon_to_gamultiobj")=@(p)nonlin_global_nvar_conversion(p,"fitnessfcn","gamultiobj");
        globalSolverMap.("fmincon_to_paretosearch")=@(p)nonlin_global_nvar_conversion(p,"objective","paretosearch");
        globalSolverMap.("fmincon_to_particleswarm")=@fmincon_to_particleswarm_conversion;
        globalSolverMap.("fmincon_to_patternsearch")=@do_nothing;
        globalSolverMap.("fmincon_to_simulannealbnd")=@fmincon_to_simulannealbnd_conversion;
        globalSolverMap.("fmincon_to_surrogateopt")=@fmincon_to_surrogateopt_conversion;


        globalSolverMap.("ga_to_ga")=@ga_to_ga_conversion;
        globalSolverMap.("ga_to_gamultiobj")=@ga_to_ga_conversion;
        globalSolverMap.("ga_to_surrogateopt")=@ga_to_surrogateopt_conversion;


        globalSolverMap.("gamultiobj_to_gamultiobj")=@gamultiobj_to_gamultiobj_conversion;
        globalSolverMap.("gamultiobj_to_paretosearch")=@gamultiobj_to_paretosearch_conversion;

    end

    key=probStructSolver+"_to_"+userDefinedSolver;



    if isfield(optimSolverMap,key)
        fhdl=optimSolverMap.(key);
    elseif optim.internal.utils.hasGlobalOptimizationToolbox&&isfield(globalSolverMap,key)
        fhdl=globalSolverMap.(key);
    else
        throwAsCaller(iErrorIncompatibleSolver(userDefinedSolver,caller,probStructSolver));
    end

end

function problemStruct=setInitialPoints(problemStruct)



    solversWithX0InOptions=...
    optim.problemdef.OptimizationProblem.SolversWithX0InOptions;
    idx=strcmp(solversWithX0InOptions,problemStruct.solver);
    if~isempty(problemStruct.x0Input)&&any(idx)
        initialXAlias=["InitialPopulation","InitialPopulation",...
        "InitialSwarm","InitialPoints","InitialPoints"];
        if isempty(problemStruct.options)
            problemStruct.options=optimoptions(problemStruct.solver,initialXAlias(idx),problemStruct.x0');
        else
            problemStruct.options.(initialXAlias(idx))=problemStruct.x0';
        end

        problemStruct.SolveSetInitialX=true;


        if isa(problemStruct.x0Input,'optim.problemdef.OptimizationValues')
            initObjVals=objectiveValues4Solver(problemStruct.x0Input);
            if any(isnan(initObjVals))
                initObjVals=[];
            end
            switch problemStruct.solver
            case{'ga','gamultiobj'}
                problemStruct.options.InitialScores=initObjVals;
            case 'paretosearch'
                fNames=["X0","Fvals","Cineq"];
                problemStruct.options.InitialPoints=...
                createInitialPointsStruct(problemStruct,fNames,...
                initObjVals,problemStruct.x0Input);
            case 'surrogateopt'
                fNames=["X","Fval","Ineq"];
                problemStruct.options.InitialPoints=...
                createInitialPointsStruct(problemStruct,fNames,...
                initObjVals,problemStruct.x0Input);
            end


            problemStruct.SolveSetInitialObjConVals=true;
        end
    end

    function InitialPointsStruct=createInitialPointsStruct(problemStruct,...
        fNames,initObjVals,x0)

        InitialPointsStruct.(fNames(1))=problemStruct.options.InitialPoints;
        if~isempty(initObjVals)
            InitialPointsStruct.(fNames(2))=initObjVals;
        end
        initConVals=inequalityConstraintValues4Solver(x0);
        if~isempty(initConVals)&&~any(isnan(initConVals))
            InitialPointsStruct.(fNames(3))=initConVals;
        end

    end


end
