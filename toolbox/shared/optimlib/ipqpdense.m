function[x,fval,exitflag,output,lambda]=ipqpdense(H,f,A,b,Aeq,beq,lb,ub,x0,...
    flags,opts,defaultopt)













    A=full(A);
    Aeq=full(Aeq);


    optionsNeeded={'Display';'ConvexCheck';'MaxIter';'TolCon';'TolFun';'TolX';'EnablePresolve';'DynamicReg'};
    defaultopt.EnablePresolve=true;
    defaultopt.DynamicReg='on';
    defaultopt.ConvexCheck='on';

    for i=1:numel(optionsNeeded)
        field=optionsNeeded{i};
        options.(field)=optimget(opts,field,defaultopt,'fast');
    end


    if~isempty(x0)&&flags.verbosity>=1
        fprintf(getString(message('optimlib:ipqpcommon:IgnoringX0')));
    end


    if isfield(options,'PresolveOps')
        transformsToPerform=options.PresolveOps;
    else
        transformsToPerform=[];
    end


    if options.MaxIter<0
        options.MaxIter=0;
    end


    flags.makeExitMsg=logical(flags.verbosity)||flags.computeLambda;

    if(options.EnablePresolve)


        [H,f,A,b,Aeq,beq,lb,ub,transforms,restoreData,exitflag,msg]=...
        presolve(H,full(f),A,full(b),Aeq,full(beq),full(lb),full(ub),...
        options,flags.computeLambda,transformsToPerform,flags.makeExitMsg);


        if~isempty(exitflag)
            x=[];fval=[];lambda=[];
            output.algorithm='interior-point-convex';
            output.iterations=0;
            output.cgiterations=[];
            output.constrviolation=[];
            output.firstorderopt=[];
            output.message=msg;

            if exitflag>0


                [x,lambda]=postsolve(x,transforms,restoreData,...
                lambda,options,flags.computeLambda,false);
            end
            return
        end
    end


    options=i_unwrapInternalOptions(options);


    nVar=length(f);
    classifyBoundsOnVars(lb,ub,nVar,true);

    [x,fval,exitflag,mexoutput,lambda]=...
    interiorPointQPmex(full(H),full(f),full(A),full(b),...
    full(Aeq),full(beq),full(lb),full(ub),options);



    dispMsg=flags.verbosity>0;
    switch exitflag
    case 1
        msgData={{'optimlib:ipqpcommon:Exit1basic'},...
        {'optimlib:ipqpcommon:Exit1detailed',...
        mexoutput.dualResNorm/mexoutput.dualRelTol*options.TolFun,options.TolFun,...
        mexoutput.complError,...
        mexoutput.primalResNorm/mexoutput.primalRelTol*options.TolCon,options.TolCon},...
        dispMsg,flags.detailedExitMsg};
    case 0
        msgData={{'optimlib:commonMsgs:Exit10basic',flags.caller,options.MaxIter},...
        {},dispMsg,false};
    case 2


        AineqFeasible=true;
        lbFeasible=true;
        ubFeasible=true;
        AeqFeasible=true;

        if(~isempty(A))
            AineqFeasible=all(A*x<=b+options.TolCon);
        end
        if(~isempty(lb))
            lbFeasible=all(x>=lb-options.TolCon);
        end
        if(~isempty(ub))
            ubFeasible=all(x<=ub+options.TolCon);
        end
        if(~isempty(Aeq))
            AeqFeasible=all(norm(Aeq*x-beq,inf)<=options.TolCon);
        end

        msgID='optimlib:ipqpcommon:Exit2detailed';
        if~(AineqFeasible&&lbFeasible&&ubFeasible&&AeqFeasible)
            exitflag=-2;
            msgID='optimlib:ipqpcommon:ExitNeg22detailed';
        end

        msgData={{replace(msgID,'detailed','basic'),flags.caller},...
        {msgID,options.TolX,...
        mexoutput.primalResNorm/mexoutput.primalRelTol,options.TolCon},...
        dispMsg,flags.detailedExitMsg};
    case-2
        msgData={{'optimlib:ipqpcommon:ExitNeg21basic',flags.caller},...
        {'optimlib:ipqpcommon:ExitNeg21detailed',...
        mexoutput.meritFun/mexoutput.meritFunTol*options.TolFun},...
        dispMsg,flags.detailedExitMsg};
    case-3
        msgData={{'optimlib:ipqpcommon:ExitNeg3basic',flags.caller},{},dispMsg,false};
    case-6

        msgData={{'optimlib:ipqpcommon:ExitNeg6basic'},{},dispMsg,false};
    case-8
        msgData={{'optimlib:ipqpcommon:ExitNeg8basic'},{},dispMsg,false};
    case 91
        error(message('optimlib:ipqpcommon:ipConvexQP:emptyProblem'));
    case{10,11,12}
        error(message('optimlib:ipqpcommon:ipConvexQP:InfNaNComplexDetected'));
    otherwise
        error(message('optimlib:ipqpcommon:ipConvexQP:unknownExitflag'));
    end


    if(options.EnablePresolve)
        if(~isempty(x))
            [x,lambda]=postsolve(x,transforms,restoreData,lambda,options,...
            flags.computeLambda,false);
        end
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

    output.algorithm='interior-point-convex';
    output.firstorderopt=[];
    output.constrviolation=[];
    output.iterations=mexoutput.iterations;




    function options=i_unwrapInternalOptions(options)


        if~isfield(options,'ConvexityCheck')
            options.ConvexityCheck='on';
        end

        if~isfield(options,'InternalOptions')
            return;
        end



        if isstruct(options.InternalOptions)
            internalOptionNames=fieldnames(options.InternalOptions);
        else
            internalOptionNames={};
        end
        for i=1:length(internalOptionNames)
            options.(internalOptionNames{i})=options.InternalOptions.(internalOptionNames{i});
        end


        options=rmfield(options,'InternalOptions');

