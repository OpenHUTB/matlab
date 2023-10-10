function solution=surrogateNLPsolver(x0,lb,ub,Aineq,bineq,Aeq,beq)

    persistent minlp_options surrogates constraintFcn objectiveFcn nlp_solver nlp_options...
    intcon node_options nobj_expensive mineq_expensive objSurrogate constrSurrogates

    if nargout==0

        if nargin==0
            minlp_options=[];surrogates=[];constraintFcn=[];
            objectiveFcn=[];nlp_solver=[];nlp_options=[];
            intcon=[];node_options=[];nobj_expensive=[];
            mineq_expensive=[];objSurrogate=[];constrSurrogates=[];
munlock
            return
        end

        nobj_expensive=x0;
        mineq_expensive=lb;
        surrogates=ub;
        minlp_options=Aineq;
        intcon=bineq;
        node_options=Aeq;
        if~isempty(intcon)
            intcon=intcon+1;
        end
        NodeNLPSolver=minlp_options.NodeNLPSolver;
        nlp_options=minlp_options.NodeNLPSolverOptions;

        if nobj_expensive>0
            objSurrogate=@(x)surrogates(x,'Fval');
            objectiveFcn=@(x)objective(x);
        else
            objectiveFcn=@no_objective;
        end

        if mineq_expensive>0
            constrSurrogates=@(x)surrogates(x,'Ineq');
            constraintFcn=@nonlinconstr;
        else
            constraintFcn=[];
        end

        if surrogates.have_hessian
            hessianFcn=@hessian;
        else
            hessianFcn=[];
        end
        NodeNLPSolver=lower(NodeNLPSolver);

        ConstraintTolerance=min(minlp_options.LinearConstraintTolerance,...
        minlp_options.ConstraintTolerance);


        if strcmp(NodeNLPSolver,'interior-point')||...
            strcmp(NodeNLPSolver,'sqp')
            if isempty(nlp_options)
                nlp_options=optimoptions('fmincon','Algorithm',NodeNLPSolver,...
                'Display','off');
            end
            nlp_options=optimoptions(nlp_options,'Algorithm',NodeNLPSolver,...
            'SpecifyConstraintGradient',surrogates.have_gradients,...
            'SpecifyObjectiveGradient',surrogates.have_gradients,...
            'ConstraintTolerance',ConstraintTolerance);

            if strcmp(NodeNLPSolver,'interior-point')
                nlp_options.HessianFcn=hessianFcn;
            end

            nlp_solver=@(x0,lb,ub,Aineq,bineq,Aeq,beq)...
            fmincon_run(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,constraintFcn,nlp_options);

        elseif strcmp(NodeNLPSolver,'interior-point-multi-start')||...
            strcmp(NodeNLPSolver,'sqp-multi-start')

            NodeNLPSolver=NodeNLPSolver(1:strfind(NodeNLPSolver,'multi-start')-2);
            if isempty(nlp_options)
                nlp_options=optimoptions('fmincon','Algorithm',NodeNLPSolver,...
                'Display','off');
            end
            nlp_options=optimoptions(nlp_options,'Algorithm',NodeNLPSolver,...
            'SpecifyConstraintGradient',surrogates.have_gradients,...
            'SpecifyObjectiveGradient',surrogates.have_gradients,...
            'ConstraintTolerance',ConstraintTolerance);

            if strcmp(NodeNLPSolver,'interior-point')
                nlp_options.HessianFcn=hessianFcn;
            end

            nlp_solver=@(x0,lb,ub,Aineq,bineq,Aeq,beq)...
            multi_start_run(objectiveFcn,x0,Aineq,bineq,...
            Aeq,beq,lb,ub,constraintFcn,nlp_options);

        elseif strcmpi(NodeNLPSolver,'patternsearch')
            if isempty(nlp_options)
                nlp_options=optimoptions(NodeNLPSolver,'Display','off');
            end
            nlp_options=optimoptions(nlp_options,'UseVectorized',true,...
            'UseCompletePoll',true,...
            'ConstraintTolerance',ConstraintTolerance);

            nlp_solver=@(x0,lb,ub,Aineq,bineq,Aeq,beq)...
            patternsearch_run(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,...
            constraintFcn,nlp_options);

        elseif strcmpi(NodeNLPSolver,'ga')
            if isempty(nlp_options)
                nlp_options=optimoptions(NodeNLPSolver,'Display','off');
            end
            nlp_options=optimoptions(nlp_options,'UseVectorized',true,...
            'ConstraintTolerance',ConstraintTolerance,'Display','off');

            nlp_solver=@(x0,lb,ub,Aineq,bineq,Aeq,beq)...
            ga_run(objectiveFcn,numel(x0),Aineq,bineq,Aeq,beq,lb,ub,...
            constraintFcn,nlp_options);

        else
            assert(false,'NodeNLPSolver is not supported');
        end

