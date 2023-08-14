function[x,fval,exitflag,output,lambda]=asqpdense(H,f,A,b,Aeq,beq,lb,ub,x0,...
    flags,opts,defaultopt)















    if isempty(x0)
        error(message('optim:quadprog:EmptyX0',upper(flags.caller)));
    elseif numel(x0)~=size(H,1)
        error(message('optim:asqpdense:InvalidSizeX0'));
    end


    [invalidProblem,boundsInvalid]=checkFiniteProblem(H,f,A,b,Aeq,beq,lb,ub,x0);


    if invalidProblem||boundsInvalid
        error(message('optim:asqpdense:InfNaNComplexDetected'));
    end



    optionsNeeded={'Display';'ConvexCheck';'MaxIter';'TolCon';'TolFun';'TolX';'ObjectiveLimit';'PricingTolerance'};
    defaultopt.ConvexCheck='on';
    defaultopt.PricingTolerance=0.0;

    for i=1:numel(optionsNeeded)
        field=optionsNeeded{i};
        opts.(field)=optimget(opts,field,defaultopt,'fast');
    end


    if opts.MaxIter<0
        opts.MaxIter=0;
    end


    flags.makeExitMsg=logical(flags.verbosity)||flags.computeLambda;


    opts.MaxIterations=optimget(opts,'MaxIter',defaultopt,'fast');
    opts.ConstraintTolerance=optimget(opts,'TolCon',defaultopt,'fast');
    opts.OptimalityTolerance=optimget(opts,'TolFun',defaultopt,'fast');
    opts.StepTolerance=optimget(opts,'TolX',defaultopt,'fast');


    [x,fval,exitflag,lambdaqp,mexoutput]=...
    activesetqp(full(H),full(f(:)),full(A),full(b(:)),full(Aeq),full(beq(:)),...
    full(lb(:)),full(ub(:)),full(x0(:)),opts);

    output.algorithm='active-set';
    output.iterations=mexoutput.numiters;
    output.constrviolation=mexoutput.maxconstr;
    output.firstorderopt=mexoutput.firstorderopt;

    if isnan(output.constrviolation)
        output.constrviolation=[];
    end
    if isnan(output.firstorderopt)
        output.firstorderopt=[];
    end

    output.message='';
    output.linearsolver=[];
    output.cgiterations=[];

    lambda=struct();
    if(flags.computeLambda)

        mEq=numel(beq);
        mIneq=numel(b);
        nVar=numel(x0);

        lambda.eqlin=lambdaqp(1:mEq);
        lambda.ineqlin=lambdaqp(mEq+1:mEq+mIneq);
        lambda.lower=lambdaqp(mEq+mIneq+1:mEq+mIneq+nVar);
        lambda.upper=lambdaqp(mEq+mIneq+nVar+1:end);
    end



    dispMsg=flags.verbosity>0;


    switch exitflag
    case 1
        msgData={{'optim:asqpdense:Exit1basic'},...
        {'optim:asqpdense:Exit1detailed',...
        output.firstorderopt/mexoutput.reloptmult,opts.OptimalityTolerance,...
        output.constrviolation/mexoutput.relconstrmult,opts.ConstraintTolerance},...
        dispMsg,flags.detailedExitMsg};
    case 0
        msgData={{'optimlib:commonMsgs:Exit10basic',flags.caller,opts.MaxIterations},...
        {},dispMsg,false};
    case-3
        exitflag=-2;
        msgData={{'optim:asqpdense:ExitNeg22basic',flags.caller},{},dispMsg,false};
    case-2
        msgData={{'optim:asqpdense:ExitNeg21basic',flags.caller},{},dispMsg,false};
    case 2
        exitflag=-3;
        msgData={{'optim:asqpdense:ExitNeg3basic',flags.caller},{},dispMsg,false};
    case 4
        exitflag=-2;
        msgData={{'optim:asqpdense:ExitNeg21basic',flags.caller},{},dispMsg,false};
    case-6
        msgData={{'optim:asqpdense:ExitNeg6basic'},{},dispMsg,false};
    otherwise
        error('Unknown exitflag from asqpdense.');
    end


    ProblemdefOptions=optimget(opts,'ProblemdefOptions',defaultopt,'fast');
    FromEqnSolve=false;
    if~isempty(ProblemdefOptions)&&isfield(ProblemdefOptions,'FromEqnSolve')
        FromEqnSolve=ProblemdefOptions.FromEqnSolve;
    end


    if FromEqnSolve


        output.msgData=msgData;
    elseif flags.makeExitMsg

        output.message=createExitMsg(msgData{:});
    end

end

function[invalidProblem,boundsInvalid]=checkFiniteProblem(H,f,A,b,Aeq,beq,lb,ub,x0)

    invalidProblem=~all(isfinite(H(:)))||~all(isfinite(x0(:)))||(~isempty(f)&&~all(isfinite(f(:))))||...
    (~isempty(A)&&~(all(isfinite(A(:)))&&all(isfinite(b(:)))))||...
    (~isempty(Aeq)&&~(all(isfinite(Aeq(:)))&&all(isfinite(beq(:)))));


    boundsInvalid=(~isempty(lb)&&(any(isnan(lb))||any(lb==Inf)))||...
    (~isempty(ub)&&(any(isnan(ub))||any(ub==-Inf)));

end

