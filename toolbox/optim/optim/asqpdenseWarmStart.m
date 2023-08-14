function[wsout,fval,exitflag,output,lambda]=asqpdenseWarmStart(H,f,A,b,Aeq,beq,lb,ub,ws,flags)















    if numel(ws.X)~=size(H,1)
        error(message('optim:asqpdense:InvalidSizeX0'));
    end


    [invalidProblem,boundsInvalid]=checkFiniteProblem(H,f,A,b,Aeq,beq,lb,ub,ws.X);


    if invalidProblem||boundsInvalid
        error(message('optim:asqpdense:InfNaNComplexDetected'));
    end

    if flags.isLeastSquaresUnconstrained
        wsout=solveUnconstrained(ws,H,f);
        return;
    end


    flags.makeExitMsg=logical(flags.verbosity)||flags.computeLambda;

    mEq=numel(beq);
    mIneq=numel(b);


    [wsout,fval,exitflag,lambdaqp,mexoutput]=...
    solve(ws,mEq,mIneq,full(H),full(f(:)),full(A),full(b(:)),full(Aeq),full(beq(:)),...
    full(lb(:)),full(ub(:)));

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

        nVar=numel(wsout.X);

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
        output.firstorderopt/mexoutput.reloptmult,wsout.Options.OptimalityTolerance,...
        output.constrviolation/mexoutput.relconstrmult,wsout.Options.ConstraintTolerance},...
        dispMsg,flags.detailedExitMsg};
    case 0
        msgData={{'optimlib:commonMsgs:Exit10basic',flags.caller,mexoutput.MaxIterations},...
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
        error('Unknown exitflag from aswsqpdense.');
    end

    if flags.makeExitMsg

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