mlock
        return
    end

    t=tic;
    solution=nlp_solver(x0(:)',lb(:)',ub(:)',Aineq,bineq,Aeq,beq);
    if~isempty(solution.x)&&solution.exitflag~=1&&...
        solution.exitflag~=-2
        solution.exitflag=2;
    end

    if~isempty(intcon)&&~isempty(node_options)
        solution=node_heuristics(solution,objectiveFcn,...
        Aineq,bineq,Aeq,beq,lb,ub,intcon,constraintFcn,...
        nlp_options,minlp_options,node_options);
    end
    solution.time_elapsed=toc(t);


    function[cineq,ceq,cineqgrad,ceqgrad]=nonlinconstr(x)
        [cineq,cineqgrad]=constrSurrogates(x);
        cineqgrad=squeeze(cineqgrad);
        if numel(cineq)==1
            cineqgrad=cineqgrad(:);
        end
        if numel(x)==1
            cineqgrad=cineqgrad(:)';
        end
        ceq=[];
        ceqgrad=[];
    end


    function[fval,grad]=objective(x)

        if nargout>1
            [fval,grad]=objSurrogate(x);
            grad=squeeze(grad);
        else
            fval=objSurrogate(x);
        end

    end


    function[fval,grad]=no_objective(x)
        fval=1;
        grad=zeros(numel(x),1);
    end


    function Hess=hessian(x,lambda)

        if nobj_expensive>0
            Hess=surrogates.getEvaluator().hessian(x(:)','Fval');
            Hess=squeeze(Hess);
        else
            Hess=zeros(numel(x));
        end

        if mineq_expensive>0
            ineq_Hess=surrogates.getEvaluator().hessian(x(:)','Ineq');
            for ii=1:mineq_expensive
                Hess=Hess+lambda.ineqnonlin(ii)*squeeze(ineq_Hess(:,:,:,ii));
            end
        end
    end

end


function solution=multi_start_run(objectiveFcn,x0,Aineq,bineq,...
    Aeq,beq,lb,ub,constraintFcn,nlp_options)

    problem=createOptimProblem('fmincon','objective',objectiveFcn,...
    'x0',x0,'Aineq',Aineq,'bineq',bineq,...
    'Aeq',Aeq,'beq',beq,'lb',lb,'ub',ub,...
    'nonlcon',constraintFcn,'options',nlp_options);

    ms=MultiStart('Display','off');
    [x,fval,exitflag]=run(ms,problem,20);

    solution=struct('x',x,'fval',fval,'exitflag',exitflag);

end


function solution=fmincon_run(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,nlp_options)
    [x,fval,exitflag,output]=fmincon(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,nlp_options);

    bestfeasible=output.bestfeasible;
    if~isempty(bestfeasible)
        solution=struct('x',bestfeasible.x,'fval',bestfeasible.fval,...
        'exitflag',1);
    else
        solution=struct('x',x,'fval',fval,'exitflag',exitflag);
    end
end


function solution=ga_run(objectiveFcn,nvar,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,nlp_options)
    [x,fval,exitflag]=ga(objectiveFcn,nvar,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,[],nlp_options);
    solution=struct('x',x,'fval',fval,'exitflag',exitflag);
end


function solution=patternsearch_run(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,nlp_options)
    [x,fval,exitflag]=patternsearch(objectiveFcn,x0,Aineq,bineq,Aeq,beq,lb,ub,...
    constraintFcn,nlp_options);

    solution=struct('x',x,'fval',fval,'exitflag',exitflag);

end


function solution=node_heuristics(solution,objectiveFcn,...
    Aineq,bineq,Aeq,beq,lb,ub,intcon,constraintFcn,...
    nlp_options,minlp_options,node_options)

    if solution.exitflag==-2
        return;
    end

    problem=struct('Aineq',Aineq,'bineq',bineq,'Aeq',Aeq,'beq',beq,...
    'lb',lb,'ub',ub,'vartype',false(numel(lb),1),'intcon',intcon);
    problem.vartype(intcon)=true;

    if checkIntegerFeasible(solution.x)

        solution.integer=true;
        return;
    end

    if node_options.RoundingHeurisics
        x_integer=globaloptim.bmo.boundAndRound(solution.x,problem,[],minlp_options);
        if~isempty(x_integer)


            if isempty(constraintFcn)||...
                max(constraintFcn(x_integer))<=nlp_options.ConstraintTolerance
                solution.x_integer=x_integer;
                solution.fval_integer=objectiveFcn(x_integer);
            end
        end
    end


    function integerFeasible=checkIntegerFeasible(trials)
        intVarIdx=problem.vartype;
        integerFeasible=all(abs(round(trials(:,intVarIdx))-trials(:,intVarIdx))<=...
        minlp_options.IntegerTolerance,2);
    end

end
